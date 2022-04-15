import 'dart:async';

import 'package:engen518_assignment1/bloc/auth.dart';
import 'package:engen518_assignment1/pages/success_page.dart';
import 'package:engen518_assignment1/widgets/themed_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Password TextField with optional obscurity and a max character limit of 64.
class _PasswordInput extends StatefulWidget {
  /// Password [TextField] within [_PasswordInputState] uses this to allow
  /// retrieval of the password [String] externally.
  final TextEditingController controller;
  const _PasswordInput({Key? key, required this.controller}) : super(key: key);

  @override
  State<_PasswordInput> createState() => _PasswordInputState();
}

/// The state for [_PasswordInput].
///
/// Statefulness is required for visiblity toggle ability.
class _PasswordInputState extends State<_PasswordInput> {
  /// Controls whether to obsure the relevant [TextField] when called with
  /// [setState].
  bool _passwordVisible = false;

  /// Returns a [TextField] with a toggleable eye [Icon] suffix.
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

/// A page containing username and password inputs, and a custom handler on
/// submission.
class CredentialPage extends StatelessWidget {
  /// Controls username input inside the relevant [TextField].
  final _usernameController = TextEditingController();

  /// Controls password input inside the relevant [_PasswordInput].
  final _passwordController = TextEditingController();

  /// The callback fired on credential submission.
  ///
  /// Intended to be intialised with [enrol] or [verify].
  final Future<void> Function(String username, String password) onSubmitted;

  CredentialPage({Key? key, required this.onSubmitted}) : super(key: key);

  /// Removes any existing [SnackBar] within the current [Scaffold], and
  /// displays a new one with a [Text] object containing [error].
  void _showErrorSnackBar(BuildContext context, String error) {
    ScaffoldMessenger.of(context).clearSnackBars();
    final snackBar = SnackBar(content: Text(error));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Creates a non-dismissible loading [AlertDialog], returning a [Future] with
  /// its [BuildContext].
  ///
  /// This [Future] is completed when [showDialog] begins building the
  /// [AlertDialog].
  Future<BuildContext> _showLoadingDialog(BuildContext context) {
    FocusScope.of(context).unfocus();
    final dialog = AlertDialog(
      content:
          Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
        Padding(
            padding: EdgeInsets.only(right: 24.0),
            child: CircularProgressIndicator()),
        Text('Loading (bcrypt is very slow)...')
      ]),
    );

    final completer = Completer<BuildContext>();
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          completer.complete(context);
          return dialog;
        });

    return completer.future;
  }

  /// Handles credential submission.
  ///
  /// If [onSubmitted] does not throw an error, a [SuccessPage] object is pushed
  /// onto the [Navigator] stack.
  ///
  /// If [onSubmitted] throws an [AuthException] error, it means credential
  /// conditions have not been met. An error [SnackBar] will be shown to verify
  /// the user on which condition was broken.
  ///
  /// If [onSubmitted] throws a different [Exception], the user will be informed
  /// that something went wrong internally.
  ///
  /// [onSubmitted] is expected to process for at least a few seconds. A loading
  /// [AlertDialog] will be shown during processing, and closed on success or
  /// [Exception] thrown.
  Future<void> _onSubmitted(BuildContext context) async {
    final dialogContext = await _showLoadingDialog(context);
    try {
      await onSubmitted(_usernameController.text, _passwordController.text);
      Navigator.of(dialogContext).pop();
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const SuccessPage()));
    } on AuthException catch (e) {
      Navigator.of(dialogContext).pop();
      _showErrorSnackBar(context, e.toString());
    } catch (e) {
      Navigator.of(dialogContext).pop();
      _showErrorSnackBar(
          context, 'Something went wrong internally. Please try again.');
      debugPrint(e.toString());
    }
  }

  /// Returns credential input fields, alongside error and success handling upon
  /// submission.
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
                      // Username input is restricted to only allow for
                      // characters within the following pattern:
                      // [a-zA-Z0-9_]
                      FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9_]'))
                    ],
                    decoration: const InputDecoration(label: Text('Username'))),
                _PasswordInput(controller: _passwordController),
                ElevatedButton(
                    onPressed: () => _onSubmitted(context),
                    child: const Text('Submit'))
              ],
            )));
  }
}
