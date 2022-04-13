import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_bcrypt/flutter_bcrypt.dart';

late final bool _canCheckBiometrics;
final _localAuth = LocalAuthentication();

const _pepper =
    '64charlongpepper64charlongpepper64charlongpepper64charlongpepper64charlongpepper64charlongpepper';

/// Solution from: https://stackoverflow.com/questions/61919395/how-to-generate-random-string-in-dart
String _generateRandomString(int len) {
  var r = Random();
  return String.fromCharCodes(
      List.generate(len, (index) => r.nextInt(33) + 89));
}

class _User {
  final String username;
  late String _salt, _hash;

  _User({required this.username});

  Future<void> generateHash(String password) async {
    _salt = _generateRandomString(64);
    final saltAndPepper = _salt + _pepper;
    _hash = await FlutterBcrypt.hashPw(password: password, salt: saltAndPepper);
  }

  Future<bool> login(String password) async {
    final saltAndPepper = _salt + _pepper;
    final hash =
        await FlutterBcrypt.hashPw(password: password, salt: saltAndPepper);
    if (_hash == hash) {
      generateHash(password);
      return true;
    } else {
      return false;
    }
  }
}

final _users = List<_User>.empty(growable: true);

Future<void> initAuth() async {
  _canCheckBiometrics = await _localAuth.canCheckBiometrics;
}

Future<void> enrol(String username, String password) async {
  if (_canCheckBiometrics &&
      !await _localAuth.authenticate(
          localizedReason: 'Please authenticate with your face or fingerprint.',
          biometricOnly: true)) {
    throw 'Could not recognise your face or fingerprint. Please try again.';
  }

  // TODO: Add username and password conditions.

  final user = _User(username: username);
  await user.generateHash(password);
}

Future<bool> verify(String username, String password) async {
  final user = _users.firstWhere(
    (e) => e.username == username,
    orElse: () => throw 'Could not find user with username $username.',
  );
  return user.login(password);
}
