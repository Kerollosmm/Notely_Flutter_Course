import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Light Theme Colors
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF5F5F5); // For cards, text fields
  static const Color primaryLight = Color(0xFF007AFF); // A nice blue
  static const Color onBackgroundLight = Color(0xFF000000);
  static const Color onSurfaceLight = Color(0xFF000000);
  static const Color secondaryTextLight = Color(0xFF8A8A8E); // For subtitles, hints

  // Dark Theme Colors
  static const Color backgroundDark = Color(0xFF1C1C1E);
  static const Color surfaceDark = Color(0xFF2C2C2E); // For cards, text fields
  static const Color primaryDark = Color(0xFF0A84FF); // A slightly brighter blue for dark mode
  static const Color onBackgroundDark = Color(0xFFFFFFFF);
  static const Color onSurfaceDark = Color(0xFFFFFFFF);
  static const Color secondaryTextDark = Color(0xFF8D8D93); // For subtitles, hints

  // Typography
  static final TextTheme _textTheme = TextTheme(
    headlineMedium: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold), // AppBar titles
    titleLarge: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold), // Note titles
    titleMedium: GoogleFonts.lato(fontSize: 16), // Note subtitles/body
    bodyMedium: GoogleFonts.lato(fontSize: 16),
    labelLarge: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w700), // Buttons
  );

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryLight,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: primaryLight,
        secondary: primaryLight,
        background: backgroundLight,
        surface: surfaceLight,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: onBackgroundLight,
        onSurface: onSurfaceLight,
        surfaceVariant: surfaceLight, // Used for TextField fill
        outline: Colors.grey,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: backgroundLight,
        titleTextStyle: _textTheme.headlineMedium?.copyWith(color: onBackgroundLight),
        iconTheme: const IconThemeData(color: onBackgroundLight),
      ),
      textTheme: _textTheme.apply(
        bodyColor: onBackgroundLight,
        displayColor: onBackgroundLight,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        hintStyle: TextStyle(color: secondaryTextLight),
        labelStyle: const TextStyle(color: onBackgroundLight, fontWeight: FontWeight.bold),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: primaryLight, width: 1.5),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryLight,
        foregroundColor: Colors.white,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryDark,
      scaffoldBackgroundColor: backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: primaryDark,
        secondary: primaryDark,
        background: backgroundDark,
        surface: surfaceDark,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: onBackgroundDark,
        onSurface: onSurfaceDark,
        surfaceVariant: surfaceDark, // Used for TextField fill
        outline: Colors.grey,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: backgroundDark,
        titleTextStyle: _textTheme.headlineMedium?.copyWith(color: onBackgroundDark),
        iconTheme: const IconThemeData(color: onBackgroundDark),
      ),
      textTheme: _textTheme.apply(
        bodyColor: onBackgroundDark,
        displayColor: onBackgroundDark,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        hintStyle: TextStyle(color: secondaryTextDark),
        labelStyle: const TextStyle(color: onBackgroundDark, fontWeight: FontWeight.bold),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: primaryDark, width: 1.5),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryDark,
        foregroundColor: Colors.white,
      ),
    );
  }
}
