import 'package:commitly/screens/commitly_leaderboard/widgets/team_stats_card.dart';
import 'package:commitly/screens/commitly_leaderboard/widgets/weekly_calendar.dart';
import 'package:commitly/screens/commitly_leaderboard/widgets/weekly_leaderboard_card.dart';
import 'package:flutter/material.dart';

import 'widgets/group_header.dart';
//import 'widgets/weekly_competition_card.dart';
//import 'widgets/members_calendar_section.dart';
//import 'widgets/team_stats_card.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            GroupHeader(),
            SizedBox(height: 16),
            WeeklyLeaderboardCard(),
            SizedBox(height: 16),
            WeeklyCalendar(),
            SizedBox(height: 16),
            TeamStatsCard(),
          ],
        ),
      ),
    );
  }
}