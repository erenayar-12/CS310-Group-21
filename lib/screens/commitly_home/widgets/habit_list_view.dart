import 'package:flutter/material.dart';

import '../../../data/habit.dart';
import 'home_header.dart';
import 'today_progress_card.dart';
import 'today_habits_header.dart';
import 'habit_card.dart';
import 'achievements_stats.dart';

class HabitListView extends StatelessWidget {
  const HabitListView({
    required this.habits,
    required this.hoveredHabitIndex,
    required this.isLoading,
    required this.onHabitSelected,
    required this.onHoverChanged,
    this.onDelete,
    this.onComplete,
    super.key,
  });

  final List<Habit> habits;
  final int? hoveredHabitIndex;
  final bool isLoading;
  final ValueChanged<Habit> onHabitSelected;
  final ValueChanged<int?> onHoverChanged;
  final ValueChanged<Habit>? onDelete;
  final ValueChanged<Habit>? onComplete;

  int get _completedToday =>
      habits.where((h) => h.progress >= 1.0).length; // simple rule

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HomeHeader(),
            const SizedBox(height: 16),
            TodayProgressCard(
              totalHabits: habits.isEmpty ? 3 : habits.length,
              completedHabits: _completedToday,
            ),
            const SizedBox(height: 16),
            const TodayHabitsHeader(),
            const SizedBox(height: 8),
            if (habits.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'No habits yet. Create your first one from the Add tab!',
                  textAlign: TextAlign.left,
                ),
              )
            else
              ListView.separated(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: habits.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final habit = habits[index];
                  final isHovered = hoveredHabitIndex == index;
                  return HabitCard(
                    habit: habit,
                    index: index,
                    isHovered: isHovered,
                    onHabitSelected: onHabitSelected,
                    onHoverChanged: onHoverChanged,
                    onDelete: onDelete,
                    onComplete: onComplete,
                  );
                },
              ),
            const SizedBox(height: 24),
            const AchievementsStats(),
          ],
        ),
      ),
    );
  }
}