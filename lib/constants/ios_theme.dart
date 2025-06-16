import 'package:flutter/material.dart';

class IOSTheme {
  // Colors
  static const Color primary = Color(0xFF007AFF);
  static const Color secondary = Color(0xFF5856D6);
  static const Color background = Colors.white;
  static const Color secondaryBackground = Color(0xFFF2F2F7);
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color divider = Color(0xFFD1D1D6);
  static const Color error = Color(0xFFFF3B30);

  // Typography
  static const TextStyle heading = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.41,
    color: textPrimary,
    fontFamily: '.SF Pro Text',
  );

  static const TextStyle subheading = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.38,
    color: textPrimary,
    fontFamily: '.SF Pro Text',
  );

  static const TextStyle body = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.41,
    color: textPrimary,
    fontFamily: '.SF Pro Text',
  );

  // Decorations
  static BoxDecoration textFieldDecoration = BoxDecoration(
    color: secondaryBackground,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: divider, width: 0.5),
  );

  static BoxDecoration buttonDecoration = BoxDecoration(
    color: primary,
    borderRadius: BorderRadius.circular(10),
  );

  static BoxDecoration socialButtonDecoration = BoxDecoration(
    color: secondaryBackground,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: divider, width: 0.5),
  );

  // Animations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);

  // Curves
  static const Curve defaultCurve = Curves.easeOutCubic;
  
  // Padding and Spacing
  static const double defaultPadding = 16.0;
  static const double buttonHeight = 50.0;
  static const double textFieldHeight = 44.0;
  static const double borderRadius = 10.0;

  // Shadows
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.07),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];
}
