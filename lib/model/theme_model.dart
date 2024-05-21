//theme_model.dart
import 'package:flutter/material.dart';
import '../services/theme_preferences.dart';

class ThemeModel with ChangeNotifier {
  bool _isDark = false;
  final ThemePreferences _preferences = ThemePreferences();
  bool get isDark => _isDark;

  ThemeModel() {
    getPreferences();
  }

//Switching themes in the flutter apps - Flutterant
  set isDark(bool value) {
    _isDark = value;
    _preferences.setTheme(value);
    notifyListeners();
  }

  getPreferences() async {
    _isDark = await _preferences.getTheme();
    notifyListeners();
  }
}
//Switching themes in the flutter apps - Flutterant
