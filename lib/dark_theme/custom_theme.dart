import 'package:flutter/material.dart';
import 'package:nutri_tracker/themes/app_theme.dart';

CustomTheme currentTheme = CustomTheme();

class CustomTheme with ChangeNotifier {
  static bool _isDarkTheme = false;
  static bool _isSystemTheme = false;
  ThemeMode get currentTheme => _isDarkTheme ? ThemeMode.dark : ThemeMode.light;
  bool isDarkTheme() {
    if (_isDarkTheme) return true;
    return false;
  }

  void toggleTheme() {
    _isDarkTheme = !_isDarkTheme;
    notifyListeners();
  }

  static ThemeData get lightTheme {
    return AppTheme.light;
  }

  static ThemeData get darkTheme {
    return AppTheme.dark;
  }
}
