import 'package:flutter/material.dart';
import '../../../data/habit.dart';

class HabitCard extends StatelessWidget {
  const HabitCard({
    required this.habit,
    required this.index,
    required this.isHovered,
    required this.onHabitSelected,
    required this.onHoverChanged,
    super.key,
  });

  final Habit habit;
  final int index;
  final bool isHovered;
  final ValueChanged<Habit> onHabitSelected;
  final ValueChanged<int?> onHoverChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return MouseRegion(
      onEnter: (_) => onHoverChanged(index),
      onExit: (_) => onHoverChanged(null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isHovered ? 0.3 : 0.18),
              blurRadius: isHovered ? 14 : 10,
              offset: Offset(0, isHovered ? 8 : 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onHabitSelected(habit),
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        habit.emoji ?? '🗒️',
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habit.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            habit.frequencyLabel,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            habit.streakLabel,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.black87,
                            ),
                          ),
                          if (habit.description != null &&
                              habit.description!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              habit.description!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.black87,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: habit.progress.clamp(0.0, 1.0),
                              minHeight: 8,
                              backgroundColor:
                              const Color(0xFFE0E0F5), // light track
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            habit.remainingLabel,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.black87,
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