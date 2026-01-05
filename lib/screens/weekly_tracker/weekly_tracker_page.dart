import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/habit.dart';
import '../../services/firestore_service.dart';
import '../../utils/loading_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WeeklyTrackerPage extends StatefulWidget {
  const WeeklyTrackerPage({super.key});

  @override
  State<WeeklyTrackerPage> createState() => _WeeklyTrackerPageState();
}

class _WeeklyTrackerPageState extends State<WeeklyTrackerPage> {
  int weekOffset = 0;

  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday;
    final daysFromSunday = weekday % 7;
    final weekStart = date.subtract(Duration(days: daysFromSunday));
    return DateTime(weekStart.year, weekStart.month, weekStart.day);
  }

  List<DateTime> _getWeekDays(int offset) {
    final now = DateTime.now();
    final weekStart = _getWeekStart(now.add(Duration(days: offset * 7)));
    return List.generate(7, (i) => weekStart.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firestoreService = Provider.of<FirestoreService>(context);
    final weekDays = _getWeekDays(weekOffset);
    final today = DateTime.now();
    final todayDateOnly = DateTime(today.year, today.month, today.day);

    final start = weekDays.first;
    final end = weekDays.last;
    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    final startStr = '${monthNames[start.month - 1]} ${start.day}';
    final endStr = '${monthNames[end.month - 1]} ${end.day}, ${end.year}';

    final gradient = LinearGradient(
      colors: [
        theme.colorScheme.primary,
        theme.colorScheme.primaryContainer,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    'Weekly Tracker',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Track your habit completion for the week',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary.withOpacity(0.7),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 1.5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () {
                          setState(() => weekOffset--);
                        },
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$startStr - $endStr',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            TextButton(
                              onPressed: () {
                                setState(() => weekOffset = 0);
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                              ),
                              child: const Text(
                                'Go to Current Week',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () {
                          setState(() => weekOffset++);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: StreamBuilder<List<Habit>>(
                stream: firestoreService.getHabitsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SkeletonListLoader(
                      itemCount: 3,
                      itemBuilder: (context, index) => SkeletonHabitCard(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  final habits = snapshot.data ?? [];
                  
                  if (habits.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          'Weekly tracker will show your habits here.\nCreate habits to see them tracked weekly.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: habits.length,
                    itemBuilder: (context, index) {
                      return _buildHabitCard(habits[index], weekDays, todayDateOnly, firestoreService);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitCard(Habit habit, List<DateTime> weekDays, DateTime todayDateOnly, FirestoreService firestoreService) {
    final theme = Theme.of(context);

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: habit.id != null
          ? firestoreService.getHabitCompletionsStream(habit.id!)
          : Stream.value([]),
      builder: (context, completionsSnapshot) {
        final completions = completionsSnapshot.data ?? [];
        final completedDates = completions
            .map((c) {
          final dynamic completedAtData = c['completedAt'];
          if (completedAtData is Timestamp) { // Now 'Timestamp' will be recognized
            return completedAtData.toDate();
          } else if (completedAtData is DateTime) {
            return completedAtData;
          }
          return null;
        })
            .whereType<DateTime>()
            .map((date) => DateTime(date.year, date.month, date.day))
            .toSet();

        final completedCount = weekDays.where((day) {
          final dayDateOnly = DateTime(day.year, day.month, day.day);
          return completedDates.contains(dayDateOnly);
        }).length;

        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 1.5,
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          habit.emoji ?? '📝',
                          style: const TextStyle(fontSize: 26),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habit.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            habit.description ?? habit.frequencyLabel,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(7, (dayIndex) {
                      final day = weekDays[dayIndex];
                      final dayDateOnly = DateTime(day.year, day.month, day.day);
                      final isToday = dayDateOnly == todayDateOnly;
                      final isFuture = dayDateOnly.isAfter(todayDateOnly);
                      final isCompleted = completedDates.contains(dayDateOnly);

                      Color bgColor;
                      Color borderColor;
                      Color textColor;
                      Widget bottomWidget;

                      if (isFuture) {
                        bgColor = theme.colorScheme.surfaceContainerHighest;
                        borderColor = theme.colorScheme.outlineVariant;
                        textColor = theme.colorScheme.onSurfaceVariant.withOpacity(0.5);
                        bottomWidget = const SizedBox(height: 14);
                      } else if (isCompleted) {
                        bgColor = theme.colorScheme.primary;
                        borderColor = theme.colorScheme.primary;
                        textColor = theme.colorScheme.onPrimary;
                        bottomWidget = Icon(
                          Icons.check,
                          size: 14,
                          color: theme.colorScheme.onPrimary,
                        );
                      } else {
                        bgColor = theme.colorScheme.surface;
                        borderColor = theme.colorScheme.outlineVariant;
                        textColor = theme.colorScheme.onSurface;
                        bottomWidget = Text(
                          'X',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }

                      return Container(
                        width: 52,
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isToday ? Colors.blue : borderColor,
                            width: isToday ? 2 : 1.1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][dayIndex],
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              day.day.toString(),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            bottomWidget,
                          ],
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'This Week:',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '$completedCount / 7 days',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
