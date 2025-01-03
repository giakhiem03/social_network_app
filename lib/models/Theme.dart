import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  Color _theme = Colors.white10;

  Color get theme => _theme;

  Color _text = Colors.white70;

  Color get textColor => _text;

  Color _textFeel = Colors.white38;

  Color get textFeel => _textFeel;


  Color _textFullName= Colors.black87;

  Color get textFullName => _textFullName;

  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  Color _textProfile= Colors.white70;

  Color get textProfile => _textProfile;

  Color _textPost = Colors.white70;

  Color get textPost => _textPost;

  changeTheme(bool mode) {
    _isDarkMode = mode;

    if(mode) {
      _theme = Colors.white10;
      _text =  Colors.white70;
      _textFeel = Colors.white38;
      _textFullName = Colors.black87;
      _textProfile = Colors.white70;
      _textPost = Colors.white70;
    } else {
      _theme =  Colors.white;
      _text =  Colors.black;
      _textFeel = Colors.black87;
      _textFullName = Colors.white70;
      _textProfile = Colors.white;
      _textPost = Colors.black87;
    }
    notifyListeners();
  }


}