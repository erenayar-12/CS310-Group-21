import 'package:flutter/material.dart';

import '../../../data/habit.dart';
import '../../../data/friend.dart';
import 'friends_list_view.dart';

class HabitListView extends StatelessWidget {
  const HabitListView({
    required this.habits,
    required this.hoveredHabitIndex,
    required this.isLoading,
    required this.onHabitSelected,
    required this.onHoverChanged,
    super.key,
  });

  final List<Habit> habits;
  final int? hoveredHabitIndex;
  final bool isLoading;
  final ValueChanged<Habit> onHabitSelected;
  final ValueChanged<int?> onHoverChanged;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // FRIEND DATA (UI-only)
    final friends = [
      Friend(
        name: "Sarah Chen",
        level: 12,
        streak: 45,
        topHabit: "Morning Meditation",
        color: Colors.pink,
      ),
      Friend(
        name: "Mike Johnson",
        level: 8,
        streak: 28,
        topHabit: "Daily Exercise",
        color: Colors.blue,
      ),
      Friend(
        name: "Emma Davis",
        level: 15,
        streak: 62,
        topHabit: "Reading Books",
        color: Colors.green,
      ),
    ];

    return Container(
      color: Colors.grey.shade100,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          children: [

            // 🔥 HABIT CARDS
            if (habits.isEmpty)
              const Center(
                child: Text(
                  'No habits yet. Create your first one from the Add Habit tab!',
                  textAlign: TextAlign.center,
                ),
              )
            else
              ...List.generate(
                habits.length,
                (index) {
                  final habit = habits[index];
                  final isHovered = hoveredHabitIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _HabitListTile(
                      habit: habit,
                      index: index,
                      isHovered: isHovered,
                      onHabitSelected: onHabitSelected,
                      onHoverChanged: onHoverChanged,
                    ),
                  );
                },
              ),

            const SizedBox(height: 20),

            // 🔥 FRIENDS LIST SECTION (PDF-style)
            FriendsListView(friends: friends),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}

class _HabitListTile extends StatelessWidget {
  const _HabitListTile({
    required this.habit,
    required this.index,
    required this.isHovered,
    required this.onHabitSelected,
    required this.onHoverChanged,
  });

  final Habit habit;
  final int index;
  final bool isHovered;
  final ValueChanged<Habit> onHabitSelected;
  final ValueChanged<int?> onHoverChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tileColor = Color.alphaBlend(
      colorScheme.primary.withValues(alpha: isHovered ? 0.18 : 0.12),
      colorScheme.surface,
    );

    return MouseRegion(
      onEnter: (_) => onHoverChanged(index),
      onExit: (_) => onHoverChanged(null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: tileColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: isHovered ? 0.35 : 0.18),
              blurRadius: isHovered ? 18 : 10,
              offset: Offset(0, isHovered ? 10 : 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onHabitSelected(habit),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(habit.emoji ?? '🗒️', style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(habit.name,
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text(habit.frequencyLabel,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Theme.of(context).hintColor)),
                          const SizedBox(height: 4),
                          Text(habit.streakLabel,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Theme.of(context).hintColor)),
                          if (habit.description != null) ...[
                            const SizedBox(height: 8),
                            Text(habit.description!,
                                style: Theme.of(context).textTheme.bodyMedium),
                          ],
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: habit.progress.clamp(0.0, 1.0),
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            habit.remainingLabel,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Theme.of(context).hintColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
