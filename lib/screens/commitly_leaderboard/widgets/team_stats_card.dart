import 'package:flutter/material.dart';
import '../../../data/habit_group.dart';
import '../../../utils/app_colors.dart';

class TeamStatsCard extends StatelessWidget {
  final HabitGroup group;

  const TeamStatsCard({required this.group, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: theme.colorScheme.surfaceContainerHighest,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Team Stats',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              _StatRow(
                icon: Icons.local_fire_department_outlined,
                iconColor: AppColors.leaderboardOrange,
                label: 'Total days completed',
                value: '${group.streak}', // USING STREAK AS TOTAL FOR NOW
                subtitle: 'All members this week',
              ),
              const Divider(height: 16),
              const _StatRow(
                icon: Icons.trending_up_outlined,
                iconColor: AppColors.leaderboardGreen,
                label: 'Average streak',
                value: '---', // Needs calculation logic
                subtitle: 'Per active member',
              ),
              const Divider(height: 16),
              _StatRow(
                icon: Icons.check_circle_outline,
                iconColor: AppColors.leaderboardBlue,
                label: 'On-track members',
                value: '${group.todayProgress}/${group.totalMembers}', // REAL PROGRESS
                subtitle: 'Completed today's habit',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
              Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
        Text(value, style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700, color: Colors.black87)),
      ],
    );
  }
}