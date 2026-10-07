import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Emerald / Fresh Mint Green
  static const Color primary = Color(0xFF0D9488); // Teal / Emerald balance
  static const Color primaryLight = Color(0xFF14B8A6);
  static const Color primaryDark = Color(0xFF0F766E);
  static const Color primaryContainer = Color(0xFFCCFBF1);
  static const Color onPrimaryContainer = Color(0xFF115E59);

  // Secondary
  static const Color secondary = Color(0xFF475569);
  static const Color secondaryContainer = Color(0xFFF1F5F9);

  // Backgrounds & Surfaces (Light)
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF1F5F9);
  static const Color borderLight = Color(0xFFE2E8F0);

  // Backgrounds & Surfaces (Dark)
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color surfaceVariantDark = Color(0xFF334155);
  static const Color borderDark = Color(0xFF334155);

  // Macro Nutrients colors (Standardized, accessible)
  static const Color protein = Color(0xFF3B82F6); // Vibrant Blue
  static const Color proteinLight = Color(0xFFDBEAFE);
  static const Color carb = Color(0xFFF59E0B); // Amber / Gold
  static const Color carbLight = Color(0xFFFEF3C7);
  static const Color fat = Color(0xFFF43F5E); // Soft Rose
  static const Color fatLight = Color(0xFFFFE4E6);

  // Calorie Status Colors (Neutral & Non-judgmental)
  // When over target: Warm subtle bronze/amber instead of screaming red
  static const Color calorieOver = Color(0xFFD97706);
  static const Color calorieOverLight = Color(0xFFFEF3C7);
  static const Color calorieNormal = Color(0xFF0D9488);
  static const Color calorieNormalLight = Color(0xFFCCFBF1);

  // Text
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
}
