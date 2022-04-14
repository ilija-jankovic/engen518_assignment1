import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

/// Profanity JSON list from: https://github.com/zacanger/profane-words
/// Includes number substitutions for letters.
///
/// Common password list from: https://github.com/danielmiessler/SecLists/tree/master/Passwords/Common-Credentials

late List<String> _profanityList, _commonPasswords;

Future<void> initWordLists() async {
  var data = await rootBundle.loadString('assets/profanity_list.json');
  _profanityList = (jsonDecode(data) as List).cast<String>();
  _commonPasswords = File('assets/10-million-password-list-top-1000000.txt')
      .readAsStringSync()
      .split('\n');
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
