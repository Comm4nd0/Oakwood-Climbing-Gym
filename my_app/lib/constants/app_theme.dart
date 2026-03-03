import 'package:flutter/material.dart';

class AppTheme {
  // Oakwood Climbing Centre brand palette
  // Inspired by the climbing wall colors — a bright, kid-friendly palette
  // balanced with clean white space (designed by The Creative Donut)
  static const Color primaryColor = Color(0xFF00897B);     // Teal (main brand)
  static const Color primaryDark = Color(0xFF00695C);      // Dark teal
  static const Color secondaryColor = Color(0xFFF57C00);   // Vibrant orange (accent)
  static const Color accentYellow = Color(0xFFFFCA28);     // Bright yellow
  static const Color accentPink = Color(0xFFEC407A);       // Playful pink
  static const Color accentBlue = Color(0xFF42A5F5);       // Bright blue
  static const Color backgroundColor = Color(0xFFFAFAFA);  // Clean white
  static const Color surfaceColor = Colors.white;
  static const Color textPrimary = Color(0xFF263238);       // Dark charcoal
  static const Color textSecondary = Color(0xFF607D8B);     // Blue grey
  static const Color errorColor = Color(0xFFD32F2F);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      error: errorColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardTheme(
      color: surfaceColor,
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: secondaryColor,
      foregroundColor: Colors.white,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: primaryColor,
      unselectedItemColor: textSecondary,
      backgroundColor: Colors.white,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: primaryColor.withOpacity(0.1),
      labelStyle: const TextStyle(color: primaryColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}
