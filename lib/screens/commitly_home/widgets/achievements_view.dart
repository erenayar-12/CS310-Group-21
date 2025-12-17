import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/habit.dart';
import '../../../services/firestore_service.dart';

class AchievementsView extends StatefulWidget {
  const AchievementsView({super.key});

  @override
  State<AchievementsView> createState() => _AchievementsViewState();
}

class _AchievementsViewState extends State<AchievementsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;


  final List<Map<String, dynamic>> _achievements = [
    {
      'id': 'first_habit_created',
      'icon': '🎯',
      'title': 'First Habit',
      'description': 'Create your first habit',
      'xp': 20,
      'type': 'habits_created',
      'threshold': 1,
    },
    {
      'id': 'first_completion',
      'icon': '✅',
      'title': 'First Completion',
      'description': 'Complete a habit once',
      'xp': 30,
      'type': 'first_completion',
      'threshold': 1,
    },
    {
      'id': 'streak_7',
      'icon': '🔥',
      'title': '7 Day Streak',
      'description': 'Maintain a habit for 7 days',
      'xp': 100,
      'type': 'max_streak',
      'threshold': 7,
    },
    {
      'id': 'complete_10',
      'icon': '💪',
      'title': 'Consistency King',
      'description': 'Complete 10 habits',
      'xp': 150,
      'type': 'total_completions',
      'threshold': 10,
    },
    {
      'id': 'complete_50',
      'icon': '⭐',
      'title': 'Power User',
      'description': 'Complete 50 habits',
      'xp': 300,
      'type': 'total_completions',
      'threshold': 50,
    },
    {
      'id': 'streak_30',
      'icon': '🏆',
      'title': 'Champion',
      'description': 'Maintain a 30 day streak',
      'xp': 500,
      'type': 'max_streak',
      'threshold': 30,
    },
    {
      'id': 'complete_100',
      'icon': '👑',
      'title': 'Legendary',
      'description': 'Complete 100 habits',
      'xp': 1000,
      'type': 'total_completions',
      'threshold': 100,
    },
    {
      'id': 'streak_90',
      'icon': '💎',
      'title': 'Diamond Status',
      'description': 'Maintain a 90 day streak',
      'xp': 2000,
      'type': 'max_streak',
      'threshold': 90,
    },
    {
      'id': 'complete_500',
      'icon': '🌟',
      'title': 'Master',
      'description': 'Complete 500 habits',
      'xp': 5000,
      'type': 'total_completions',
      'threshold': 500,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }


  Map<String, int> _computeStats(List<Habit> habits) {
    final habitsCreated = habits.length;

    final maxStreak = habits.isEmpty
        ? 0
        : habits
        .map((h) => (h.streak).round())
        .reduce((a, b) => a > b ? a : b);


    final totalCompletions =
    habits.fold<int>(0, (sum, h) => sum + (h.streak).round());

    final hasFirstCompletion = habits.any((h) => (h.streak).round() >= 1);

    return {
      'habitsCreated': habitsCreated,
      'maxStreak': maxStreak,
      'totalCompletions': totalCompletions,
      'hasFirstCompletion': hasFirstCompletion ? 1 : 0,
    };
  }

  bool _isUnlocked(Map<String, dynamic> a, Map<String, int> stats) {
    final type = a['type'] as String;
    final threshold = a['threshold'] as int;

    switch (type) {
      case 'habits_created':
        return stats['habitsCreated']! >= threshold;
      case 'first_completion':
        return stats['hasFirstCompletion']! >= threshold;
      case 'max_streak':
        return stats['maxStreak']! >= threshold;
      case 'total_completions':
        return stats['totalCompletions']! >= threshold;
      default:
        return false;
    }
  }

  int _remainingToUnlock(Map<String, dynamic> a, Map<String, int> stats) {
    final type = a['type'] as String;
    final threshold = a['threshold'] as int;

    int current;
    switch (type) {
      case 'habits_created':
        current = stats['habitsCreated']!;
        break;
      case 'first_completion':
        current = stats['hasFirstCompletion']!;
        break;
      case 'max_streak':
        current = stats['maxStreak']!;
        break;
      case 'total_completions':
        current = stats['totalCompletions']!;
        break;
      default:
        current = 0;
    }
    return (threshold - current).clamp(0, 1 << 30);
  }

  List<Map<String, dynamic>> _buildUpcomingGoals(
      List<Map<String, dynamic>> locked,
      Map<String, int> stats,
      ) {
    final sorted = [...locked]
      ..sort((a, b) => _remainingToUnlock(a, stats).compareTo(
        _remainingToUnlock(b, stats),
      ));

    return sorted.take(3).map((a) {
      return {
        'name': a['title'],
        'xp': a['xp'],
      };
    }).toList();
  }


  String _getLevelTitle(int level) {
    if (level <= 3) return '🌱 Beginner';
    if (level <= 6) return '🔥 Consistent';
    if (level <= 10) return '⭐ Dedicated';
    return '🏆 Legend';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Habit>>(
        stream: context.read<FirestoreService>().getHabitsStream(),
        builder: (context, snapshot) {
          final theme = Theme.of(context);

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Something went wrong loading achievements.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final List<Habit> habits = snapshot.data ?? const <Habit>[];
          final stats = _computeStats(habits);

          return StreamBuilder<List<String>>(
            stream: context.read<FirestoreService>().getUnlockedAchievementIdsStream(),
            builder: (context, unlockedIdsSnap) {
              final unlockedIds = unlockedIdsSnap.data ?? const <String>[];

              final unlocked = _achievements
                  .where((a) => unlockedIds.contains(a['id'] as String))
                  .toList();

              final locked = _achievements
                  .where((a) => !unlockedIds.contains(a['id'] as String))
                  .toList();

              final unlockedCount = unlocked.length;
              final lockedCount = locked.length;

              final upcomingGoals = _buildUpcomingGoals(locked, stats);

              WidgetsBinding.instance.addPostFrameCallback((_) {
                final fs = context.read<FirestoreService>();
                for (final a in _achievements) {
                  if (_isUnlocked(a, stats)) {
                    fs.grantAchievementXpOnce(
                      achievementId: a['id'] as String,
                      xp: a['xp'] as int,
                    );
                  }
                }
              });

          return StreamBuilder<int>(
            stream: context.read<FirestoreService>().getTotalXpStream(),
            builder: (context, xpSnap) {
              final totalXP = xpSnap.data ?? 0;

              // Level system
              final level = 1 + (totalXP ~/ 100);
              const nextLevelXP = 100;
              final currentXP = totalXP % 100;
              final progressValue = currentXP / nextLevelXP;
              final levelTitle = _getLevelTitle(level);

              return Container(
                color: theme.colorScheme.surface,
                child: Column(
                  children: [
                    // Header
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.brightness == Brightness.dark
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFFFBBF24),
                            theme.brightness == Brightness.dark
                                ? const Color(0xFFEA580C)
                                : const Color(0xFFF97316),
                            theme.brightness == Brightness.dark
                                ? const Color(0xFFDC2626)
                                : const Color(0xFFEF4444),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.arrow_back,
                                        color: Colors.white),
                                    onPressed: () => Navigator.of(context).pop(),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(
                                      Icons.emoji_events,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Achievements & XP',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Level $level • $levelTitle',
                                          style: TextStyle(
                                            color: Colors.white
                                                .withValues(alpha: 0.9),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // XP Progress Card
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Current XP',
                                              style: TextStyle(
                                                color: Colors.white
                                                    .withValues(alpha: 0.8),
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '$currentXP',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              'Next Level',
                                              style: TextStyle(
                                                color: Colors.white
                                                    .withValues(alpha: 0.8),
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            const Text(
                                              '$nextLevelXP',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: LinearProgressIndicator(
                                        value: progressValue,
                                        minHeight: 12,
                                        backgroundColor: Colors.white
                                            .withValues(alpha: 0.2),
                                        valueColor:
                                        AlwaysStoppedAnimation<Color>(
                                          theme.primaryColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${nextLevelXP - currentXP} XP needed for Level ${level + 1}',
                                      style: TextStyle(
                                        color:
                                        Colors.white.withValues(alpha: 0.8),
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Total XP: $totalXP',
                                      style: TextStyle(
                                        color:
                                        Colors.white.withValues(alpha: 0.85),
                                        fontSize: 12,
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

                    // Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Stats Grid
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    icon: Icons.emoji_events,
                                    iconColor: const Color(0xFFCA8A04),
                                    label: 'Unlocked',
                                    value: '$unlockedCount',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatCard(
                                    icon: Icons.star,
                                    iconColor: const Color(0xFF2563EB),
                                    label: 'Total XP',
                                    value: '$totalXP',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatCard(
                                    icon: Icons.local_fire_department,
                                    iconColor: const Color(0xFFEA580C),
                                    label: 'Level',
                                    value: '$level',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Upcoming Goals
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    theme.brightness == Brightness.dark
                                        ? theme.colorScheme.primary
                                        .withValues(alpha: 0.1)
                                        : const Color(0xFFEFF6FF),
                                    theme.brightness == Brightness.dark
                                        ? theme.colorScheme.secondary
                                        .withValues(alpha: 0.1)
                                        : const Color(0xFFFAF5FF),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: theme.dividerColor),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '🎯 Upcoming Goals',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  if (upcomingGoals.isEmpty)
                                    Text(
                                      'All current goals completed 🎉',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: theme.brightness ==
                                            Brightness.dark
                                            ? theme.colorScheme.onSurface
                                            .withValues(alpha: 0.8)
                                            : Colors.grey.shade700,
                                      ),
                                    )
                                  else
                                    ...upcomingGoals.map(
                                          (goal) => Padding(
                                        padding:
                                        const EdgeInsets.only(bottom: 8),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '• ${goal['name']}',
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: theme.brightness ==
                                                      Brightness.dark
                                                      ? theme
                                                      .colorScheme.onSurface
                                                      .withValues(
                                                      alpha: 0.8)
                                                      : Colors.grey.shade700,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Container(
                                              padding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: theme
                                                    .colorScheme.secondary,
                                                borderRadius:
                                                BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                '+${goal['xp']} XP',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: theme.colorScheme
                                                      .onSecondary,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Tabs
                            Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: theme.colorScheme
                                    .surfaceContainerHighest
                                    .withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(3),
                              child: TabBar(
                                controller: _tabController,
                                indicator: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(10),
                                  border:
                                  Border.all(color: theme.dividerColor),
                                ),
                                indicatorSize: TabBarIndicatorSize.tab,
                                labelColor: theme.colorScheme.onSurface,
                                unselectedLabelColor: theme
                                    .colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                                dividerColor: Colors.transparent,
                                labelStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                tabs: [
                                  Tab(text: 'Unlocked ($unlockedCount)'),
                                  Tab(text: 'Locked ($lockedCount)'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            SizedBox(
                              height: 420,
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  _buildAchievementsList(unlocked,
                                      unlockedStyle: true),
                                  _buildAchievementsList(locked,
                                      unlockedStyle: false),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
            },
          );

        },
      ),

    );
  }

  // ---------- UI helpers ----------
  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: theme.brightness == Brightness.dark
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                    : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🏆', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text(
                'Complete habits to unlock achievements!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.brightness == Brightness.dark
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                      : Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementsList(
      List<Map<String, dynamic>> list, {
        required bool unlockedStyle,
      }) {
    final theme = Theme.of(context);

    if (list.isEmpty) return _buildEmptyState();

    return ListView.builder(
      padding: const EdgeInsets.only(top: 12),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final a = list[index];

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: theme.dividerColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Opacity(
                      opacity: unlockedStyle ? 1.0 : 0.5,
                      child: Text(
                        a['icon'],
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              a['title'],
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (unlockedStyle)
                            Icon(Icons.check_circle,
                                size: 18, color: theme.colorScheme.primary),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        a['description'],
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.brightness == Brightness.dark
                              ? theme.colorScheme.onSurface
                              .withValues(alpha: 0.6)
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '+${a['xp']} XP',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}