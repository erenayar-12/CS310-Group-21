import 'package:flutter/material.dart';

class TodayProgressCard extends StatelessWidget {
  const TodayProgressCard({
    required this.totalHabits,
    required this.completedHabits,
    super.key,
  });

  final int totalHabits;
  final int completedHabits;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final safeTotal = totalHabits == 0 ? 3 : totalHabits;
    final progress = (completedHabits / safeTotal).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Today's Progress",
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  '$completedHabits / $safeTotal',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.primary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}