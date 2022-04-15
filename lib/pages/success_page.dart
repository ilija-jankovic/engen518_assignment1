import 'package:engen518_assignment1/widgets/themed_scaffold.dart';
import 'package:flutter/material.dart';

/// Shown on successful Enrolment or Verification.
class SuccessPage extends StatelessWidget {
  const SuccessPage({Key? key}) : super(key: key);

  // Returns a success message.
  @override
  Widget build(BuildContext context) {
    return const ThemedScaffold(
        body: Center(
            child: Text(
      'You have successfully logged in.\nWelcome!',
      textAlign: TextAlign.center,
    )));
  }
}
