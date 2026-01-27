import 'package:flutter/material.dart';

/// Centralized UI constants for the entire application.
/// Use these values instead of hardcoded numbers for consistency and maintainability.
class AppConstants {
  AppConstants._();

  static const double splashScreenRadius = 90;

  // ============================================================
  // BORDER RADIUS
  // ============================================================

  static const double radiusXxs = 4;

  /// Extra small radius (6) - Progress bars, small indicators
  static const double radiusXs = 6;

  /// Small radius (8) - Chevron buttons, small badges
  static const double radiusSm = 8;

  /// Medium radius (10) - Icon backgrounds in feature items
  static const double radiusMd = 10;

  /// Large radius (12) - Badge containers, disease count chips
  static const double radiusLg = 12;

  /// Extra large radius (16) - Icon containers in expandable sections
  static const double radiusXl = 16;

  /// 2XL radius (20) - Status badges, AI powered chip
  static const double radius2xl = 20;

  /// 3XL radius (24) - Cards, feature items, disease cards
  static const double radius3xl = 18;

  /// Full/Pill radius (30) - Pill-shaped buttons, theme toggles
  static const double radiusFull = 100;

  /// Card radius (32) - Large section containers, header cards
  static const double radiusCard = 18;

  /// Hero radius (40) - Main scanner cards, analyzing state
  static const double radiusHero = 18;

  // Special Purpose
  /// Theme toggle button radius (pill shape)
  static const double radiusThemeToggle = 30;

  /// Button radius for ElevatedButton/OutlinedButton
  static const double radiusButton = 12;

  /// Back button uses BoxShape.circle (no radius needed)

  // ============================================================
  // SPACING
  // ============================================================

  /// XXS spacing (4) - Tiny gaps
  static const double spacingXxs = 4;

  /// XS spacing (6) - Small gaps
  static const double spacingXs = 6;

  /// Small spacing (8) - Between icon and text
  static const double spacingSm = 8;

  /// Medium spacing (10) - Small vertical gaps
  static const double spacingMd = 10;

  /// Large spacing (12) - Button gaps, section breaks
  static const double spacingLg = 12;

  /// XL spacing (16) - Standard gaps
  static const double spacingXl = 16;

  /// 2XL spacing (20) - Padding in sections
  static const double spacing2xl = 20;

  /// 3XL spacing (24) - Section padding
  static const double spacing3xl = 24;

  /// 4XL spacing (32) - Large section gaps
  static const double spacing4xl = 32;

  /// 5XL spacing (40) - Hero spacing
  static const double spacing5xl = 40;

  // ============================================================
  // ICON SIZES
  // ============================================================

  /// XS icon (10) - Chart pie icons, tiny indicators
  static const double iconXs = 10;

  /// Small icon (12) - Arrow down, chevrons
  static const double iconSm = 12;

  /// Medium icon (14) - Theme toggle icons
  static const double iconMd = 14;

  /// Large icon (16) - Back arrow, small icons
  static const double iconLg = 16;

  /// XL icon (18) - Action button icons
  static const double iconXl = 18;

  /// 2XL icon (24) - Card icons
  static const double icon2xl = 24;

  /// 3XL icon (32) - Empty state camera
  static const double icon3xl = 32;

  /// 4XL icon (48) - Analyzing state microscope
  static const double icon4xl = 48;

  /// 5XL icon (64) - Hero plant icon
  static const double icon5xl = 64;

  // ============================================================
  // SHADOWS
  // ============================================================

  /// Light shadow opacity (0.03)
  static const double shadowLight = 0.03;

  /// Medium shadow opacity (0.05)
  static const double shadowMedium = 0.05;

  /// Heavy shadow opacity (0.08)
  static const double shadowHeavy = 0.08;

  // Common shadow presets
  static List<BoxShadow> lightShadow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: shadowLight),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> cardShadow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: shadowLight),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> heroShadow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: shadowMedium),
      blurRadius: 40,
      offset: const Offset(0, 10),
    ),
  ];

  // ============================================================
  // BUTTON DIMENSIONS
  // ============================================================

  /// Standard button height
  static const double buttonHeight = 52;
  static const double buttonMediumHeight = 42;
  static const double buttonSmallHeight = 33;


  /// Loading indicator size inside buttons
  static const double loaderSize = 22;

  /// Loading indicator stroke width
  static const double loaderStrokeWidth = 2.5;

  // ============================================================
  // ANIMATION DURATIONS
  // ============================================================

  /// Fast animation (200ms)
  static const Duration animationFast = Duration(milliseconds: 200);

  /// Normal animation (300ms)
  static const Duration animationNormal = Duration(milliseconds: 300);

  /// Slow animation (500ms)
  static const Duration animationSlow = Duration(milliseconds: 500);

  /// Pulse animation (1500ms)
  static const Duration animationPulse = Duration(milliseconds: 1500);

  // ============================================================
  // SPLASH SCREEN
  // ============================================================

  /// Splash screen duration (6 seconds)
  static const Duration splashDuration = Duration(seconds: 6);

  /// Splash scan animation duration
  static const Duration splashScanDuration = Duration(milliseconds: 2000);

  /// Splash flow animation duration
  static const Duration splashFlowDuration = Duration(milliseconds: 1500);

  /// Splash leaf appearance duration
  static const Duration splashLeafDuration = Duration(milliseconds: 800);
}
