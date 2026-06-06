import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const _themeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    final storedValue = preferences.getString(_themeKey);
    _themeMode = switch (storedValue) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _themeKey,
      _themeMode == ThemeMode.dark ? 'dark' : 'light',
    );
    notifyListeners();
  }
}
