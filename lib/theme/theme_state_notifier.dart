import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme_preferences.dart';

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(false) {
    getPreferences();
  }

  final ThemePreferences _preferences = ThemePreferences();

//Switching themes in the flutter apps - Flutterant
  setTheme(bool value) {
    state = value;
    _preferences.setTheme(value);
  }

  getPreferences() async {
    state = await _preferences.getTheme();
  }
}

final themeProvider =
    StateNotifierProvider<ThemeNotifier, bool>((ref) => ThemeNotifier());
