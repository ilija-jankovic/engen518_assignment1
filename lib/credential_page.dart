import 'package:engen518_assignment1/themed_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CredentialPage extends StatelessWidget {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final void Function(String username, String password) onSubmitted;

  CredentialPage({Key? key, required this.onSubmitted}) : super(key: key);

  Widget _createTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
          controller: controller,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9_]'))
          ],
          decoration: InputDecoration(label: Text(label))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _createTextField(_usernameController, 'Username'),
        _createTextField(_passwordController, 'Password'),
        ElevatedButton(
            onPressed: (() => onSubmitted(
                _usernameController.text, _passwordController.text)),
            child: const Text('Submit'))
      ],
    ));
  }
}
