import 'dart:convert';

class URF8 {
  static String decodeUtf8(String? text) {
    if (text == null) return '';
    return utf8.decode(text.runes.toList());
  }
}