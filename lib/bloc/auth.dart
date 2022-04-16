/// Password guidelines from NIST 800-63b summaries:
/// https://www.netsec.news/summary-of-the-nist-password-recommendations-for-2021/
/// https://www.auditboard.com/blog/nist-password-guidelines/
///
/// Most of the logic within this file is intended to be run in the backend.

import 'package:engen518_assignment1/bloc/word_lists.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_bcrypt/flutter_bcrypt.dart';

// Face and Touch ID variables.
late final bool _canCheckBiometrics;
final _localAuth = LocalAuthentication();

/// Value added to a salt before performing bcrypt. [_pepper] is over 112 bits
/// as suggested by NIST.
late final String _pepper;

final _users = List<_User>.empty(growable: true);

/// Gets if Face or Touch ID are enabled, and retrieves value for [_pepper],
/// found in /.env.
Future<void> initAuth() async {
  _canCheckBiometrics = await _localAuth.canCheckBiometrics;
  await dotenv.load(fileName: ".env");
  _pepper = dotenv.get('PEPPER');
}

/// Adapted custom Exception solution from:
/// https://stackoverflow.com/questions/13579982/how-to-create-a-custom-exception-and-handle-it-in-dart
///
/// Used to differentiate between authentication [Exception] and other
/// [Exception] on the frontend.
class AuthException implements Exception {
  final String cause;
  AuthException(this.cause);

  @override
  String toString() {
    return cause;
  }
}

/// Checks for Face or Touch ID if enabled on the device.
///
/// Proof of concept for two-factor authentication.
Future<void> _checkBiometrics() async {
  if (_canCheckBiometrics &&
      !await _localAuth.authenticate(
          localizedReason: 'Please authenticate with your face or fingerprint.',
          biometricOnly: true)) {
    throw AuthException('Could not recognise your face or fingerprint.');
  }
}

/// Class containing all relevant user data. This a representation of fields in
/// a secure database.
class _User {
  /// Unique [_User] identifier. While the [_User] object's memory location can
  /// be used as an ID for this proof-of-concept application, an ID would be
  /// required in a database.
  final int _id;

  /// Keeps track of the lastest [_id] assigned so new [_User] objects can be
  /// assigned a unique [_id]. A smarter UUID generation system would be used in
  /// a real application.
  static int _latestUserId = -1;

  /// A unique [String] chosen on account creation. The program can modified
  /// later to include [username] modification an existing [_User] as [_id] is
  /// also unique.
  final String username;

  /// A random [String] combined with the [_pepper] and password when generating
  /// a new [_hash]. It is randomised per [_hash] generated.
  late String _salt;

  /// The result of applying bcrypt on the password combined with [_salt] and
  /// [_pepper].
  late String _hash;

  /// The number of unsuccessful login attempts on this [_User]. Reset on
  /// successful login.
  int _unsuccessfulLoginAttempts = 0;

  /// Maximum number of [_unsuccessfulLoginAttempts] before the [_User] is
  /// locked.
  ///
  /// NIST recommends at most 100 max login attempts.
  static const _maxLoginAttempts = 3;

  /// [username] should be unique.
  ///
  /// [_id] will be unique as [_latestUserId] is incremented on intialisation.
  _User({required this.username}) : _id = _latestUserId + 1 {
    _latestUserId++;
  }

  /// Generates a new [_hash] using bcrypt with [password] and a new random
  /// [_salt] conatenated with [_pepper].
  ///
  /// bcrypt with pepper solution from: https://security.stackexchange.com/questions/21263/how-to-apply-a-pepper-correctly-to-bcrypt
  Future<void> generateHash(String password) async {
    _salt = await FlutterBcrypt.salt();
    _hash =
        await FlutterBcrypt.hashPw(password: password + _pepper, salt: _salt);
  }

