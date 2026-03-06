import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1B8E5A),
      brightness: Brightness.light,
    ),

    scaffoldBackgroundColor: const Color(0xFFF4F7FA),

    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),

    cardTheme: const CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
  );
}
