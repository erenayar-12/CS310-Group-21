import 'package:flutter_test/flutter_test.dart';
import 'package:commitly/data/habit.dart';

void main() {
  group('Habit Model Tests', () {
    test('fromMap creates Habit with valid data', () {
      final map = {
        'id': 'test-id-123',
        'emoji': '🏃',
        'name': 'Morning Run',
        'description': 'Run 5km every morning',
        'is_recurring': 1,
        'frequency': 'daily',
        'custom_day_count': null,
        'notify_before_hour': 1,
        'progress': 0.75,
        'streak': 10,
        'createdBy': 'user123',
        'createdAt': '2024-01-15T10:30:00.000Z',
      };

      final habit = Habit.fromMap(map);

      expect(habit.id, 'test-id-123');
      expect(habit.emoji, '🏃');
      expect(habit.name, 'Morning Run');
      expect(habit.description, 'Run 5km every morning');
      expect(habit.isRecurring, true);
      expect(habit.frequency, HabitFrequency.daily);
      expect(habit.customDayCount, null);
      expect(habit.notifyBeforeHour, true);
      expect(habit.progress, 0.75);
      expect(habit.streak, 10);
      expect(habit.createdBy, 'user123');
      expect(habit.createdAt, isNotNull);
    });

    test('fromMap handles null values correctly', () {
      final map = {
        'name': 'Simple Habit',
        'is_recurring': 0,
        'notify_before_hour': 0,
        'progress': 0.0,
        'streak': 0,
      };

      final habit = Habit.fromMap(map);

      expect(habit.id, null);
      expect(habit.emoji, null);
      expect(habit.description, null);
      expect(habit.isRecurring, false);
      expect(habit.frequency, null);
      expect(habit.customDayCount, null);
      expect(habit.notifyBeforeHour, false);
      expect(habit.progress, 0.0);
      expect(habit.streak, 0);
      expect(habit.createdBy, null);
      expect(habit.createdAt, null);
    });

    test('fromMap handles different frequency types', () {
      final frequencies = [
        'hourly',
        'daily',
        'weekly',
        'monthly',
        'custom',
      ];

      for (final freqStr in frequencies) {
        final map = {
          'name': 'Test Habit',
          'is_recurring': 1,
          'frequency': freqStr,
          'custom_day_count': freqStr == 'custom' ? 3 : null,
          'notify_before_hour': 1,
          'progress': 0.5,
          'streak': 5,
        };

        final habit = Habit.fromMap(map);
        expect(habit.frequency, isNotNull);
        
        if (freqStr == 'custom') {
          expect(habit.customDayCount, 3);
        }
      }
    });

    test('toMap converts Habit to Map correctly', () {
      final habit = Habit(
        id: 'test-id',
        emoji: '📚',
        name: 'Read Book',
        description: 'Read 30 pages',
        frequency: HabitFrequency.daily,
        notifyBeforeHour: true,
        progress: 0.6,
        streak: 7,
        createdBy: 'user456',
        createdAt: DateTime(2024, 1, 15, 10, 30),
      );

      final map = habit.toMap();

      expect(map['id'], 'test-id');
      expect(map['emoji'], '📚');
      expect(map['name'], 'Read Book');
      expect(map['description'], 'Read 30 pages');
      expect(map['is_recurring'], 1);
      expect(map['frequency'], 'daily');
      expect(map['notify_before_hour'], 1);
      expect(map['progress'], 0.6);
      expect(map['streak'], 7);
      expect(map['createdBy'], 'user456');
      expect(map['createdAt'], isNotNull);
    });

    test('toMap and fromMap round-trip conversion preserves data', () {
      final originalHabit = Habit(
        id: 'round-trip-id',
        emoji: '💪',
        name: 'Workout',
        description: 'Gym session',
        frequency: HabitFrequency.weekly,
        customDayCount: null,
        notifyBeforeHour: false,
        progress: 0.9,
        streak: 20,
        createdBy: 'user789',
        createdAt: DateTime(2024, 2, 1, 8, 0),
      );

      // Convert to map and back
      final map = originalHabit.toMap();
      final recreatedHabit = Habit.fromMap(map);

      expect(recreatedHabit.id, originalHabit.id);
      expect(recreatedHabit.emoji, originalHabit.emoji);
      expect(recreatedHabit.name, originalHabit.name);
      expect(recreatedHabit.description, originalHabit.description);
      expect(recreatedHabit.isRecurring, originalHabit.isRecurring);
      expect(recreatedHabit.frequency, originalHabit.frequency);
      expect(recreatedHabit.customDayCount, originalHabit.customDayCount);
      expect(recreatedHabit.notifyBeforeHour, originalHabit.notifyBeforeHour);
      expect(recreatedHabit.progress, originalHabit.progress);
      expect(recreatedHabit.streak, originalHabit.streak);
      expect(recreatedHabit.createdBy, originalHabit.createdBy);
      // Compare dates (they might have different formats but same time)
      if (originalHabit.createdAt != null && recreatedHabit.createdAt != null) {
        expect(
          recreatedHabit.createdAt!.toIso8601String(),
          originalHabit.createdAt!.toIso8601String(),
        );
      }
    });

    test('frequencyLabel returns correct labels for different frequencies', () {
      expect(
        Habit(
          name: 'Daily',
          frequency: HabitFrequency.daily,
          notifyBeforeHour: false,
          progress: 0.0,
        ).frequencyLabel,
        'Daily',
      );

      expect(
        Habit(
          name: 'Weekly',
          frequency: HabitFrequency.weekly,
          notifyBeforeHour: false,
          progress: 0.0,
        ).frequencyLabel,
        'Weekly',
      );

      expect(
        Habit(
          name: 'Custom',
          frequency: HabitFrequency.custom,
          customDayCount: 3,
          notifyBeforeHour: false,
          progress: 0.0,
        ).frequencyLabel,
        'Every 3 days',
      );

      expect(
        Habit(
          name: 'Custom Single',
          frequency: HabitFrequency.custom,
          customDayCount: 1,
          notifyBeforeHour: false,
          progress: 0.0,
        ).frequencyLabel,
        'Every 1 day',
      );
    });

    test('remainingLabel calculates correct percentage', () {
      final habit1 = Habit(
        name: 'Test',
        notifyBeforeHour: false,
        progress: 0.25,
      );
      expect(habit1.remainingLabel, '75% remaining');

      final habit2 = Habit(
        name: 'Test',
        notifyBeforeHour: false,
        progress: 1.0,
      );
      expect(habit2.remainingLabel, '0% remaining');

      final habit3 = Habit(
        name: 'Test',
        notifyBeforeHour: false,
        progress: 0.0,
      );
      expect(habit3.remainingLabel, '100% remaining');
    });

    test('streakLabel returns correct format', () {
      final habit = Habit(
        name: 'Test',
        notifyBeforeHour: false,
        progress: 0.0,
        streak: 15,
      );
      expect(habit.streakLabel, 'Current streak: 15');
    });
  });
}

