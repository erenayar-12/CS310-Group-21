import 'package:cloud_firestore/cloud_firestore.dart';

/// Model class representing a habit completion record
class HabitCompletion {
  const HabitCompletion({
    this.id,
    required this.habitId,
    this.habitName,
    this.habitEmoji,
    required this.userId,
    required this.completedAt,
    this.notes,
    this.groupId,
  });

  final String? id;
  final String habitId;
  final String? habitName;
  final String? habitEmoji;
  final String userId;
  final DateTime completedAt;
  final String? notes;
  final String? groupId; // For group habit completions

  /// Create HabitCompletion from Firestore document
  factory HabitCompletion.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    final completedAt = data['completedAt'];
    
    DateTime completedAtDateTime;
    if (completedAt is Timestamp) {
      completedAtDateTime = completedAt.toDate();
    } else if (completedAt is DateTime) {
      completedAtDateTime = completedAt;
    } else {
      completedAtDateTime = DateTime.now();
    }

    return HabitCompletion(
      id: doc.id,
      habitId: data['habitId'] as String,
      habitName: data['habitName'] as String?,
      habitEmoji: data['habitEmoji'] as String?,
      userId: data['userId'] as String,
      completedAt: completedAtDateTime,
      notes: data['notes'] as String?,
      groupId: data['groupId'] as String?,
    );
  }

  /// Create HabitCompletion from Map (for local storage or testing)
  factory HabitCompletion.fromMap(Map<String, dynamic> map) {
    final completedAt = map['completedAt'];
    
    DateTime completedAtDateTime;
    if (completedAt is Timestamp) {
      completedAtDateTime = completedAt.toDate();
    } else if (completedAt is DateTime) {
      completedAtDateTime = completedAt;
    } else if (completedAt is String) {
      completedAtDateTime = DateTime.tryParse(completedAt) ?? DateTime.now();
    } else {
      completedAtDateTime = DateTime.now();
    }

    return HabitCompletion(
      id: map['id'] as String?,
      habitId: map['habitId'] as String,
      habitName: map['habitName'] as String?,
      habitEmoji: map['habitEmoji'] as String?,
      userId: map['userId'] as String,
      completedAt: completedAtDateTime,
      notes: map['notes'] as String?,
      groupId: map['groupId'] as String?,
    );
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'habitId': habitId,
      if (habitName != null) 'habitName': habitName,
      if (habitEmoji != null) 'habitEmoji': habitEmoji,
      'userId': userId,
      'completedAt': Timestamp.fromDate(completedAt),
      if (notes != null) 'notes': notes,
      if (groupId != null) 'groupId': groupId,
    };
  }

  /// Convert to Map for local storage
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'habitId': habitId,
      if (habitName != null) 'habitName': habitName,
      if (habitEmoji != null) 'habitEmoji': habitEmoji,
      'userId': userId,
      'completedAt': completedAt.toIso8601String(),
      if (notes != null) 'notes': notes,
      if (groupId != null) 'groupId': groupId,
    };
  }

  /// Create a copy with updated fields
  HabitCompletion copyWith({
    String? id,
    String? habitId,
    String? habitName,
    String? habitEmoji,
    String? userId,
    DateTime? completedAt,
    String? notes,
    String? groupId,
  }) {
    return HabitCompletion(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      habitName: habitName ?? this.habitName,
      habitEmoji: habitEmoji ?? this.habitEmoji,
      userId: userId ?? this.userId,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
      groupId: groupId ?? this.groupId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HabitCompletion &&
        other.id == id &&
        other.habitId == habitId &&
        other.userId == userId &&
        other.completedAt == completedAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, habitId, userId, completedAt);
  }

  @override
  String toString() {
    return 'HabitCompletion(id: $id, habitId: $habitId, habitName: $habitName, userId: $userId, completedAt: $completedAt)';
  }
}
