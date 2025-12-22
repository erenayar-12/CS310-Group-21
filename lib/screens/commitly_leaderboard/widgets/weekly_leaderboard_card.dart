import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/habit_group.dart';

class WeeklyLeaderboardCard extends StatelessWidget {
  final HabitGroup group;

  const WeeklyLeaderboardCard({required this.group, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 0,
        color: theme.colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            _buildHeader(theme),
            Divider(height: 1, color: theme.colorScheme.outlineVariant),
            if (group.members.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Text(
                      'No group members yet',
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant)
                  ),
                ),
              )
            else
              ...group.members.map((uid) => StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox.shrink();
                  final data = snapshot.data!.data() as Map<String, dynamic>?;

                  return _LeaderboardItem(
                    name: data?['username'] ?? 'User',
                    color: Color(data?['color'] ?? 0xFF9C27B0),
                    rank: group.members.indexOf(uid) + 1,
                    xp: data?['xp'] ?? 0,
                  );
                },
              )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    "Group Competition",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface // FIX
                    )
                ),
                const SizedBox(height: 4),
                Row(children: [
                  Icon(Icons.emoji_events_outlined, size: 14, color: theme.colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(
                      'Leaderboard',
                      style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant) // FIX
                  ),
                ]),
              ]
          ),
          Text(
              'This week',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 11) // FIX
          ),
        ],
      ),
    );
  }
}

class _LeaderboardItem extends StatelessWidget {
  final String name;
  final Color color;
  final int rank;
  final int xp;

  const _LeaderboardItem({required this.name, required this.color, required this.rank, required this.xp});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(
              '#$rank',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurfaceVariant, // FIX
                  fontSize: 13
              )
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 16,
            backgroundColor: color.withOpacity(0.15),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
                name,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface, // FIX
                    fontSize: 14
                )
            ),
          ),
          Text(
            '$xp XP',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary, // Using primary for XP visibility
                fontSize: 14
            ),
          ),
        ],
      ),
    );
  }
}