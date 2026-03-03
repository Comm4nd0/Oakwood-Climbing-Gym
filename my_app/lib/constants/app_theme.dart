import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF2E7D32);
  static const Color secondaryColor = Color(0xFF455A64);
  static const Color accentColor = Color(0xFFFF8F00);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
  static const Color errorColor = Color(0xFFD32F2F);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: secondaryColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: const CardTheme(
      color: cardColor,
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accentColor,
      foregroundColor: Colors.white,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
    ),
  );
}
