import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const Color primary = Color(0xFFFFED4E); // Yellow accent
  static const Color primaryDark = Color(0xFFE5D546);
  static const Color accent = primary; // Alias

  // Backgrounds
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF1E1E1E);
  static const Color surface = cardLight; // Default surface for light mode

  // Text
  static const Color textPrimaryLight = Color(0xFF1A1A1A);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB3B3B3);
  static const Color textPrimary = textPrimaryLight; // Default

  // Accents & Tags
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);

  // Tag Colors (for badges)
  static const Color tagWork = Color(0xFFE3F2FD); // Light Blue
  static const Color tagWorkText = Color(0xFF1565C0);
  static const Color tagPersonal = Color(0xFFF3E5F5); // Light Purple
  static const Color tagPersonalText = Color(0xFF7B1FA2);
  static const Color tagStudy = Color(0xFFE8F5E9); // Light Green
  static const Color tagStudyText = Color(0xFF2E7D32);
  static const Color tagIdea = Color(0xFFFFF3E0); // Light Orange
  static const Color tagIdeaText = Color(0xFFEF6C00);

  // UI Elements
  static const Color divider = Color(0xFFEEEEEE);
  static const Color iconLight = Color(0xFF424242);
  static const Color iconDark = Color(0xFFE0E0E0);
}
