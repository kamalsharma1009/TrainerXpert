import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    primaryColor: const Color(0xFF2E3A59),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF2E3A59),
      secondary: Color(0xFFF5A623),
      surface: Color(0xFFF8F9FA),
    ),
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF2E3A59),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: Color(0xFF2E3A59),
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),
      bodyLarge: TextStyle(color: Color(0xFF2E3A59), fontSize: 16),
    ),
  );

  static final darkTheme = ThemeData(
    primaryColor: const Color(0xFF1A2335),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF1A2335),
      secondary: Color(0xFFF5A623),
      surface: Color(0xFF121212),
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1A2335),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFF1E1E1E),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),
      bodyLarge: TextStyle(color: Colors.white70, fontSize: 16),
    ),
  );
}
