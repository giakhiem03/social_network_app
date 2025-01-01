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


  Color _textProfile= Colors.black87;

  Color get textProfile => _textProfile;

  changeTheme(bool mode) {
    if(mode) {
      _theme = Colors.white10;
      _text =  Colors.white70;
      _textFeel = Colors.white38;
      _textFullName = Colors.black87;
      _textProfile = Colors.white70;
    } else {
      _theme =  Colors.white;
      _text =  Colors.black;
      _textFeel = Colors.black87;
      _textFullName = Colors.white70;
      _textProfile = Colors.white;
    }

    notifyListeners();
  }

}