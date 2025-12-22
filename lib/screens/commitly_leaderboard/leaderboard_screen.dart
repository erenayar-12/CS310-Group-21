import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/habit_group.dart';
import 'widgets/group_header.dart';
import 'widgets/team_stats_card.dart';
import 'widgets/weekly_calendar.dart';
import 'widgets/weekly_leaderboard_card.dart';
import 'widgets/group_weekly_tracker.dart';
import 'widgets/done_card.dart';

class LeaderboardScreen extends StatelessWidget {
  final HabitGroup group;

  const LeaderboardScreen({required this.group, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<DocumentSnapshot>(
      // Listen to this specific group document for real-time updates
      stream: FirebaseFirestore.instance
          .collection('habitGroups')
          .doc(group.id)
          .snapshots(),
      builder: (context, snapshot) {
        // Use live data from Firestore if available, otherwise use initial data
        final liveGroup = snapshot.hasData && snapshot.data!.exists
            ? HabitGroup.fromFirestore(
            snapshot.data!.data() as Map<String, dynamic>,
            snapshot.data!.id
        )
            : group;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GroupHeader(group: liveGroup),
                  const SizedBox(height: 16),
                  DoneCard(group: liveGroup),
                  const SizedBox(height: 16),
                  WeeklyLeaderboardCard(group: liveGroup),
                  const SizedBox(height: 16),
                  WeeklyCalendar(group: liveGroup),
                  const SizedBox(height: 16),
                  TeamStatsCard(group: liveGroup),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}