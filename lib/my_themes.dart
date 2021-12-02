import 'package:flutter/material.dart';

class MyThemes {
  static final darkTheme = ThemeData(
      scaffoldBackgroundColor: Colors.grey.shade900,
      primaryColor: Colors.black,
      colorScheme: ColorScheme.dark(),
      dividerColor: Colors.white,
      // appBarTheme: AppBarTheme()
      iconTheme: IconThemeData(color: Colors.purple.shade200, opacity: 0.8));
  static final lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    primaryColor: Colors.white,
    dividerColor: Colors.black,
    colorScheme: ColorScheme.light(),
  );
}
