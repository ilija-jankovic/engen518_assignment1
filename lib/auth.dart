/// Password guidelines from NIST 800-63b summaries:
/// https://www.netsec.news/summary-of-the-nist-password-recommendations-for-2021/
/// https://www.auditboard.com/blog/nist-password-guidelines/

import 'package:engen518_assignment1/word_lists.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_bcrypt/flutter_bcrypt.dart';

late final bool _canCheckBiometrics;
final _localAuth = LocalAuthentication();

// Pepper is over 112 bits as suggested by NIST.
const _pepper = 'donthackmedonthackmedonthackmedonthackmedonthackmedonthackme';

/// Adapted custom Exception solution from: https://stackoverflow.com/questions/13579982/how-to-create-a-custom-exception-and-handle-it-in-dart
class AuthException implements Exception {
  final String cause;
  AuthException(this.cause);

  @override
  String toString() {
    return cause;
  }
}

Future<void> _checkBiometrics() async {
  if (_canCheckBiometrics &&
      !await _localAuth.authenticate(
          localizedReason: 'Please authenticate with your face or fingerprint.',
          biometricOnly: true)) {
    throw AuthException('Could not recognise your face or fingerprint.');
  }
}

class _User {
  final String username;
  late String _salt, _hash;
  int unsuccessfulLoginAttempts = 0;
  static const maxLoginAttempts = 3;

  _User({required this.username});

  Future<void> generateHash(String password) async {
    _salt = await FlutterBcrypt.salt();
    final saltAndPepper = _salt + _pepper;

    _hash = await FlutterBcrypt.hashPw(password: password, salt: saltAndPepper);
  }

  Future<void> login(String password) async {
    if (unsuccessfulLoginAttempts >= maxLoginAttempts) {
      throw AuthException(
          "Account with username '$username' has been locked due to too many unsuccessful login attempts.");
    }

    await _checkBiometrics();

    final saltAndPepper = _salt + _pepper;
    final hash =
        await FlutterBcrypt.hashPw(password: password, salt: saltAndPepper);
    if (_hash == hash) {
      unsuccessfulLoginAttempts = 0;
      await generateHash(password);
    } else {
      unsuccessfulLoginAttempts++;
      final attemptsLeft = maxLoginAttempts - unsuccessfulLoginAttempts;
      throw AuthException('Could not log in. '
          '${attemptsLeft > 0 ? '$attemptsLeft login attempt${attemptsLeft != 1 ? 's' : ''} left.' : "Account with username '$username' has been locked."}');
    }
  }
}

final _users = List<_User>.empty(growable: true);

Future<void> initAuth() async {
  _canCheckBiometrics = await _localAuth.canCheckBiometrics;
}

void _checkGenericCredentialConditions(String username, String password) {
  if (username.isEmpty) {
    throw AuthException('Username cannot be empty.');
  }

  // Arbitrary usernmae limit for greater user experience.
  if (username.length > 32) {
    throw AuthException('Username cannot be more than 32 characters long.');
  }

  if (RegExp('[^a-zA-Z0-9_]').hasMatch(username)) {
    throw AuthException(
        'Username can only contain upper or lowercase letters, `whole numbers, or underscores.');
  }

  if (password.length < 8) {
    throw AuthException('Password must be at least 8 characters long.');
  }

  if (password.length > 64) {
    throw AuthException(
        'Password is above the maximum length of 64 characters.');
  }
}

Future<void> enrol(String username, String password) async {
  _checkGenericCredentialConditions(username, password);

  if (_users.indexWhere(
          (e) => e.username.toLowerCase() == username.toLowerCase()) !=
      -1) {
    throw AuthException("User with username '$username' already exists.");
  }

  final profanity = getProfanity(username);
  if (profanity != null) {
    throw AuthException(
        "Username cannot contain profanity. Found '$profanity'.");
  }

  if (isCommon(password)) {
    throw AuthException(
        "Password '$password' is too common. Please enter a more secure password.");
  }

  await _checkBiometrics();

  final user = (_users..add(_User(username: username))).last;
  await user.generateHash(password);
}

Future<void> verify(String username, String password) async {
  _checkGenericCredentialConditions(username, password);

  final user = _users.firstWhere(
    (e) => e.username == username,
    orElse: () =>
        throw AuthException("Could not find user with username '$username'."),
  );

  return user.login(password);
}

List<List<String>> getUserData() {
  return _users.map((e) => [e.username, e._salt, e._hash].toList()).toList()
    ..insert(0, [
      'Username',
      'Salt',
      'Hash',
    ]);
}