  /// Attempts to log [_User] in with [password].
  ///
  /// An [AuthException] is thrown if [password] is incorrect,
  /// [_unsuccessfulLoginAttempts] has reached [_maxLoginAttempts], or Face or
  /// Touch ID is incorrect.
  ///
  /// Face or Touch ID is used to simulate two-factor authentication, and is
  /// only used if either are enabled on the device.
  ///
  /// If login is successful, [generateHash] with [password] is called.
  Future<void> login(String password) async {
    if (_unsuccessfulLoginAttempts >= _maxLoginAttempts) {
      throw AuthException(
          "Account with username '$username' has been locked due to too many unsuccessful login attempts.");
    }

    await _checkBiometrics();

    // Same procedure as generateHash but without storage.
    final hash =
        await FlutterBcrypt.hashPw(password: password + _pepper, salt: _salt);
    if (_hash == hash) {
      _unsuccessfulLoginAttempts = 0;
      await generateHash(password);
    } else {
      _unsuccessfulLoginAttempts++;
      final attemptsLeft = _maxLoginAttempts - _unsuccessfulLoginAttempts;
      throw AuthException('Could not log in. '
          '${attemptsLeft > 0 ? '$attemptsLeft login attempt${attemptsLeft != 1 ? 's' : ''} left.' : "Account with username '$username' has been locked."}');
    }
  }
}

/// Common [username] and [password] condition checks across [enrol] and
/// [verify].
///
/// If [username] or [password] fail a condition, an [AuthException] is thrown.
void _checkGenericCredentialConditions(String username, String password) {
  // Checks if username is empty.
  if (username.isEmpty) {
    throw AuthException('Username cannot be empty.');
  }

  // Checks if the username length is over 32.
  // Arbitrary small username length limit for greater user experience.
  if (username.length > 32) {
    throw AuthException('Username cannot be more than 32 characters long.');
  }

  // Checks if the username contains characters outside of a-z, A-Z, 0-9, or _.
  if (RegExp('[^a-zA-Z0-9_]').hasMatch(username)) {
    throw AuthException(
        'Username can only contain upper or lowercase letters, `whole numbers, or underscores.');
  }

  // Checks if the password length is below 8.
  if (password.length < 8) {
    throw AuthException('Password must be at least 8 characters long.');
  }

  // Checks if the password length is above 64.
  if (password.length > 64) {
    throw AuthException(
        'Password is above the maximum length of 64 characters.');
  }
}

/// Attempts to create a new [_User] based on [username] and [password].
///
/// If successful, adds it to [_users].
///
/// If [username] or [password] fail a condition, an [AuthException] is thrown.
Future<void> enrol(String username, String password) async {
  // Checks username and password conditions which are also checked within
  // verify.
  _checkGenericCredentialConditions(username, password);

  // Checks if a user with the same username exists.
  if (_users.indexWhere(
          (e) => e.username.toLowerCase() == username.toLowerCase()) !=
      -1) {
    throw AuthException("User with username '$username' already exists.");
  }

  // Checks if the username contains profanity.
  final profanity = getProfanity(username);
  if (profanity != null) {
    throw AuthException(
        "Username cannot contain profanity. Found '$profanity'.");
  }

  // Checks if the password is contained within the top ten million most common
  // passwords.
  if (isCommon(password)) {
    throw AuthException(
        "Password '$password' is too common. Please enter a more secure password.");
  }

  // Checks Face or Touch ID if enabled on the device.
  await _checkBiometrics();

  // Adds a new [_User] with username and generates it a hash with password.
  final user = (_users..add(_User(username: username))).last;
  await user.generateHash(password);
}

/// Attempts to log a user in with [username] and [password].
///
/// If [username] or [password] fail a condition, an [AuthException] is thrown.
Future<void> verify(String username, String password) async {
  // Checks username and password conditions which are also checked within
  // enrol.
  _checkGenericCredentialConditions(username, password);

  // Finds the _User with username, and checks if a _User with username does not
  // exist.
  final user = _users.firstWhere(
    (e) => e.username == username,
    orElse: () =>
        throw AuthException("Could not find user with username '$username'."),
  );

  // Attempts to log the _User in.
  return user.login(password);
}

/// Returns a [List] of [List] containing each [_User] within [_users] data.
List<List<String>> getUserData() {
  return _users
      .map((e) => [e._id.toString(), e.username, e._salt, e._hash].toList())
      .toList()
    ..insert(0, [
      'ID',
      'Username',
      'Salt',
      'Hash',
    ]);
}
