/// Profanity JSON list from: https://github.com/zacanger/profane-words
/// Includes number substitutions for letters.
///
/// Common password list from: https://github.com/danielmiessler/SecLists/tree/master/Passwords/Common-Credentials

import 'dart:convert';
import 'package:flutter/services.dart';

/// [List] containing profane words, including number substitutions for
/// similarly shaped letters.
late List<String> _profanityList;

/// [List] containing top ten million common passwords.
late List<String> _commonPasswords;

/// Retrieves and captures data for [_profanityList] and [_commonPasswords].
///
/// Relevant files are found under /assets/.
Future<void> initWordLists() async {
  var data = await rootBundle.loadString('assets/profanity_list.json');
  _profanityList = (jsonDecode(data) as List).cast<String>();
  data = await rootBundle
      .loadString('assets/10-million-password-list-top-1000000.txt');
  _commonPasswords = data.split('\n');
}

/// Returns first profane word found within [text].
String? getProfanity(String text) {
  text = text.toLowerCase();
  for (final word in _profanityList) {
    if (text.contains(word)) {
      return word;
    }
  }
  return null;
}

/// Checks if [password] is within [_commonPasswords].
bool isCommon(String password) {
  return _commonPasswords.contains(password);
}
