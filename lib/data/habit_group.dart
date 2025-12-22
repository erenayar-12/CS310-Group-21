import 'package:cloud_firestore/cloud_firestore.dart';

enum GroupStatus { onTrack, passive }

class HabitGroup {
  const HabitGroup({
    this.id,
    required this.name,
    required this.icon,
    required this.status,
    required this.streak,
    required this.members, // List of UIDs (Strings)
    required this.todayProgress,
    required this.totalMembers,
    this.inviteLink,
    this.description,
    this.createdBy,
    this.createdAt,
  });

  final String? id;
  final String name;
  final String icon;
  final GroupStatus status;
  final int streak;
  final List<String> members;
  final int todayProgress;
  final int totalMembers;
  final String? inviteLink;
  final String? description;
  final String? createdBy;
  final DateTime? createdAt;

  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      'name': name,
      'icon': icon,
      'status': status.name, // Converts enum to "onTrack" or "passive"
      'streak': streak,
      'members': members, // This is your List<String> of UIDs
      'todayProgress': todayProgress,
      'totalMembers': totalMembers,
      'inviteLink': inviteLink,
      'description': description,
      'createdBy': createdBy,
      // Converts DateTime back to a Firestore Timestamp
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  // Factory to convert Firestore data to our class
  static HabitGroup fromFirestore(Map<String, dynamic> map, String id) {
    // Handle Enum safely
    GroupStatus status = GroupStatus.onTrack;
    if (map['status'] != null) {
      status = GroupStatus.values.firstWhere(
            (e) => e.name == map['status'],
        orElse: () => GroupStatus.onTrack,
      );
    }

    // Handle members (UIDs) from your array screenshot
    List<String> membersList = [];
    if (map['members'] != null) {
      membersList = List<String>.from(map['members']);
    }

    // Handle Firebase Timestamps correctly
    DateTime? createdAt;
    if (map['createdAt'] != null && map['createdAt'] is Timestamp) {
      createdAt = (map['createdAt'] as Timestamp).toDate();
    }

    return HabitGroup(
      id: id,
      name: map['name'] ?? '',
      icon: map['icon'] ?? '📖',
      status: status,
      streak: (map['streak'] as num?)?.toInt() ?? 0,
      members: membersList,
      todayProgress: (map['todayProgress'] as num?)?.toInt() ?? 0,
      totalMembers: (map['totalMembers'] as num?)?.toInt() ?? 1,
      inviteLink: map['inviteLink'] as String?,
      description: map['description'] as String?,
      createdBy: map['createdBy'] as String?,
      createdAt: createdAt,
    );
  }
}