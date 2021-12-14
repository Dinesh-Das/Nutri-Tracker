import 'package:flutter/material.dart';
import 'package:nutri_tracker/dark_theme/themes.dart';

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
    return ThemeData(
        colorScheme: const ColorScheme.light(),
        scaffoldBackgroundColor: Colors.white,
        primaryColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: appBarBackground,
          foregroundColor: appBarTextColor,
        ),
        primaryColorDark: drawerColor,
        //back color bottom bar
        bottomAppBarColor: bottomNavigationForeground,
        backgroundColor: bottomNavigationBackground,
        iconTheme: IconThemeData(color: Colors.red, opacity: 0.8));
  }

  static ThemeData get darkTheme {
    return ThemeData(
      colorScheme: const ColorScheme.dark(),
      scaffoldBackgroundColor: Colors.black,
      primaryColor: Colors.black,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF4A4E69),
        foregroundColor: Color(0XFFF2E9E4),
      ),

      //back color bottom bar
      bottomAppBarColor: Color(0XFF6d6875),
      backgroundColor: Color(0xFF4A4E69),
      iconTheme: IconThemeData(color: Color(0xffe0aaff), opacity: 0.8),
      selectedRowColor: Colors.blue,
    );
  }
}
