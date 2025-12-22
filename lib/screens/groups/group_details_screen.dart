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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final progress = group.totalMembers > 0
        ? group.todayProgress / group.totalMembers
        : 0.0;

    return Scaffold(
      backgroundColor: cs.surface,
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
                    _buildGroupInfo(context),
                    const SizedBox(height: 24),

                    // ✅ Dummy weekly chart yerine açıklama
                    _buildWeeklyProgressPlaceholder(context),
                    const SizedBox(height: 24),

                    _buildMembersSection(context),
                    const SizedBox(height: 24),
                    _buildTodayProgress(context, progress),
                    const SizedBox(height: 24),
                    _buildActions(context),
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
              child: Text(group.icon, style: const TextStyle(fontSize: 24)),
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
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: group.status == GroupStatus.onTrack
                            ? Colors.green.shade300
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        group.status == GroupStatus.onTrack ? 'On Track' : 'Passive',
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
                    Icon(Icons.local_fire_department,
                        color: Colors.orange.shade300, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${group.streak} Day Streak',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
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

  Widget _card(BuildContext context, Widget child) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.25)),
      ),
      child: child,
    );
  }

  Widget _buildGroupInfo(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return _card(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Group Information',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.group, size: 20, color: cs.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                '${group.totalMembers} members',
                style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurface),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 20, color: cs.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                'Started ${group.streak} days ago',
                style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurface),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyProgressPlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return _card(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "This Week's Competition",
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            "Weekly chart data is currently placeholder in the project.\n"
            "Connect it to real completion records when group tracking is implemented.",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersSection(BuildContext context) {
    final theme = Theme.of(context);

    return _card(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Members',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
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
          if (group.members.isEmpty)
            Text(
              'No group members yet',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            )
          else
            ...group.members.map((m) => _buildMemberRow(context, m)),
        ],
      ),
    );
  }

  Widget _buildMemberRow(BuildContext context, TeamMember member) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Not: hasCompletedToday şu an dummy idi. Gerçek completion datası yok.
    // Şimdilik göstermiyoruz; isterseniz ileride gerçek dataya bağlanır.
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.25)),
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
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                if (member.email != null)
                  Text(
                    member.email!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayProgress(BuildContext context, double progress) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return _card(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Progress",
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 12,
                    backgroundColor: cs.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${group.todayProgress}/${group.totalMembers}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toStringAsFixed(0)}% of members completed today',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => InviteTeamMembersDialog(
                  inviteLink: group.inviteLink ?? 'https://habittracker.app/invite/${group.id}',
                ),
              );
            },
            icon: const Icon(Icons.person_add),
            label: const Text('Invite Members'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Leave group functionality coming soon')),
              );
            },
            icon: const Icon(Icons.exit_to_app),
            label: const Text('Leave Group'),
            style: OutlinedButton.styleFrom(
              foregroundColor: cs.error,
              side: BorderSide(color: cs.error.withOpacity(0.6)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}
