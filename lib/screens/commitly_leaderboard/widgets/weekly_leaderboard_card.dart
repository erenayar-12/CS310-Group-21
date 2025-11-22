import 'package:flutter/material.dart';

class WeeklyLeaderboardCard extends StatelessWidget {
  const WeeklyLeaderboardCard({super.key});

  // Mock leaderboard data, now with color + isYou info
  List<Map<String, dynamic>> get _members => const [
    {
      'rank': '1',
      'name': 'Sarah Chen',
      'xp': '1450 XP',
      'streak': '7-day streak',
      'color': Color(0xFF8B5CF6), // purple
      'isYou': false,
    },
    {
      'rank': '2',
      'name': 'Mike Johnson',
      'xp': '1320 XP',
      'streak': '6-day streak',
      'color': Color(0xFF3B82F6), // blue
      'isYou': false,
    },
    {
      'rank': '3',
      'name': 'Emma Davis',
      'xp': '1200 XP',
      'streak': '5-day streak',
      'color': Color(0xFF22C55E), // green
      'isYou': false,
    },
    {
      'rank': '4',
      'name': 'You',
      'xp': '980 XP',
      'streak': '4-day streak',
      'color': Color(0xFFF97316), // orange
      'isYou': true,
    },
  ];

  String _initialsFor(String name) {
    final parts = name.split(' ');
    if (parts.length == 1) {
      return name.substring(0, 2).toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 0,
        color: const Color(0xFFFFF8E5), // soft yellow like the design
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header area
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left: title + "Group Leaderboard"
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "This Week's Competition",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.emoji_events_outlined,
                            size: 18,
                            color: primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Group Leaderboard',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Right: "This week"
                  Text(
                    'This week',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Rows
            ..._members.map((m) {
              final color = m['color'] as Color;
              final bool isYou = m['isYou'] as bool? ?? false;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        // Rank
                        Text(
                          '#${m['rank']}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Avatar (same colorful style as weekly calendar)
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: color.withOpacity(0.18),
                          child: Text(
                            _initialsFor(m['name'] as String),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Name + streak (+ "You" pill)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    m['name'] as String,
                                    style: theme.textTheme.bodyMedium
                                        ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  if (isYou) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'You',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                m['streak'] as String,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // XP on the right
                        Text(
                          m['xp'] as String,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (m != _members.last)
                    const Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                    ),
                ],
              );
            }),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}