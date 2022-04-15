import 'package:flutter/material.dart';

/// Creates the base [Scaffold] for each page. Used for code reduction and
/// consistency.
class ThemedScaffold extends StatelessWidget {
  final Widget? body;

  const ThemedScaffold({Key? key, this.body}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: body,
    );
  }
}
