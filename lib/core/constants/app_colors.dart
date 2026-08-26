import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand / Accent Colors
  static const Color primary = Color(0xFFFF5B22); // Bron Orange
  static const Color primaryLight = Color(0xFFFF7A45);
  static const Color primaryDark = Color(0xFFE04812);

  // Dark Theme Background & Surface (Matches Onboarding design)
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color cardDark = Color(0xFF242424);

  // Light Theme Colors
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);

  // Text Colors (Dark Mode)
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFFA1A1AA);
  static const Color textSecondaryDark = Color(0xFF71717A);

  // Text Colors (Light Mode)
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);

  // Indicators & Borders
  static const Color indicatorActive = Color(0xFFFFFFFF);
  static const Color indicatorInactive = Color(0x33FFFFFF); // 20% opacity white
  static const Color borderDark = Color(0xFF27272A);

  // Button Colors
  static const Color buttonWhite = Color(0xFFFFFFFF);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
}
