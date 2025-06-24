import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Apple Notes Color Palette
  static const Color noteListBackground = Color(0xFFF9F9F9);
  static const Color noteEditorBackground = Color(0xFFFFFDD0);
  static const Color primaryText = Color(0xFF1C1C1E);
  static const Color secondaryText = Color(0xFF8E8E93);
  static const Color accentColor = Color(0xFFFFCC00);
  static const Color noteDividerColor = Color(0xFFD1D1D6);

  // Typography (using Roboto as SF Pro alternative)
  static TextStyle get titleText => GoogleFonts.roboto(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primaryText,
      );

  static TextStyle get bodyText => GoogleFonts.roboto(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: primaryText,
      );

  static TextStyle get subtitleText => GoogleFonts.roboto(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: secondaryText,
      );

  static TextStyle get timestampText => GoogleFonts.roboto(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: secondaryText,
      );

  // Global ThemeData
  static ThemeData get lightTheme => ThemeData(
        scaffoldBackgroundColor: noteListBackground,
        primaryColor: accentColor,
        textTheme: TextTheme(
          titleLarge: titleText,
          bodyLarge: bodyText,
          bodyMedium: subtitleText,
          labelSmall: timestampText,
        ),
        dividerTheme: const DividerThemeData(
          color: noteDividerColor,
          thickness: 0.5,
          space: 0,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: noteListBackground,
          elevation: 0,
          iconTheme: const IconThemeData(color: primaryText),
          titleTextStyle: titleText,
        ),
      );

  // Note Editor Theme
  static BoxDecoration get noteEditorDecoration => BoxDecoration(
        color: noteEditorBackground,
        image: DecorationImage(
          image: AssetImage("assets/paper_texture.png"),
          fit: BoxFit.cover,
          opacity: 0.05,
        ),
      );
}
