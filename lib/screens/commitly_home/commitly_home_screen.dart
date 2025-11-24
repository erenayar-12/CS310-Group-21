import 'package:flutter/material.dart';

import '../../data/habit.dart';
import '../../data/habit_database.dart';
import 'widgets/add_habit_view.dart';
import 'widgets/habit_list_view.dart';
// import 'widgets/settings_view.dart';  -> this was placeholder for profile right?
import '../commitly_leaderboard/leaderboard_screen.dart';
import '../../screens/profile/profile_view.dart';

const bool kUseMockHabits = true; // <-- turn OFF DB, use fake data for UI

class CommitlyHomeScreen extends StatefulWidget {
  const CommitlyHomeScreen({super.key});

  @override
  State<CommitlyHomeScreen> createState() => _CommitlyHomeScreenState();
}

class _CommitlyHomeScreenState extends State<CommitlyHomeScreen> {
  int _currentIndex = 0;
  bool _isLoading = true;
  final List<Habit> _habits = [];
  int? _hoveredHabitIndex;

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    if (kUseMockHabits) {
      // 👇 Hard-coded habits to MATCH YOUR WIREFRAME
      final mockHabits = <Habit>[
        Habit(
          emoji: '🏋️‍♂️',
          name: 'Morning Exercise',
          description: '30 minutes of cardio',
          frequency: HabitFrequency.daily,
          notifyBeforeHour: true,
          progress: 0.0,
          streak: 4,
        ),
        Habit(
          emoji: '📚',
          name: 'Read a Book',
          description: 'Read for at least 20 minutes',
          frequency: HabitFrequency.daily,
          notifyBeforeHour: true,
          progress: 0.3,
          streak: 2,
        ),
        Habit(
          emoji: '💧',
          name: 'Drink Water',
          description: '8 glasses throughout the day',
          frequency: HabitFrequency.daily,
          notifyBeforeHour: true,
          progress: 0.6,
          streak: 5,
        ),
      ];

      await Future<void>.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;
      setState(() {
        _habits
          ..clear()
          ..addAll(mockHabits);
        _isLoading = false;
      });
      return;
    }

    // ORIGINAL DB VERSION (kept for later, but not used while kUseMockHabits=true)
    final habits = await HabitDatabase.instance.fetchHabits();
    if (!mounted) return;

    habits.sort((a, b) => (1 - a.progress).compareTo(1 - b.progress));

    setState(() {
      _habits
        ..clear()
        ..addAll(habits);
      _isLoading = false;
    });
  }

  Future<void> _handleHabitCreated(Habit habit) async {
    if (kUseMockHabits) {
      setState(() {
        _habits.add(habit);
      });
      return;
    }

    await HabitDatabase.instance.createHabit(habit);
    await _loadHabits();
  }

  Future<void> _handleSeedDummyHabits() async {
    if (kUseMockHabits) {
      await _loadHabits(); // just reload mock habits
      return;
    }

    await HabitDatabase.instance.seedDummyHabits();
    await _loadHabits();
  }

  Future<void> _handleDeleteSelectedHabits(List<int> habitIds) async {
    if (habitIds.isEmpty) return;

    if (kUseMockHabits) {
      setState(() {
        _habits.removeWhere((h) => h.id != null && habitIds.contains(h.id));
      });
      return;
    }

    final deletedCount = await HabitDatabase.instance.deleteHabits(habitIds);
    await _loadHabits();

    if (!mounted) return;

    if (deletedCount > 0) {
      final plural = deletedCount == 1 ? '' : 's';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted $deletedCount habit$plural.')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No habits were deleted.')));
    }
  }

  Future<void> _promptHabitCompletion(Habit habit) async {
    final bool? didComplete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Habit completed?'),
          content: Text('Mark "${habit.name}" as completed?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('no...'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('YES!'),
            ),
          ],
        );
      },
    );

    if (!mounted || didComplete != true) return;
    if (habit.id == null && !kUseMockHabits) return;

    Habit updatedHabit = habit;

    if (kUseMockHabits) {
      // If already completed today, prevent duplicate streak + progress
      if (habit.progress >= 1.0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${habit.name}" is already completed today.'),
          ),
        );
        return;
      }

      // Mark as fully completed (1.0 means done)
      updatedHabit = habit.copyWith(progress: 1.0, streak: habit.streak + 1);

      setState(() {
        final idx = _habits.indexOf(habit);
        if (idx != -1) _habits[idx] = updatedHabit;
      });
    } else {
      updatedHabit = await HabitDatabase.instance.completeHabit(habit);
      await _loadHabits();
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Great job! "${habit.name}" streak is now ${updatedHabit.streak}.',
        ),
      ),
    );
  }

  void _onHoverChanged(int? index) {
    if (_hoveredHabitIndex == index) return;
    setState(() {
      _hoveredHabitIndex = index;
    });
  }

  void _onNavigationDestinationSelected(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HabitListView(
            habits: _habits,
            hoveredHabitIndex: _hoveredHabitIndex,
            isLoading: _isLoading,
            onHabitSelected: _promptHabitCompletion,
            onHoverChanged: _onHoverChanged,
          ),
          const SizedBox.shrink(),  //week page will come here
          AddHabitView(
            onCreateHabit: _handleHabitCreated,
            onSeedDummyHabits: _handleSeedDummyHabits,
          ),
          const GroupsScreen(),
          const ProfileView(),
        ],
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: const Color(0xFF6A4BFF), // same purple as header
          indicatorColor: Colors.white24,
          labelTextStyle: MaterialStateProperty.resolveWith(
            (states) => const TextStyle(
              color: Colors.white, // labels white
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onNavigationDestinationSelected,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: Colors.white70),
              selectedIcon: Icon(Icons.home, color: Colors.white),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_today_outlined, color: Colors.white70),
              selectedIcon: Icon(Icons.calendar_today, color: Colors.white),
              label: 'Week',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_circle_outline, color: Colors.white70),
              selectedIcon: Icon(Icons.add_circle, color: Colors.white),
              label: 'Add',
            ),
            NavigationDestination(
              icon: Icon(Icons.group_outlined, color: Colors.white70),
              selectedIcon: Icon(Icons.group, color: Colors.white),
              label: 'Groups',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline, color: Colors.white70),
              selectedIcon: Icon(Icons.person, color: Colors.white),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
