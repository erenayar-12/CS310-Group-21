enum HabitFrequency { hourly, daily, weekly, monthly, custom }

class Habit {
  const Habit({
    this.id,
    this.emoji,
    required this.name,
    this.description,
    this.frequency,
    this.customDayCount,
    required this.notifyBeforeHour,
    required this.progress,
    this.isRecurring = true,
    this.streak = 0,
  });

  final int? id;
  final String? emoji;
  final String name;
  final String? description;
  final bool isRecurring;
  final HabitFrequency? frequency;
  final int? customDayCount;
  final bool notifyBeforeHour;
  final double progress;
  final int streak;

  Habit copyWith({
    int? id,
    String? emoji,
    String? name,
    String? description,
    bool? isRecurring,
    HabitFrequency? frequency,
    int? customDayCount,
    bool? notifyBeforeHour,
    double? progress,
    int? streak,
  }) {
    return Habit(
      id: id ?? this.id,
      emoji: emoji ?? this.emoji,
      name: name ?? this.name,
      description: description ?? this.description,
      isRecurring: isRecurring ?? this.isRecurring,
      frequency: frequency ?? this.frequency,
      customDayCount: customDayCount ?? this.customDayCount,
      notifyBeforeHour: notifyBeforeHour ?? this.notifyBeforeHour,
      progress: progress ?? this.progress,
      streak: streak ?? this.streak,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'emoji': emoji,
      'name': name,
      'description': description,
      'is_recurring': isRecurring ? 1 : 0,
      'frequency': frequency?.name,
      'custom_day_count': customDayCount,
      'notify_before_hour': notifyBeforeHour ? 1 : 0,
      'progress': progress,
      'streak': streak,
    };
  }

  static Habit fromMap(Map<String, dynamic> map) {
    final String? frequencyRaw = map['frequency'] as String?;

    HabitFrequency? parsedFrequency;
    if (frequencyRaw != null) {
      for (final freq in HabitFrequency.values) {
        if (freq.name == frequencyRaw) {
          parsedFrequency = freq;
          break;
        }
      }
    }

    return Habit(
      id: map['id'] as int?,
      emoji: map['emoji'] as String?,
      name: map['name'] as String,
      description: map['description'] as String?,
      isRecurring: (map['is_recurring'] as int) == 1,
      frequency: parsedFrequency,
      customDayCount: map['custom_day_count'] as int?,
      notifyBeforeHour: (map['notify_before_hour'] as int) == 1,
      progress: (map['progress'] as num).toDouble(),
      streak: map['streak'] != null ? (map['streak'] as num).toInt() : 0,
    );
  }

  String get remainingLabel {
    final remainingPercent = (1 - progress).clamp(0.0, 1.0);
    final percentLabel = (remainingPercent * 100).round();
    return '$percentLabel% remaining';
  }

  String get streakLabel => 'Current streak: $streak';

  String get frequencyLabel {
    if (!isRecurring && frequency == null) {
      return 'One-time habit';
    }

    if (frequency == null) {
      return 'Recurring habit';
    }

    switch (frequency!) {
      case HabitFrequency.hourly:
        return 'Hourly';
      case HabitFrequency.daily:
        return 'Daily';
      case HabitFrequency.weekly:
        return 'Weekly';
      case HabitFrequency.monthly:
        return 'Monthly';
      case HabitFrequency.custom:
        final dayCount = customDayCount ?? 1;
        return 'Every $dayCount day${dayCount == 1 ? '' : 's'}';
    }
  }
}
