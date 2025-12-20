import 'package:flutter/material.dart';

/// Centralized color definitions following product-guidelines.md
/// Primary: Vibrant Yellow (#f9f506)
/// Dark Mode First: Deep backgrounds with high-contrast text
class ColorsManager {
  ColorsManager._();

  // Primary Brand Color
  static const Color primary = Color(0xFFF9F506);
  static const Color primaryDark = Color(0xFFE0DC05);
  static const Color primaryLight = Color(0xFFFAF740);

  // Dark Theme Backgrounds (from product-guidelines.md)
  static const Color darkBackground = Color(0xFF23220F);
  static const Color darkSurface = Color(0xFF2F2E1A);
  static const Color darkCard = Color(0xFF3A3A24);

  // Light Theme Backgrounds
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF5F5F5);
  static const Color lightCard = Color(0xFFFFFFFF);

  // Text Colors - Dark Theme
  static const Color darkOnBackground = Color(0xFFFFFFFF);
  static const Color darkOnSurface = Color(0xFFFFFFFF);
  static const Color darkSecondaryText = Color(0xFF8D8D93);
  static const Color darkHintText = Color(0xFF6B6B70);

  // Text Colors - Light Theme
  static const Color lightOnBackground = Color(0xFF000000);
  static const Color lightOnSurface = Color(0xFF000000);
  static const Color lightSecondaryText = Color(0xFF8A8A8E);
  static const Color lightHintText = Color(0xFFA0A0A5);

  // Accent Colors
  static const Color success = Color(0xFF34C759);
  static const Color error = Color(0xFFFF3B30);
  static const Color warning = Color(0xFFFF9500);
  static const Color info = Color(0xFF007AFF);

  // Favorite/Star Color
  static const Color starActive = primary;
  static const Color starInactive = Color(0xFF8D8D93);

  // Border & Divider
  static const Color dividerDark = Color(0xFF3A3A3C);
  static const Color dividerLight = Color(0xFFE5E5EA);
  static const Color borderDark = Color(0xFF48483B);
  static const Color borderLight = Color(0xFFD1D1D6);

  // Shadow
  static const Color shadowDark = Color(0x40000000);
  static const Color shadowLight = Color(0x1A000000);
}
