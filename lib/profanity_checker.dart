import 'dart:convert';

import 'package:flutter/services.dart';

/// Profanity JSON list from: https://github.com/zacanger/profane-words
/// Includes number substitutions for letters.

late List<String> _profanityList;

Future<void> initProfanityChecker() async {
  final data = await rootBundle.loadString('assets/profanity_list.json');
  _profanityList = (jsonDecode(data) as List).cast<String>();
}

String? getProfanity(String text) {
  text = text.toLowerCase();
  for (final word in _profanityList) {
    if (text.contains(word)) {
      return word;
    }
  }
  return null;
}
