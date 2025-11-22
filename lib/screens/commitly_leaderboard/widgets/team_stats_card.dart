import 'package:flutter/material.dart';

class TeamStatsCard extends StatelessWidget {
  const TeamStatsCard({super.key});

  // For now: mock numbers. Later you can pass them in via constructor.
  final int _totalCompletedDays = 23;
  final double _avgStreak = 4.3;
  final int _onTrackCount = 2;
  final int _memberCount = 4;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: const Color(0xFFF5F3FF), // soft purple background
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
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              _StatRow(
                icon: Icons.local_fire_department_outlined,
                iconColor: const Color(0xFFF97316), // orange
                label: 'Total days completed',
                value: '$_totalCompletedDays',
                subtitle: 'All members this week',
              ),

              const Divider(height: 16),

              _StatRow(
                icon: Icons.trending_up_outlined,
                iconColor: const Color(0xFF22C55E), // green
                label: 'Average streak',
                value: '${_avgStreak.toStringAsFixed(1)} days',
                subtitle: 'Per active member',
              ),

              const Divider(height: 16),

              _StatRow(
                icon: Icons.check_circle_outline,
                iconColor: const Color(0xFF3B82F6), // blue
                label: 'On-track members',
                value: '$_onTrackCount/$_memberCount',
                subtitle: 'Completed today’s habit',
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
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: iconColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}