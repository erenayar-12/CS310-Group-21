import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/habit_group.dart';
import '../../data/team_member.dart';
import 'widgets/invite_team_members_dialog.dart';
import 'group_details_screen.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  // Dummy data - replace with actual data source
  final List<TeamMember> _teamMembers = [
    const TeamMember(id: '1', initials: 'SC', color: 0xFF9C27B0), // Purple
    const TeamMember(id: '2', initials: 'MJ', color: 0xFF2196F3), // Blue
    const TeamMember(id: '3', initials: 'ED', color: 0xFF4CAF50), // Green
    const TeamMember(id: '4', initials: 'ME', color: 0xFFFF9800), // Orange
  ];

  final List<HabitGroup> _habitGroups = [
    HabitGroup(
      id: '1',
      name: 'Study Together',
      icon: '📚💻',
      status: GroupStatus.onTrack,
      streak: 8,
      members: [
        const TeamMember(id: '1', initials: 'SC', color: 0xFF9C27B0),
        const TeamMember(id: '2', initials: 'MJ', color: 0xFF2196F3),
        const TeamMember(id: '3', initials: 'ED', color: 0xFF4CAF50),
        const TeamMember(id: '4', initials: 'ME', color: 0xFFFF9800),
      ],
      todayProgress: 2,
      totalMembers: 4,
      inviteLink: 'https://habittracker.app/invite/1',
    ),
    HabitGroup(
      id: '2',
      name: 'Reading Challenge',
      icon: '📖',
      status: GroupStatus.onTrack,
      streak: 5,
      members: [
        const TeamMember(id: '2', initials: 'MJ', color: 0xFF2196F3),
        const TeamMember(id: '3', initials: 'ED', color: 0xFF4CAF50),
        const TeamMember(id: '4', initials: 'ME', color: 0xFFFF9800),
      ],
      todayProgress: 1,
      totalMembers: 3,
      inviteLink: 'https://habittracker.app/invite/2',
    ),
    HabitGroup(
      id: '3',
      name: 'Morning Exercise',
      icon: '🏃',
      status: GroupStatus.onTrack,
      streak: 12,
      members: [
        const TeamMember(id: '1', initials: 'SC', color: 0xFF9C27B0),
        const TeamMember(id: '2', initials: 'MJ', color: 0xFF2196F3),
        const TeamMember(id: '3', initials: 'ED', color: 0xFF4CAF50),
        const TeamMember(id: '4', initials: 'ME', color: 0xFFFF9800),
      ],
      todayProgress: 0,
      totalMembers: 4,
      inviteLink: 'https://habittracker.app/invite/3',
    ),
  ];

  void _showInviteDialog() {
    showDialog(
      context: context,
      builder: (context) => InviteTeamMembersDialog(
        inviteLink: 'https://habittracker.app/invite/1',
      ),
    );
  }

  void _onGroupTap(HabitGroup group) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GroupDetailsScreen(group: group),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100, // Add light background
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildActiveGroupsSection(),
                    const SizedBox(height: 16),
                    _buildInfoBox(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.groups, color: Colors.white, size: 28),
              const SizedBox(width: 8),
              const Text(
                'Habit Groups',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${_habitGroups.length} active groups',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          // Team Members Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Text(
                  'Team Members',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Row(
                  children: _teamMembers.map((member) {
                    return Container(
                      margin: const EdgeInsets.only(left: 4),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Color(member.color),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          member.initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _showInviteDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_add, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Invite',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveGroupsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Active Habit Groups',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to create new group screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 18),
                  SizedBox(width: 4),
                  Text('New Group'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._habitGroups.map((group) => _buildGroupCard(group)),
      ],
    );
  }

  Widget _buildGroupCard(HabitGroup group) {
    final progress = group.totalMembers > 0
        ? group.todayProgress / group.totalMembers
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onGroupTap(group),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
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
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  group.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: group.status == GroupStatus.onTrack
                                      ? Colors.green.shade100
                                      : Colors.grey.shade200,
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
                                        ? Colors.green.shade700
                                        : Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.local_fire_department,
                                color: Colors.orange.shade600,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${group.streak} Day Streak',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.orange.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.group, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${group.totalMembers} members',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.emoji_events, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    const Text(
                      'Tap to view details',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: group.members.map((member) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Color(member.color),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          member.initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Today's Progress",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${group.todayProgress}/${group.totalMembers}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.amber.shade700, size: 24),
              const SizedBox(width: 8),
              const Text(
                'How Habit Groups Work',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoItem(
            'Tap any group to view detailed weekly progress',
          ),
          _buildInfoItem(
            'Compete with team members in real-time',
          ),
          _buildInfoItem(
            'Keep everyone accountable and motivated',
          ),
          _buildInfoItem(
            'Add or remove members from each group',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: 8),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.purple,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
