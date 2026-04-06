import 'package:flutter/material.dart';

class AppColors {
  // 🔹 Brand / Primary
  static const Color primary = Color(0xFF3B82F6); // Blue accent
  static const Color primaryLight = Color(0xFFDBEAFE); // Blue tint

  // 🔹 Backgrounds
  static const Color background = Color(0xFFF0F1F3); // Light gray page
  static const Color surface = Color(0xFFFFFFFF); // White cards
  static const Color surfaceHover = Color(0xFFF5F6F8); // Hover states
  static const Color surfaceLight = Color(0xFFF9FAFB); // Inputs

  // 🔹 Sidebar
  static const Color sidebarBg = Color(0xFFFFFFFF); // White sidebar
  static const Color sidebarActive = Color(0xFF1A1A2E); // Black active pill
  static const Color sidebarActiveText = Color(0xFFFFFFFF); // White on active
  static const Color sidebarIcon = Color(0xFF6B7280); // Gray icons

  // 🔹 Text
  static const Color textPrimary = Color(0xFF1A1A2E); // Near-black
  static const Color textSecondary = Color(0xFF6B7280); // Gray
  static const Color textMuted = Color(0xFF9CA3AF); // Light gray

  // 🔹 Status
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // 🔹 Borders & Dividers
  static const Color border = Color(0xFFE5E7EB);

  // 🔹 Buttons
  static const Color buttonPrimary = primary;
  static const Color buttonDisabled = Color(0xFFD1D5DB);

  // 🔹 Icons
  static const Color icon = Color(0xFF6B7280);

  // ❌ Prevent instantiation
  const AppColors._();
}
