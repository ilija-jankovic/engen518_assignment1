import 'package:engen518_assignment1/credential_page.dart';
import 'package:engen518_assignment1/themed_scaffold.dart';
import 'package:engen518_assignment1/auth.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initAuth();
  runApp(const MaterialApp(home: LoginPage()));
}

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  Widget _createButton(String label, void Function() onPressed) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(children: [
          Expanded(
              child: ElevatedButton(onPressed: onPressed, child: Text(label)))
        ]));
  }

  void _showErrorSnackBar(BuildContext context, String error) {
    ScaffoldMessenger.of(context).clearSnackBars();
    final snackBar = SnackBar(content: Text(error));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _handleSubmission(BuildContext context,
      Future<void> Function(String, String) function) async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CredentialPage(
                  onSubmitted: (username, password) async {
                    try {
                      await function(username, password);
                    } on AuthException catch (e) {
                      _showErrorSnackBar(context, e.toString());
                    } catch (e) {
                      _showErrorSnackBar(context,
                          'Something went wrong internally. Please try again.');
                      debugPrint(e.toString());
                    }
                  },
                )));
  }

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _createButton('Sign In', () => _handleSubmission(context, verify)),
        _createButton('Sign Up', () => _handleSubmission(context, enrol)),
        _createButton('Display Private User Data', () {})
      ],
    ));
  }
}
