import 'team_member.dart';

enum GroupStatus { onTrack, passive }

class HabitGroup {
  const HabitGroup({
    this.id,
    required this.name,
    required this.icon,
    required this.status,
    required this.streak,
    required this.members,
    required this.todayProgress,
    required this.totalMembers,
    this.inviteLink,
  });

  final String? id;
  final String name;
  final String icon; // Emoji or icon identifier
  final GroupStatus status;
  final int streak;
  final List<TeamMember> members;
  final int todayProgress; // Number of members who completed today
  final int totalMembers;
  final String? inviteLink;

  HabitGroup copyWith({
    String? id,
    String? name,
    String? icon,
    GroupStatus? status,
    int? streak,
    List<TeamMember>? members,
    int? todayProgress,
    int? totalMembers,
    String? inviteLink,
  }) {
    return HabitGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      status: status ?? this.status,
      streak: streak ?? this.streak,
      members: members ?? this.members,
      todayProgress: todayProgress ?? this.todayProgress,
      totalMembers: totalMembers ?? this.totalMembers,
      inviteLink: inviteLink ?? this.inviteLink,
    );
  }
}
