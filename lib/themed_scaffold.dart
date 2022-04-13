import 'package:flutter/material.dart';

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
