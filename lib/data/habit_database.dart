import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'habit.dart';

class HabitDatabase {
  HabitDatabase._internal();

  static final HabitDatabase instance = HabitDatabase._internal();
  static const String _tableName = 'habits';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _init();
    return _database!;
  }

  Future<Database> _init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'commitly.db');
    final dbExists = await databaseExists(path);

    if (!dbExists) {
      await Directory(dirname(path)).create(recursive: true);
    }

    return openDatabase(
      path,
      version: 2,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE $_tableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            emoji TEXT,
            name TEXT NOT NULL,
            description TEXT,
            is_recurring INTEGER NOT NULL,
            frequency TEXT,
            custom_day_count INTEGER,
            notify_before_hour INTEGER NOT NULL,
            progress REAL NOT NULL,
            streak INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE $_tableName ADD COLUMN streak INTEGER NOT NULL DEFAULT 0',
          );
        }
      },
    );
  }

  Future<List<Habit>> fetchHabits() async {
    final db = await database;
    final maps = await db.query(_tableName, orderBy: 'id DESC');
    return maps.map(Habit.fromMap).toList();
  }

  Future<int> createHabit(Habit habit) async {
    final db = await database;
    return db.insert(
      _tableName,
      habit.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateHabit(Habit habit) async {
    if (habit.id == null) {
      throw ArgumentError('Habit.id is required to update the record.');
    }

    final db = await database;
    return db.update(
      _tableName,
      habit.toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  Future<int> deleteHabit(int id) async {
    final db = await database;
    return db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteHabits(List<int> ids) async {
    if (ids.isEmpty) {
      return 0;
    }

    final db = await database;
    final placeholders = List.filled(ids.length, '?').join(', ');
    return db.delete(
      _tableName,
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
  }

  Future<Habit> completeHabit(Habit habit) async {
    if (habit.id == null) {
      throw ArgumentError('Habit.id is required to complete the habit.');
    }

    final updatedHabit = habit.copyWith(
      progress: 0.0,
      streak: habit.streak + 1,
    );
    await updateHabit(updatedHabit);
    return updatedHabit;
  }

  Future<void> seedDummyHabits() async {
    final db = await database;
    final existing = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $_tableName'),
    );

    if (existing != null && existing > 0) {
      return;
    }

    const dummyHabits = [
      Habit(
        emoji: '🧘',
        name: 'Morning Meditation',
        description: 'Start the day with 10 minutes of mindfulness.',
        isRecurring: true,
        frequency: HabitFrequency.daily,
        notifyBeforeHour: true,
        progress: 0.4,
        streak: 0,
      ),
      Habit(
        emoji: '📚',
        name: 'Read 20 Pages',
        description: 'Grow by reading daily.',
        isRecurring: true,
        frequency: HabitFrequency.daily,
        notifyBeforeHour: false,
        progress: 0.65,
        streak: 0,
      ),
      Habit(
        emoji: '🏃',
        name: 'Evening Run',
        description: 'Jog around the park.',
        isRecurring: true,
        frequency: HabitFrequency.weekly,
        notifyBeforeHour: false,
        progress: 0.2,
        streak: 0,
      ),
      Habit(
        emoji: '🥤',
        name: 'Hydration Boost',
        description: 'Drink a full glass of water every hour.',
        isRecurring: true,
        frequency: HabitFrequency.hourly,
        notifyBeforeHour: true,
        progress: 0.8,
        streak: 0,
      ),
    ];

    for (final habit in dummyHabits) {
      await db.insert(_tableName, habit.toMap());
    }
  }

  Future<void> deleteAll() async {
    final db = await database;
    await db.delete(_tableName);
  }
}
