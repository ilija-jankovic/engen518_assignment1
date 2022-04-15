import 'package:engen518_assignment1/pages/login_page.dart';
import 'package:engen518_assignment1/bloc/word_lists.dart';
import 'package:engen518_assignment1/bloc/auth.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initAuth();
  await initWordLists();
  runApp(const MaterialApp(home: HomePage()));
}
