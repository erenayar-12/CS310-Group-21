import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/habit_group.dart';
import '../../../services/firestore_service.dart';

class WeeklyCalendar extends StatelessWidget {
  final HabitGroup group;

  const WeeklyCalendar({required this.group, super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
    final today = dateOnly(DateTime.now());

    // Generate 6 boxes (Starting from Sunday to match your screenshot)
    final startDay = today.subtract(Duration(days: today.weekday % 7));
    final weekDays = List.generate(6, (i) => startDay.add(Duration(days: i)));

    if (currentUserId == null) return const SizedBox.shrink();

    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: StreamBuilder(
        stream: firestoreService.getHabitCompletionsForGroupStream(
          habitId: group.id!,
          userId: currentUserId,
        ),
        builder: (context, snapshot) {
          final completedDates = (snapshot.data?.docs ?? [])
              .map((doc) {
                final completedAt = doc.data()['completedAt'];
                if (completedAt is Timestamp) {
                  return dateOnly(completedAt.toDate());
                } else if (completedAt is DateTime) {
                  return dateOnly(completedAt);
                }
                return null;
              })
              .where((date) => date != null)
              .cast<DateTime>()
              .toSet();

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: weekDays.map((day) {
              return _DayBox(
                dayName: _getDayName(day),
                dayDate: day.day.toString(),
                isToday: dateOnly(day) == today,
                isCompleted: completedDates.contains(dateOnly(day)),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  String _getDayName(DateTime d) => ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d.weekday - 1];
}

class _DayBox extends StatelessWidget {
  final String dayName;
  final String dayDate;
  final bool isToday;
  final bool isCompleted;

  const _DayBox({
    required this.dayName,
    required this.dayDate,
    required this.isToday,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // DYNAMIC COLORS
    final Color completedBg = theme.colorScheme.primaryContainer;
    final Color idleBg = theme.colorScheme.surfaceContainer;
    final Color onCompleted = theme.colorScheme.onPrimaryContainer;

    return Container(
      width: 50, height: 75,
      decoration: BoxDecoration(
        color: isCompleted ? completedBg : idleBg,
        borderRadius: BorderRadius.circular(12),
        border: isToday ? Border.all(color: theme.colorScheme.primary, width: 2) : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(dayName, style: TextStyle(fontSize: 10, color: isCompleted ? onCompleted : theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(dayDate, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isCompleted ? onCompleted : theme.colorScheme.onSurface)),
          if (isCompleted) Icon(Icons.check, size: 14, color: onCompleted),
        ],
      ),
    );
  }
}

