import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Modern Color Palette
  static const Color primaryColorLight = Color(0xFF6200EE);
  static const Color primaryVariantLight = Color(0xFF3700B3);
  static const Color secondaryColorLight = Color(0xFFFBBC04); // Google Keep orange
  static const Color secondaryVariantLight = Color(0xFFE6A800); // Slightly darker orange
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color errorLight = Color(0xFFB00020);
  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color onSecondaryLight = Color(0xFF000000);
  static const Color onBackgroundLight = Color(0xFF000000);
  static const Color onSurfaceLight = Color(0xFF000000);
  static const Color onErrorLight = Color(0xFFFFFFFF);
  static const Color noteCardBackgroundLight = Color(0xFFF5F5F5); // Light grey for cards

  static const Color primaryColorDark = Color(0xFFBB86FC);
  static const Color primaryVariantDark = Color(0xFF3700B3); // Kept same as light for consistency or can be #3700B3
  static const Color secondaryColorDark = Color(0xFFFBBC04); // Google Keep orange
  static const Color backgroundDark = Color(0xFF121212); // Standard dark theme background
  static const Color surfaceDark = Color(0xFF1E1E1E); // Slightly lighter than background for cards/dialogs
  static const Color errorDark = Color(0xFFCF6679); // Standard dark theme error
  static const Color onPrimaryDark = Color(0xFF000000);
  static const Color onSecondaryDark = Color(0xFF000000);
  static const Color onBackgroundDark = Color(0xFFFFFFFF);
  static const Color onSurfaceDark = Color(0xFFFFFFFF);
  static const Color onErrorDark = Color(0xFF000000);
  static const Color noteCardBackgroundDark = Color(0xFF2A2A2A); // Darker grey for cards

  // Typography
  static final TextTheme _textTheme = TextTheme(
    displayLarge: GoogleFonts.montserrat(fontSize: 57, fontWeight: FontWeight.w300, letterSpacing: -1.5),
    displayMedium: GoogleFonts.montserrat(fontSize: 45, fontWeight: FontWeight.w300, letterSpacing: -0.5),
    displaySmall: GoogleFonts.montserrat(fontSize: 36, fontWeight: FontWeight.w400),
    headlineLarge: GoogleFonts.montserrat(fontSize: 32, fontWeight: FontWeight.w400, letterSpacing: 0.25),
    headlineMedium: GoogleFonts.montserrat(fontSize: 28, fontWeight: FontWeight.w400), // Used for AppBar titles
    headlineSmall: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.w400),
    titleLarge: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w500, letterSpacing: 0.15), // Good for card titles
    titleMedium: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.15), // Good for subtitles
    titleSmall: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
    bodyLarge: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5), // Default body text
    bodyMedium: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25), // Smaller body text
    labelLarge: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 1.25), // Buttons
    bodySmall: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4),
    labelSmall: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.w400, letterSpacing: 1.5), // Captions
  );

  static ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        primaryColor: primaryColorLight,
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: primaryColorLight,
          onPrimary: onPrimaryLight,
          primaryContainer: primaryVariantLight, // Or a lighter shade of primary
          onPrimaryContainer: onPrimaryLight,
          secondary: secondaryColorLight,
          onSecondary: onSecondaryLight,
          secondaryContainer: secondaryVariantLight, // Or a lighter shade of secondary
          onSecondaryContainer: onSecondaryLight,
          tertiary: Color(0xFF03A9F4), // Example tertiary
          onTertiary: Colors.white,
          tertiaryContainer: Color(0xFFB3E5FC),
          onTertiaryContainer: Colors.black,
          error: errorLight,
          onError: onErrorLight,
          errorContainer: Color(0xFFFFCDD2),
          onErrorContainer: Colors.black,
          background: backgroundLight,
          onBackground: onBackgroundLight,
          surface: surfaceLight,
          onSurface: onSurfaceLight,
          surfaceVariant: Color(0xFFEEEEEE), // For elements like dividers or disabled tracks
          onSurfaceVariant: onBackgroundLight,
          outline: Color(0xFFBDBDBD),
          shadow: const Color(0x1A000000), // Equivalent to black.withOpacity(0.1)
          inverseSurface: onSurfaceLight, // Typically a dark background for snackbars on light theme
          onInverseSurface: surfaceLight, // Text color for inverseSurface
          inversePrimary: primaryColorDark, // For elements like primary buttons on dark surfaces
        ),
        scaffoldBackgroundColor: backgroundLight,
        textTheme: _textTheme.apply(bodyColor: onBackgroundLight, displayColor: onBackgroundLight),
        appBarTheme: AppBarTheme(
          color: surfaceLight, // Or primaryColorLight
          elevation: 1,
          iconTheme: const IconThemeData(color: onSurfaceLight),
          titleTextStyle: _textTheme.headlineMedium?.copyWith(color: onSurfaceLight),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: secondaryColorLight,
          foregroundColor: onSecondaryLight,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColorLight,
            foregroundColor: onPrimaryLight,
            textStyle: _textTheme.labelLarge,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: primaryColorLight, width: 2),
          ),
          labelStyle: _textTheme.bodyMedium?.copyWith(color: onSurfaceLight.withOpacity(0.7)),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: noteCardBackgroundLight,
        ),
        dividerTheme: DividerThemeData(
          color: Colors.grey[300],
          thickness: 1,
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        primaryColor: primaryColorDark,
        colorScheme: ColorScheme(
          brightness: Brightness.dark,
          primary: primaryColorDark,
          onPrimary: onPrimaryDark,
          primaryContainer: primaryVariantDark,
          onPrimaryContainer: onPrimaryDark,
          secondary: secondaryColorDark,
          onSecondary: onSecondaryDark,
          secondaryContainer: Color(0xFF03DAC5), // Lighter shade for dark theme
          onSecondaryContainer: onSecondaryDark,
          tertiary: Color(0xFF64FFDA), // Example tertiary for dark
          onTertiary: Colors.black,
          tertiaryContainer: Color(0xFF00BFA5),
          onTertiaryContainer: Colors.black,
          error: errorDark,
          onError: onErrorDark,
          errorContainer: Color(0xFFB00020),
          onErrorContainer: Colors.white,
          background: backgroundDark,
          onBackground: onBackgroundDark,
          surface: surfaceDark,
          onSurface: onSurfaceDark,
          surfaceVariant: Color(0xFF303030),
          onSurfaceVariant: onBackgroundDark,
          outline: Color(0xFF424242),
          shadow: const Color(0x4D000000), // Equivalent to black.withOpacity(0.3)
          inverseSurface: onSurfaceDark,
          onInverseSurface: surfaceDark,
          inversePrimary: primaryColorLight,
        ),
        scaffoldBackgroundColor: backgroundDark,
        textTheme: _textTheme.apply(bodyColor: onBackgroundDark, displayColor: onBackgroundDark),
        appBarTheme: AppBarTheme(
          color: surfaceDark, // Or primaryColorDark
          elevation: 1,
          iconTheme: const IconThemeData(color: onSurfaceDark),
          titleTextStyle: _textTheme.headlineMedium?.copyWith(color: onSurfaceDark),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: secondaryColorDark,
          foregroundColor: onSecondaryDark,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColorDark,
            foregroundColor: onPrimaryDark,
            textStyle: _textTheme.labelLarge,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[700]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: primaryColorDark, width: 2),
          ),
          labelStyle: _textTheme.bodyMedium?.copyWith(color: onSurfaceDark.withOpacity(0.7)),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: noteCardBackgroundDark,
        ),
        dividerTheme: DividerThemeData(
          color: Colors.grey[700],
          thickness: 1,
        ),
      );
}
