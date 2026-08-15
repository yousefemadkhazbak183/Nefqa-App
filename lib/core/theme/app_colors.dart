import 'package:flutter/material.dart';

class AppColors {
  // Dark
  static const backgroundDark = Color(0xFF131313);
  static const surfaceDark = Color(0xFF1E1E1E);
  static const surfaceElevatedDark = Color(0xFF232323);
  static const textPrimaryDark = Color(0xFFF5F5F5);
  static const textSecondaryDark = Color(0xFF8A8A8A);
  static const textMutedDark = Color(0xFF6A6A6A);
  static const accentDark = Color(0xFFF0F0F0);

  // Light
  static const backgroundLight = Color(0xFFFAFAFA);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceElevatedLight = Color(0xFFF0F0F0);
  static const textPrimaryLight = Color(0xFF1A1A1A);
  static const textSecondaryLight = Color(0xFF6E6E6E);
  static const textMutedLight = Color(0xFF9E9E9E);
  static const accentLight = Color(0xFF1A1A1A);

  // Categories (same in both modes)
  static const categoryAmber = Color(0xFFE8A33D);
  static const categoryTeal = Color(0xFF6FAE95);
  static const categoryPurple = Color(0xFF8F89E0);
  static const categoryCoral = Color(0xFFD46A5B);
  static const categoryGray = Color(0xFF9A9A9A);

  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color background(BuildContext context) =>
      _isDark(context) ? backgroundDark : backgroundLight;

  static Color surface(BuildContext context) =>
      _isDark(context) ? surfaceDark : surfaceLight;

  static Color surfaceElevated(BuildContext context) =>
      _isDark(context) ? surfaceElevatedDark : surfaceElevatedLight;

  static Color textPrimary(BuildContext context) =>
      _isDark(context) ? textPrimaryDark : textPrimaryLight;

  static Color textSecondary(BuildContext context) =>
      _isDark(context) ? textSecondaryDark : textSecondaryLight;

  static Color textMuted(BuildContext context) =>
      _isDark(context) ? textMutedDark : textMutedLight;

  static Color accent(BuildContext context) =>
      _isDark(context) ? accentDark : accentLight;
}
