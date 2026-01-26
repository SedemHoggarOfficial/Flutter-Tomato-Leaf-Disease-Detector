import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

    // Modern Professional Colors - Light Theme (Nature Green)
  static const Color primaryLight = Color(0xFF0B3D2E); // Deep Nature Green
  static const Color secondaryLight = Color(0xFFC7D1B9); // Sage Green Accent
  static const Color surfaceLight = Color(0xFFF2F5F8); // Professional Cool Grey
  static const Color cardLight = Color(0xFFFFFFFF); // Clean White
  static const Color textPrimaryLight = Color(0xFF040502); // Soft Black
  static const Color textSecondaryLight = Color(0xFF584A40,); // Earthy Brown-Grey

  // Modern Professional Colors - Dark Theme (Deep Forest)
  static const Color primaryDark = Color(0xFFFFFFFF); // Nature Green (Same as Light)
  static const Color secondaryDark = Color(0xFFFFFFFF); // White for contrast
  static const Color surfaceDark = Color(0xFF0D0D0D); // Near Black
  static const Color cardDark = Color(0xFF1C1C1E); // Dark Grey
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFF8E8E93);

  // Accent colors
  static const Color success = Color(0xFF2E6B50);
  //static const Color warning = Color(0xFFD97706);
  static const Color error = Color(0xFFB91C1C);

  // Gradient for welcome screen only (Nature Vibes)
  static const LinearGradient welcomeGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF367009), Color(0xFF5B8C36)],
  );

  static const LinearGradient welcomeGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E3E08), Color(0xFF2C5512)],
  );


    // Confidence level bar
  static const Color confidenceLow = Colors.red;
  static const Color confidenceMedium = Colors.orange;
  static const Color confidenceHigh = Color(0xFF66BB6A);

  // static const Color cardLight = Color(0xFFFFFFFF); // Clean White
}