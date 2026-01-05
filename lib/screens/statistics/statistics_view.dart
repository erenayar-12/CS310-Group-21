import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/habit.dart';
import '../../services/firestore_service.dart';
import '../../utils/loading_widgets.dart';
import '../../utils/app_colors.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: StreamBuilder<List<Habit>>(
          stream: context.read<FirestoreService>().getHabitsStream(),
          builder: (context, habitsSnap) {
            if (habitsSnap.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary));
            }
            if (habitsSnap.hasError) {
              return _ErrorView(error: habitsSnap.error.toString());
            }

            final habits = habitsSnap.data ?? [];
            final activeHabitsCount = habits.length;

            final Map<String, String> habitNameMap = {};
            for (final h in habits) {
              if (h.id != null) {
                habitNameMap[h.id!] = h.name ?? 'Unnamed Habit';
              }
            }

            return StreamBuilder<Map<String, dynamic>>(
              stream: context.read<FirestoreService>().getUserStatsStream(),
              builder: (context, statsSnap) {
                final stats = statsSnap.data ?? {};
                final totalXP = (stats['totalXp'] as num?)?.toInt() ?? 0;
                final totalCompletions = (stats['totalCompletions'] as num?)?.toInt() ?? 0;

                return StreamBuilder<List<Map<String, dynamic>>>(
                  stream: context.read<FirestoreService>().getUserCompletionsStream(),
                  builder: (context, compSnap) {

                    if (compSnap.hasError) {
                      debugPrint("Firestore Query Error: ${compSnap.error}");
                      return const Center(child: Text("Loading stats...\n(If this persists, check debug console)", textAlign: TextAlign.center));
                    }

                    if (compSnap.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: AppLoadingIndicator(
                          message: 'Loading statistics...',
                        ),
                      );
                    }

                    final completions = compSnap.data ?? [];

                    // Calculate stats for the GridView
                    final now = DateTime.now();
                    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
                    final weekStart = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));

                    final weeklyCompletionsList = completions.where((c) {
                      final dt = c['completedAt'];
                      if (dt is! DateTime) return false;
                      return dt.isAfter(weekStart) && dt.isBefore(todayEnd);
                    }).toList();

                    final activeHabitIds = habits
                        .where((h) => h.id != null)
                        .map((h) => h.id!)
                        .toSet();

                    final uniqueActiveHabitsCompletedThisWeek = weeklyCompletionsList
                        .map((c) => c['habitId'] as String?)
                        .where((id) => id != null && activeHabitIds.contains(id))
                        .toSet();

                    final avgRate = activeHabitsCount == 0
                        ? 0
                        : ((uniqueActiveHabitsCompletedThisWeek.length / activeHabitsCount) * 100).round();

                    return SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 32),
                      child: Column(
                        children: [
                          const _Header(),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.55,
                              children: [
                                _StatCard(
                                  icon: Icons.star,
                                  label: 'Total XP',
                                  value: '$totalXP',
                                  color: AppColors.primaryPurple,
                                ),
                                _StatCard(
                                  icon: Icons.check_circle,
                                  label: 'Completions',
                                  value: '$totalCompletions',
                                  color: Colors.green,
                                ),
                                _StatCard(
                                  icon: Icons.calendar_today,
                                  label: 'Active Habits',
                                  value: '$activeHabitsCount',
                                  color: Colors.blue,
                                ),
                                _StatCard(
                                  icon: Icons.trending_up,
                                  label: 'Daily Consistency', // Renamed from Avg Rate for clarity
                                  value: '$avgRate%',
                                  color: Colors.orange,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          _WeeklyCompletionCard(
                            completions: completions,
                            activeHabitsCount: activeHabitsCount,
                          ),

                          const SizedBox(height: 24),

                          _HabitBreakdownList(
                            completions: completions,
                            habitNameMap: habitNameMap,
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
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  const _ErrorView({required this.error});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Something went wrong.\n$error', textAlign: TextAlign.center),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 24, 16, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryPurple, AppColors.habitPink],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.bar_chart, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Statistics',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text('Your habit insights',
                    style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const Spacer(),
          Text(label, style: theme.textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// UPDATED WIDGET: Replaces the bar with 7-Day Bubbles
class _WeeklyCompletionCard extends StatelessWidget {
  final List<Map<String, dynamic>> completions;
  final int activeHabitsCount;

  const _WeeklyCompletionCard({
    required this.completions,
    required this.activeHabitsCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    // Helper: Calculate completion % for a specific date
    double getDailyCompletionPercent(DateTime date) {
      if (activeHabitsCount == 0) return 0.0;

      // Filter completions for this specific date (Year/Month/Day match)
      final dailyComps = completions.where((c) {
        final dt = c['completedAt'];
        if (dt is! DateTime) return false;
        return dt.year == date.year &&
            dt.month == date.month &&
            dt.day == date.day;
      }).length;

      // Cap at 1.0 (100%)
      return (dailyComps / activeHabitsCount).clamp(0.0, 1.0);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Consistency Tracker',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              // Optional: A little badge for "Today"
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Today',
                  style: TextStyle(fontSize: 10, color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          LayoutBuilder(
              builder: (context, constraints) {
                final double availableWidth = constraints.maxWidth;
                final double bubbleSize = (availableWidth / 7) - 6; // Subtract spacing

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (index) {
                    final date = now.subtract(Duration(days: 6 - index));
                    final percent = getDailyCompletionPercent(date);

                    final weekdayLetter = ['M','T','W','T','F','S','S'][date.weekday - 1];
                    final isToday = (index == 6);

                    final isPerfect = percent >= 1.0;
                    final isPartial = percent > 0.0 && percent < 1.0;

                    return Column(
                      children: [
                        Container(
                          width: bubbleSize.clamp(28.0, 38.0),
                          height: bubbleSize.clamp(28.0, 38.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isPerfect
                                ? theme.colorScheme.primary
                                : isPartial
                                ? theme.colorScheme.primary.withOpacity(0.4)
                                : theme.colorScheme.surfaceDim,
                            border: isToday
                                ? Border.all(color: theme.colorScheme.primary, width: 2)
                                : null,
                          ),
                          child: Center(
                            child: isPerfect
                                ? const Icon(Icons.check, size: 18, color: Colors.white)
                                : Text(
                              isPartial ? '${(percent * 100).toInt()}' : '', // Show number if partial
                              style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          weekdayLetter,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                            color: isToday ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    );
                  }),
                );
              }
          ),
        ],
      ),
    );
  }
}

class _HabitBreakdownList extends StatelessWidget {
  final List<Map<String, dynamic>> completions;
  final Map<String, String> habitNameMap;

  const _HabitBreakdownList({
    required this.completions,
    required this.habitNameMap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Grouping Logic
    final Map<String, int> counts = {};

    for (final c in completions) {
      final habitId = c['habitId'] as String?;
      final savedName = c['habitName'] as String?;

      String displayName;
      if (savedName != null && savedName.isNotEmpty) {
        displayName = savedName;
      } else if (habitId != null && habitNameMap.containsKey(habitId)) {
        displayName = habitNameMap[habitId]!;
      } else {
        displayName = "Deleted Habit";
      }

      counts[displayName] = (counts[displayName] ?? 0) + 1;
    }

    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Habit Completions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No completions found'),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: entries.length,
              separatorBuilder: (_, __) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final e = entries[index];
                final isDeleted = e.key.startsWith("Deleted");

                return Row(
                  children: [
                    Expanded(
                      child: Text(
                        e.key,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: isDeleted ? theme.colorScheme.onSurface.withOpacity(0.6) : null,
                          fontStyle: isDeleted ? FontStyle.italic : FontStyle.normal,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDeleted ? theme.colorScheme.surfaceDim : theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${e.value}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDeleted ? theme.colorScheme.onSurface : theme.colorScheme.onPrimaryContainer
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}