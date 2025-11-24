import 'package:flutter/material.dart';

class Friend {
  final String name;
  final int level;
  final int streak;
  final String topHabit;
  final Color color;

  Friend({
    required this.name,
    required this.level,
    required this.streak,
    required this.topHabit,
    required this.color,
  });
}
