import 'package:flutter/material.dart';

class AppTheme {
// Primary color - healthcare green
static const Color primaryGreen = Color(0xFF1B8E5A);
static const Color lightGreen = Color(0xFFE8F5E9);
static const Color darkGreen = Color(0xFF0D5F3E);

// Status colors
static const Color highRiskRed = Color(0xFFDC3545);
static const Color mediumRiskOrange = Color(0xFFFFC107);
static const Color lowRiskGreen = Color(0xFF28A745);

// Neutral colors
static const Color lightBg = Color(0xFFF4F7FA);
static const Color cardBg = Color(0xFFFFFFFF);
static const Color textPrimary = Color(0xFF212121);
static const Color textSecondary = Color(0xFF757575);

static ThemeData lightTheme = ThemeData(
useMaterial3: true,
scaffoldBackgroundColor: lightBg,


colorScheme: ColorScheme.fromSeed(
  seedColor: primaryGreen,
  brightness: Brightness.light,
  primary: primaryGreen,
  secondary: const Color(0xFF00BCD4),
  surface: cardBg,
  error: highRiskRed,
),

// 🔥 AppBar
appBarTheme: const AppBarTheme(
  centerTitle: true,
  elevation: 0,
  backgroundColor: primaryGreen,
  foregroundColor: Colors.white,
  titleTextStyle: TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.w600,
  ),
),

// 🔥 FIXED CARD THEME (Material 3)
cardTheme: CardThemeData(
  elevation: 6,
  shadowColor: Colors.black12,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(18),
  ),
  color: cardBg,
),

// 🔥 INPUT FIELDS (NO OVERLAP)
inputDecorationTheme: InputDecorationTheme(
  filled: true,
  fillColor: Colors.white,
  contentPadding: const EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 18,
  ),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(color: primaryGreen, width: 2),
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(color: highRiskRed),
  ),
  hintStyle: const TextStyle(color: textSecondary),
),

// 🔥 BUTTONS
elevatedButtonTheme: ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    backgroundColor: primaryGreen,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(
      horizontal: 24,
      vertical: 16,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
    elevation: 3,
  ),
),

// 🔥 FAB
floatingActionButtonTheme: const FloatingActionButtonThemeData(
  backgroundColor: primaryGreen,
  foregroundColor: Colors.white,
  elevation: 6,
),

// 🔥 TEXT
textTheme: const TextTheme(
  headlineLarge: TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: textPrimary,
  ),
  headlineMedium: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  ),
  titleLarge: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  ),
  bodyLarge: TextStyle(
    fontSize: 16,
    color: textPrimary,
  ),
  bodyMedium: TextStyle(
    fontSize: 14,
    color: textSecondary,
  ),
),

// 🔥 CHIP
chipTheme: ChipThemeData(
  backgroundColor: lightGreen,
  selectedColor: primaryGreen,
  labelStyle: const TextStyle(color: textPrimary),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  ),
),


);
}
