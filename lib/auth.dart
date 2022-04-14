import 'package:engen518_assignment1/word_lists.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_bcrypt/flutter_bcrypt.dart';

late final bool _canCheckBiometrics;
final _localAuth = LocalAuthentication();

const _pepper =
    '64charlongpepper64charlongpepper64charlongpepper64charlongpepper64charlongpepper64charlongpepper';

/// Adapted custom Exception solution from: https://stackoverflow.com/questions/13579982/how-to-create-a-custom-exception-and-handle-it-in-dart
class AuthException implements Exception {
  final String cause;
  AuthException(this.cause);

  @override
  String toString() {
    return cause;
  }
}

class _User {
  final String username;
  late String _salt, _hash;

  _User({required this.username});

  Future<void> generateHash(String password) async {
    _salt = await FlutterBcrypt.salt();
    final saltAndPepper = _salt + _pepper;

    _hash = await FlutterBcrypt.hashPw(password: password, salt: saltAndPepper);
  }

  Future<void> login(String password) async {
    final saltAndPepper = _salt + _pepper;
    final hash =
        await FlutterBcrypt.hashPw(password: password, salt: saltAndPepper);
    if (_hash == hash) {
      generateHash(password);
    } else {
      throw AuthException('Could not log in.');
    }
  }
}

final _users = List<_User>.empty(growable: true);

Future<void> initAuth() async {
  _canCheckBiometrics = await _localAuth.canCheckBiometrics;
}

// Password guidelines from NIST 800-63b summary: https://www.netsec.news/summary-of-the-nist-password-recommendations-for-2021/
Future<void> enrol(String username, String password) async {
  if (RegExp('[^a-zA-Z0-9_]').hasMatch(username)) {
    throw AuthException(
        'Username can only contain upper or lowercase letters, `whole numbers, or underscores.');
  }

  final profanity = getProfanity(username);
  if (profanity != null) {
    throw AuthException(
        "Username cannot contain profanity. Found '$profanity'.");
  }

  // TODO: Add username and password conditions.
  if (_users.indexWhere(
          (e) => e.username.toLowerCase() == username.toLowerCase()) !=
      -1) {
    throw AuthException("User with username '$username' already exists.");
  }

  if (password.length > 64) {
    throw AuthException(
        'Password is above the maximum length of 64 characters.');
  }

  if (isCommon(password)) {
    throw AuthException("Password '$password' is too common. Please enter a more secure password.");
  }

  if (_canCheckBiometrics &&
      !await _localAuth.authenticate(
          localizedReason: 'Please authenticate with your face or fingerprint.',
          biometricOnly: true)) {
    throw AuthException('Could not recognise your face or fingerprint.');
  }

  final user = (_users..add(_User(username: username))).last;
  await user.generateHash(password);
}

Future<void> verify(String username, String password) async {
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
