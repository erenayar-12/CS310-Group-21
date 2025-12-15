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
    this.description,
    this.createdBy,
    this.createdAt,
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
  final String? description;
  final String? createdBy; // Firebase user ID
  final DateTime? createdAt; // Timestamp

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
    String? description,
    String? createdBy,
    DateTime? createdAt,
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
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      'name': name,
      'icon': icon,
      'status': status.name,
      'streak': streak,
      'members': members.map((m) => {
        'id': m.id,
        'initials': m.initials,
        'color': m.color,
        'name': m.name,
        'email': m.email,
      }).toList(),
      'todayProgress': todayProgress,
      'totalMembers': totalMembers,
      'inviteLink': inviteLink,
      'description': description,
      'createdBy': createdBy,
      'createdAt': createdAt,
    };
  }

  static HabitGroup fromFirestore(Map<String, dynamic> map, String id) {
    GroupStatus status = GroupStatus.onTrack;
    if (map['status'] != null) {
      try {
        status = GroupStatus.values.firstWhere(
          (e) => e.name == map['status'],
          orElse: () => GroupStatus.onTrack,
        );
      } catch (e) {
        status = GroupStatus.onTrack;
      }
    }

    List<TeamMember> members = [];
    if (map['members'] != null && map['members'] is List) {
      members = (map['members'] as List).map((m) {
        return TeamMember(
          id: m['id'] ?? '',
          initials: m['initials'] ?? '',
          color: m['color'] ?? 0,
          name: m['name'],
          email: m['email'],
        );
      }).toList();
    }

    DateTime? createdAt;
    if (map['createdAt'] != null) {
      if (map['createdAt'] is String) {
        createdAt = DateTime.tryParse(map['createdAt']);
      } else if (map['createdAt'] is DateTime) {
        createdAt = map['createdAt'] as DateTime;
      }
    }

    return HabitGroup(
      id: id,
      name: map['name'] ?? '',
      icon: map['icon'] ?? '📝',
      status: status,
      streak: (map['streak'] as num?)?.toInt() ?? 0,
      members: members,
      todayProgress: (map['todayProgress'] as num?)?.toInt() ?? 0,
      totalMembers: (map['totalMembers'] as num?)?.toInt() ?? members.length,
      inviteLink: map['inviteLink'] as String?,
      description: map['description'] as String?,
      createdBy: map['createdBy'] as String?,
      createdAt: createdAt,
    );
  }
}
