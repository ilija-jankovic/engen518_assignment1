import 'package:engen518_assignment1/bloc/auth.dart';
import 'package:engen518_assignment1/pages/credential_page.dart';
import 'package:engen518_assignment1/widgets/themed_scaffold.dart';
import 'package:flutter/material.dart';

/// Page for navigation to Enrolment or Verification, or to display private user
/// data for debugging purposes.
///
/// Private user data should not be shown in a real application, this is just a
/// proof-of-concept.
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

  /// Pushes a [CredentialPage] object with [onSubmitted] on the [Navigator]
  /// stack.
  Future<void> _handleSubmission(BuildContext context,
      Future<void> Function(String, String) onSubmitted) async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CredentialPage(onSubmitted: onSubmitted)));
  }

  /// Returns a [Column] of 'Sign In', 'Sign Up', and 'Display Private User
  /// Data' [ElevatedButton]s.
  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _createButton('Sign In', () => _handleSubmission(context, verify)),
        _createButton('Sign Up', () => _handleSubmission(context, enrol)),
        _createButton('Display Private User Data', () {
          final data = getUserData();
          final dialog = AlertDialog(
              title: const Text('Private User Data'),
              content: SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    // Displays private user data in a formatted style.
                    children: data
                        .map((e) => FittedBox(
                            child: Container(
                                color: data.indexOf(e) % 2 == 0
                                    ? Colors.white
                                    : Colors.grey[200],
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: e
                                        .map((e) => SizedBox(
                                            height: 50,
                                            width: 200,
                                            child: Text(e)))
                                        .toList()))))
                        .toList()),
              ));
          showDialog(context: context, builder: (context) => dialog);
        })
      ],
    ));
  }
}
