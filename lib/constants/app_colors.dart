import 'package:flutter/material.dart';

class AppColors {
  // Primary palette
  static const Color primary = Color(0xFF1E1E2E); // Deep slate
  static const Color secondary = Color(0xFFFFFFFF); // White
  static const Color accent = Color(0xFF00D9FF); // Cyan accent

  // Persona gradients - vibrant, immersive, minimalist
  static const LinearGradient explorerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)], // Purple to deep purple
  );

  static const LinearGradient hostGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF093FB), Color(0xFFF5576C)], // Pink to coral
  );

  static const LinearGradient performerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00D2FC), Color(0xFF3677FF)], // Cyan to blue
  );

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
