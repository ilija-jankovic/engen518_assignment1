import 'package:engen518_assignment1/pages/home_page.dart';
import 'package:engen518_assignment1/bloc/word_lists.dart';
import 'package:engen518_assignment1/bloc/auth.dart';
import 'package:flutter/material.dart';

/// Initalises authentication parameters and word lists, and creates a
/// [HomePage] object as the [MaterialApp]'s root.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initAuth();
  await initWordLists();
  runApp(const MaterialApp(home: HomePage()));
}
