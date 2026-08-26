import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand / Accent Colors
  static const Color primary = Color(0xFFFF5B22); // Vibrant Bron Orange
  static const Color primaryLight = Color(0xFFFF7A45);
  static const Color primarySoft = Color(0xFFFFF2ED); // Light orange tint
  static const Color primaryDark = Color(0xFFE04812);

  // Light Theme Background & Surface (Default app design from Figma)
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFF8F9FA);
  static const Color borderLight = Color(0xFFEEEEEE);
  static const Color dividerLight = Color(0xFFF0F0F0);

  // Dark Theme Colors
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color cardDark = Color(0xFF242424);
  static const Color borderDark = Color(0xFF27272A);

  // Text Colors (Light Mode)
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textMuted = Color(0xFF8E8E93);
  static const Color textHint = Color(0xFFBDBDBD);

  // Text Colors (Dark Mode)
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFF71717A);

  // Indicators & Buttons
  static const Color indicatorActive = Color(0xFFFFFFFF);
  static const Color indicatorInactive = Color(0x33FFFFFF);
  static const Color buttonWhite = Color(0xFFFFFFFF);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
}
