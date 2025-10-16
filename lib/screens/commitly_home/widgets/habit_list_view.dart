import 'package:flutter/material.dart';

import '../../../data/habit.dart';

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

    if (habits.isEmpty) {
      return const Center(
        child: Text(
          'No habits yet. Create your first one from the Add Habit tab!',
          textAlign: TextAlign.center,
        ),
      );
    }

    return SafeArea(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        itemCount: habits.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final habit = habits[index];
          final isHovered = hoveredHabitIndex == index;
          return _HabitListTile(
            habit: habit,
            index: index,
            isHovered: isHovered,
            onHabitSelected: onHabitSelected,
            onHoverChanged: onHoverChanged,
          );
        },
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
              color: colorScheme.primary
                  .withValues(alpha: isHovered ? 0.35 : 0.18),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.emoji ?? '🗒️',
                      style: const TextStyle(fontSize: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habit.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            habit.frequencyLabel,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).hintColor,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            habit.streakLabel,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).hintColor,
                                ),
                          ),
                          if (habit.description != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              habit.description!,
                              style:
                                  Theme.of(context).textTheme.bodyMedium,
                            ),
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
                                ?.copyWith(
                                  color: Theme.of(context).hintColor,
                                ),
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
