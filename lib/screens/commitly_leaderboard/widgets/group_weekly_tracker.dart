import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/habit_group.dart';
import '../../../services/firestore_service.dart';

class GroupWeeklyTracker extends StatelessWidget {
  final HabitGroup group;

  const GroupWeeklyTracker({required this.group, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) return const SizedBox.shrink();

    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    return StreamBuilder(
      stream: firestoreService.getUserStreamById(currentUserId),
      builder: (context, userSnap) {
        if (!userSnap.hasData || !userSnap.data!.exists) return const SizedBox.shrink();
        final userData = userSnap.data!.data() as Map<String, dynamic>?;

        return StreamBuilder(
          stream: firestoreService.getHabitCompletionsForGroupStream(
            habitId: group.id!,
            userId: currentUserId,
          ),
          builder: (context, completionSnap) {
            final Set<DateTime> dates = (completionSnap.data?.docs ?? [])
                .map((d) {
                  final completedAt = d.data()['completedAt'];
                  if (completedAt is Timestamp) {
                    return _dateOnly(completedAt.toDate());
                  } else if (completedAt is DateTime) {
                    return _dateOnly(completedAt);
                  }
                  return null;
                })
                .where((date) => date != null)
                .cast<DateTime>()
                .toSet();

            // FIX: This now points to the widget defined below
            return _MemberRowUI(
              name: userData?['username'] ?? 'Me',
              color: Color(userData?['color'] ?? 0xFF9C27B0),
              completedDates: dates,
            );
          },
        );
      },
    );
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}

// THE MISSING WIDGET DEFINITION
class _MemberRowUI extends StatelessWidget {
  final String name;
  final Color color;
  final Set<DateTime> completedDates;

  const _MemberRowUI({
    required this.name,
    required this.color,
    required this.completedDates,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final weekDays = List.generate(7, (i) => today.subtract(Duration(days: 6 - i)));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: color.withOpacity(0.2),
                child: Text(name[0], style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Text(name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: weekDays.map((date) {
              bool isDone = completedDates.contains(date);
              bool isToday = date == today;
              return Icon(
                isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 22,
                color: isDone ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}