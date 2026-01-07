import 'package:flutter/material.dart';

class AppColors {
  // Primary palette
  static const Color primary = Color(0xFF1E1E2E); // Deep slate
  static const Color secondary = Color(0xFFFFFFFF); // White
  static const Color accent = Color(0xFF00D9FF); // Cyan accent

  // Persona gradients - minimal black with dividers
  static const LinearGradient explorerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF000000), Color(0xFF000000)], // Pure black
  );

  static const LinearGradient hostGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF000000), Color(0xFF000000)], // Pure black
  );

  static const LinearGradient performerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF000000), Color(0xFF000000)], // Pure black
  );

  // Persona-specific accent colors
  static const Color explorerAccent = Color(0xFF00A3FF); // Bright navy blue
  static const Color hostAccent = Color(0xFFD946EF); // Vibrant purple
  static const Color performerAccent = Color(0xFF00D9A3); // Vibrant teal

  // Neutral palette
  static const Color darkBg = Color(0xFF0F0F1E);
  static const Color cardBg = Color(0xFF1A1A2E);
  static const Color divider = Color(0xFF2A2A3E);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0C0);
  static const Color textTertiary = Color(0xFF808090);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFFF6B6B);
  static const Color warning = Color(0xFFFFC107);

  // Utility
  static const Color transparent = Colors.transparent;
  static const Color black = Colors.black;
  static const Color white = Colors.white;
}
