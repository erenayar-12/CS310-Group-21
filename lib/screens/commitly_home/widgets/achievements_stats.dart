import 'package:flutter/material.dart';

import 'achievements_view.dart';

class AchievementsStats extends StatelessWidget {
  const AchievementsStats({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget buildButton(String label, IconData icon) {
      return Expanded(
        child: OutlinedButton.icon(
          onPressed: () {
            if (label == 'Achievements') {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AchievementsView(),
                ),
              );
            } else {
              showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(label),
                  content: Text('$label page will be implemented later.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            }
          },
          icon: Icon(icon, size: 18),
          label: Text(label),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'More',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              buildButton('Achievements', Icons.emoji_events_outlined),
              const SizedBox(width: 12),
              buildButton('Statistics', Icons.bar_chart_outlined),
            ],
          ),
        ],
      ),
    );
  }
}