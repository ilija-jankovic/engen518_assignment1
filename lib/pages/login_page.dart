import 'package:engen518_assignment1/bloc/auth.dart';
import 'package:engen518_assignment1/pages/credential_page.dart';
import 'package:engen518_assignment1/widgets/themed_scaffold.dart';
import 'package:flutter/material.dart';

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

  Future<void> _handleSubmission(BuildContext context,
      Future<void> Function(String, String) onSubmitted) async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CredentialPage(onSubmitted: onSubmitted)));
  }

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
