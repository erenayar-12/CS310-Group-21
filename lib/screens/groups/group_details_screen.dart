import 'package:flutter/material.dart';

import '../../data/habit_group.dart';
import '../../data/team_member.dart';
import 'widgets/invite_team_members_dialog.dart';

class GroupDetailsScreen extends StatelessWidget {
  final HabitGroup group;

  const GroupDetailsScreen({
    required this.group,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final progress = group.totalMembers > 0
        ? group.todayProgress / group.totalMembers
        : 0.0;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildGroupInfo(),
                    const SizedBox(height: 24),
                    _buildWeeklyProgress(),
                    const SizedBox(height: 24),
                    _buildMembersSection(context),
                    const SizedBox(height: 24),
                    _buildTodayProgress(progress),
                    const SizedBox(height: 24),
                    _buildActions(context),
                    const SizedBox(height: 80), // Space for bottom nav
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.shade600,
            Colors.pink.shade400,
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                group.icon,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: group.status == GroupStatus.onTrack
                            ? Colors.green.shade300
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        group.status == GroupStatus.onTrack
                            ? 'On Track'
                            : 'Passive',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: group.status == GroupStatus.onTrack
                              ? Colors.green.shade900
                              : Colors.grey.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.local_fire_department,
                      color: Colors.orange.shade300,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${group.streak} Day Streak',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Group Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.group, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                '${group.totalMembers} members',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                'Started ${group.streak} days ago',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyProgress() {
    // Dummy weekly data - replace with actual data
    final weeklyData = [2, 3, 1, 4, 3, 2, 4]; // Mon-Sun

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: _WeeklyProgressChart(data: weeklyData),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Members',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  // Show invite dialog
                  showDialog(
                    context: context, // Now context is available
                    builder: (context) => InviteTeamMembersDialog(
                      inviteLink: group.inviteLink ?? 'https://habittracker.app/invite/${group.id}',
                    ),
                  );
                },
                icon: const Icon(Icons.person_add, size: 18),
                label: const Text('Invite'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...group.members.map((member) => _buildMemberRow(member)),
        ],
      ),
    );
  }

  Widget _buildMemberRow(TeamMember member) {
    // Dummy completion status - replace with actual data
    final hasCompletedToday = group.members.indexOf(member) < group.todayProgress;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasCompletedToday ? Colors.green.shade200 : Colors.grey.shade200,
          width: hasCompletedToday ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(member.color),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                member.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name ?? member.initials,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (member.email != null)
                  Text(
                    member.email!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),
          if (hasCompletedToday)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, size: 16, color: Colors.green.shade700),
                  const SizedBox(width: 4),
                  Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Pending',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTodayProgress(double progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Progress",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 12,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.purple.shade600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${group.todayProgress}/${group.totalMembers}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toStringAsFixed(0)}% of members completed today',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context, // This should work if context is passed
                builder: (context) => InviteTeamMembersDialog(
                  inviteLink: group.inviteLink ?? 'https://habittracker.app/invite/${group.id}',
                ),
              );
            },
            icon: const Icon(Icons.person_add),
            label: const Text('Invite Members'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: Implement leave group functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Leave group functionality coming soon')),
              );
            },
            icon: const Icon(Icons.exit_to_app),
            label: const Text('Leave Group'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Weekly Progress Chart Widget
class _WeeklyProgressChart extends StatelessWidget {
  final List<int> data;
  final List<String> labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  _WeeklyProgressChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxValue = data.isEmpty ? 4.0 : data.reduce((a, b) => a > b ? a : b).toDouble().clamp(1.0, 4.0);
    final chartHeight = 160.0;

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 30,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(5, (index) {
                  final value = maxValue - (index * (maxValue / 4));
                  return Text(
                    value.toStringAsFixed(0),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  );
                }).reversed.toList(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: chartHeight,
                child: CustomPaint(
                  painter: _WeeklyChartPainter(data: data, maxValue: maxValue),
                  size: Size(MediaQuery.of(context).size.width - 64, chartHeight),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 38),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: labels.map((label) {
              return SizedBox(
                width: (MediaQuery.of(context).size.width - 64 - 40) / labels.length,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _WeeklyChartPainter extends CustomPainter {
  final List<int> data;
  final double maxValue;

  _WeeklyChartPainter({required this.data, required this.maxValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    // Draw grid lines
    for (int i = 0; i <= 4; i++) {
      final y = size.height - (i * size.height / 4);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Draw bars
    final barWidth = size.width / data.length;
    final barPaint = Paint()..color = Colors.purple.shade600;
    
    for (int i = 0; i < data.length; i++) {
      final barHeight = (data[i] / maxValue) * size.height;
      final x = i * barWidth;
      canvas.drawRect(
        Rect.fromLTWH(x + 10, size.height - barHeight, barWidth - 20, barHeight),
        barPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
