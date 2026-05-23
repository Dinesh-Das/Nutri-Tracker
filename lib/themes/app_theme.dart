import 'package:flutter/material.dart';
import 'package:nutri_tracker/themes/app_colors.dart';

class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryOrange,
      primary: AppColors.primaryOrange,
      secondary: AppColors.accentGreen,
      surface: AppColors.cardLight,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: scheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: const CardTheme(
        color: AppColors.cardLight,
        elevation: 1,
        margin: EdgeInsets.all(8),
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: AppColors.primaryOrange.withOpacity(0.15),
      ),
    );
  }

  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryOrange,
      primary: AppColors.primaryOrange,
      secondary: AppColors.accentGreen,
      surface: AppColors.cardDark,
      brightness: Brightness.dark,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: scheme.surface,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: const CardTheme(
        color: AppColors.cardDark,
        elevation: 1,
        margin: EdgeInsets.all(8),
      ),
    );
  }
}
