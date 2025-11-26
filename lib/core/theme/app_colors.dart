import 'package:flutter/material.dart';

/// Angler-themed color palette with earth tones and dark map UI.
class AppColors {
  AppColors._();

  // Primary earth tones
  static const Color primaryGreen = Color(0xFF2D5A27);
  static const Color primaryBrown = Color(0xFF5D4037);
  static const Color accentOrange = Color(0xFFE65100);
  static const Color accentGold = Color(0xFFFFB300);

  // Dark map UI colors
  static const Color mapDark = Color(0xFF1A1A2E);
  static const Color mapMedium = Color(0xFF16213E);
  static const Color mapLight = Color(0xFF0F3460);

  // Surface colors
  static const Color surfaceDark = Color(0xFF121212);
  static const Color surfaceCard = Color(0xFF1E1E1E);
  static const Color surfaceElevated = Color(0xFF2C2C2C);

  // Text colors
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textMuted = Color(0xFF757575);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFEF5350);
  static const Color info = Color(0xFF29B6F6);

  // Water & weather themed
  static const Color waterBlue = Color(0xFF0288D1);
  static const Color waterDeep = Color(0xFF01579B);
  static const Color sunnyYellow = Color(0xFFFFD54F);
  static const Color cloudGray = Color(0xFF78909C);

  // Hotspot intensity colors
  static const Color hotspotHigh = Color(0xFFE53935);
  static const Color hotspotMedium = Color(0xFFFF9800);
  static const Color hotspotLow = Color(0xFF4CAF50);

  // Gradient for bite prediction
  static const List<Color> biteGradient = [
    Color(0xFF1B5E20),
    Color(0xFF388E3C),
    Color(0xFFFBC02D),
    Color(0xFFE65100),
    Color(0xFFB71C1C),
  ];
}
