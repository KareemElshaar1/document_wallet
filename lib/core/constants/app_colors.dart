import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary brand colors
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFFC7D2FE);

  // Secondary/Accent colors
  static const Color secondary = Color(0xFF0EA5E9); // Sky blue
  static const Color accent = Color(0xFF10B981); // Emerald green
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Rose red

  // Light Mode Colors
  static const Color bgLight = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceLight = Colors.white;
  static const Color cardLight = Color(0xFFF1F5F9); // Slate 100
  static const Color textPrimaryLight = Color(0xFF0F172A); // Slate 900
  static const Color textSecondaryLight = Color(0xFF475569); // Slate 600
  static const Color borderLight = Color(0xFFE2E8F0); // Slate 200

  // Dark Mode Colors
  static const Color bgDark = Color(0xFF0B0F19); // Deep Midnight
  static const Color surfaceDark = Color(0xFF151B2C); // Dark Slate Card
  static const Color cardDark = Color(0xFF1E293B); // Slate 800
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // Slate 50
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Slate 400
  static const Color borderDark = Color(0xFF334155); // Slate 700

  // Glassmorphic properties
  static const Color glassWhite = Color(0x33FFFFFF);
  static const Color glassBlack = Color(0x4D000000);
}
