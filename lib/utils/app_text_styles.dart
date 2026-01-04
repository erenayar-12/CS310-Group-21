import 'package:flutter/material.dart';

/// Utility class for app-wide text style constants
class AppTextStyles {
  AppTextStyles._(); // Private constructor to prevent instantiation

  // Headline Styles
  static TextStyle headlineLarge(BuildContext context) {
    return Theme.of(context).textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ) ??
        const TextStyle(fontSize: 32, fontWeight: FontWeight.bold);
  }

  static TextStyle headlineMedium(BuildContext context) {
    return Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ) ??
        const TextStyle(fontSize: 28, fontWeight: FontWeight.bold);
  }

  static TextStyle headlineSmall(BuildContext context) {
    return Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ) ??
        const TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
  }

  // Title Styles
  static TextStyle titleLarge(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ) ??
        const TextStyle(fontSize: 22, fontWeight: FontWeight.w600);
  }

  static TextStyle titleMedium(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ) ??
        const TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
  }

  static TextStyle titleSmall(BuildContext context) {
    return Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w500,
        ) ??
        const TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
  }

  // Body Styles
  static TextStyle bodyLarge(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge ??
        const TextStyle(fontSize: 16);
  }

  static TextStyle bodyMedium(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium ??
        const TextStyle(fontSize: 14);
  }

  static TextStyle bodySmall(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall ??
        const TextStyle(fontSize: 12);
  }

  // Label Styles
  static TextStyle labelLarge(BuildContext context) {
    return Theme.of(context).textTheme.labelLarge ??
        const TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
  }

  static TextStyle labelMedium(BuildContext context) {
    return Theme.of(context).textTheme.labelMedium ??
        const TextStyle(fontSize: 12, fontWeight: FontWeight.w500);
  }

  static TextStyle labelSmall(BuildContext context) {
    return Theme.of(context).textTheme.labelSmall ??
        const TextStyle(fontSize: 11, fontWeight: FontWeight.w500);
  }

  // Navigation Bar Label Style
  static const TextStyle navigationBarLabel = TextStyle(
    color: Colors.white,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );
}

