import 'package:engen518_assignment1/credential_page.dart';
import 'package:engen518_assignment1/themed_scaffold.dart';
import 'package:engen518_assignment1/auth.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initAuth();
  runApp(const MaterialApp(home: HomePage()));
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  Widget _createButton(String label, void Function() onPressed) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(children: [
          Expanded(
              child: ElevatedButton(onPressed: onPressed, child: Text(label)))
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _createButton(
            'Sign In',
            () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        CredentialPage(onSubmitted: verify)))),
        _createButton(
            'Sign Up',
            () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CredentialPage(
                          onSubmitted: enrol,
                        )))),
        _createButton('Display Private User Data', () {})
      ],
    ));
  }
}
