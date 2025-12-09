import 'package:flutter/material.dart';

class AppColors {
  // 🔹 Brand / Primary
  static const Color primary = Color(0xFF6C63FF); // Main accent
  static const Color secondary = Color(0xFF00E5FF); // Optional glow accent

  // 🔹 Backgrounds
  static const Color background = Color(0xFF0F1220); // Main background
  static const Color surface = Color(0xFF1B1E36); // Cards, containers
  static const Color surfaceLight = Color(0xFF25284A); // Inputs

  // 🔹 Text
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color textMuted = Colors.white54;

  // 🔹 Status
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);

  // 🔹 Borders & Dividers
  static const Color border = Color(0xFF2E325F);

  // 🔹 Buttons
  static const Color buttonPrimary = primary;
  static const Color buttonDisabled = Color(0xFF4A4E75);

  // 🔹 Icons
  static const Color icon = Colors.white70;

  // ❌ Prevent instantiation
  const AppColors._();
}
