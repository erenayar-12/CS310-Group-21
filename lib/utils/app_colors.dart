import 'package:flutter/material.dart';

/// Utility class for app-wide color constants
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // Primary Colors
  static const Color primaryPurple = Color(0xFF6A4BFF);
  static const Color primaryPurpleLight = Color(0xFF9D5BFF);
  static const Color primaryPurpleGradientStart = Color(0xFF8A36FF);
  static const Color primaryPurpleGradientEnd = Color(0xFF3F6FFF);

  // Background Colors
  static const Color backgroundLight = Color(0xFFF5F6FA);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color cardBackgroundLight = Color(0xFFE0E0F5);
  static const Color cardBackgroundPurple = Color(0xFFF3E8FF);

  // Status Colors
  static const Color successGreen = Color(0xFF31C36A);
  static const Color successGreenDark = Color(0xFF29A658);
  static const Color infoBlue = Color(0xFF1F8CFF);
  static const Color warningOrange = Color(0xFFF97316);
  static const Color errorRed = Color(0xFFEF4444);

  // Habit Color Options
  static const Color habitGreen = Color(0xFF22C55E);
  static const Color habitBlue = Color(0xFF3B82F6);
  static const Color habitPurple = Color(0xFFA855F7);
  static const Color habitRed = Color(0xFFEF4444);
  static const Color habitOrange = Color(0xFFF97316);
  static const Color habitPink = Color(0xFFEC4899);
  static const Color habitCyan = Color(0xFF06B6D4);
  static const Color habitYellow = Color(0xFFEAB308);

  // Achievement Colors
  static const Color achievementGold = Color(0xFFF59E0B);
  static const Color achievementGoldLight = Color(0xFFFBBF24);
  static const Color achievementOrange = Color(0xFFEA580C);
  static const Color achievementOrangeLight = Color(0xFFF97316);
  static const Color achievementRed = Color(0xFFDC2626);
  static const Color achievementRedLight = Color(0xFFEF4444);
  static const Color achievementYellow = Color(0xFFCA8A04);
  static const Color achievementBlue = Color(0xFF2563EB);
  static const Color achievementBlueLight = Color(0xFFEFF6FF);
  static const Color achievementPurpleLight = Color(0xFFFAF5FF);

  // Leaderboard Colors
  static const Color leaderboardOrange = Color(0xFFF97316);
  static const Color leaderboardGreen = Color(0xFF22C55E);
  static const Color leaderboardBlue = Color(0xFF3B82F6);

  // List of habit color options (for color picker)
  static const List<Color> habitColorOptions = [
    habitGreen,
    habitBlue,
    habitPurple,
    habitRed,
    habitOrange,
    habitPink,
    habitCyan,
    habitYellow,
  ];
}

