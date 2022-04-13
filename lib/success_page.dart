import 'package:engen518_assignment1/themed_scaffold.dart';
import 'package:flutter/material.dart';

class SuccessPage extends StatelessWidget {
  const SuccessPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ThemedScaffold(
        body: Text('You have sucessfully been logged in.\nWelcome!'));
  }
}
