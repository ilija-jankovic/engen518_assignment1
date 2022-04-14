import 'package:engen518_assignment1/themed_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class _PasswordInput extends StatefulWidget {
  final TextEditingController controller;
  const _PasswordInput({Key? key, required this.controller}) : super(key: key);

  @override
  State<_PasswordInput> createState() => __PasswordInputState();
}

class __PasswordInputState extends State<_PasswordInput> {
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return TextField(
        obscureText: !_passwordVisible,
        controller: widget.controller,
        maxLength: 64,
        maxLines: 1,
        decoration: InputDecoration(
            label: const Text('Password'),
            suffixIcon: IconButton(
                onPressed: () =>
                    setState(() => _passwordVisible = !_passwordVisible),
                icon: Icon(
                  _passwordVisible
                      ? Icons.remove_red_eye_outlined
                      : Icons.remove_red_eye_rounded,
                ))));
  }
}

class CredentialPage extends StatelessWidget {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final void Function(String username, String password) onSubmitted;

  CredentialPage({Key? key, required this.onSubmitted}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                    controller: _usernameController,
                    maxLines: 1,
                    maxLength: 32,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9_]'))
                    ],
                    decoration: const InputDecoration(label: Text('Username'))),
                _PasswordInput(controller: _passwordController),
                ElevatedButton(
                    onPressed: (() => onSubmitted(
                        _usernameController.text, _passwordController.text)),
                    child: const Text('Submit'))
              ],
            )));
  }
}
