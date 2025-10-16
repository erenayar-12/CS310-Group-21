import 'package:flutter/material.dart';

import '../../data/habit.dart';
import '../../data/habit_database.dart';
import 'widgets/add_habit_view.dart';
import 'widgets/habit_list_view.dart';
import 'widgets/settings_view.dart';

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
    final habits = await HabitDatabase.instance.fetchHabits();
    if (!mounted) {
      return;
    }

    habits.sort((a, b) => (1 - a.progress).compareTo(1 - b.progress));

    setState(() {
      _habits
        ..clear()
        ..addAll(habits);
      _isLoading = false;
    });
  }

  Future<void> _handleHabitCreated(Habit habit) async {
    await HabitDatabase.instance.createHabit(habit);
    await _loadHabits();
  }

  Future<void> _handleSeedDummyHabits() async {
    await HabitDatabase.instance.seedDummyHabits();
    await _loadHabits();
  }

  Future<void> _handleDeleteSelectedHabits(List<int> habitIds) async {
    if (habitIds.isEmpty) {
      return;
    }

    final deletedCount =
        await HabitDatabase.instance.deleteHabits(habitIds);
    await _loadHabits();

    if (!mounted) {
      return;
    }

    if (deletedCount > 0) {
      final plural = deletedCount == 1 ? '' : 's';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted $deletedCount habit$plural.'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No habits were deleted.'),
        ),
      );
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

    if (!mounted || didComplete != true) {
      return;
    }

    if (habit.id == null) {
      return;
    }

    final updatedHabit =
        await HabitDatabase.instance.completeHabit(habit);
    await _loadHabits();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Great job! "${habit.name}" streak is now ${updatedHabit.streak}.',
        ),
      ),
    );
  }

  void _onHoverChanged(int? index) {
    if (_hoveredHabitIndex == index) {
      return;
    }

    setState(() {
      _hoveredHabitIndex = index;
    });
  }

  void _onNavigationDestinationSelected(int index) {
    if (_currentIndex == index) {
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  String _appBarTitle() {
    switch (_currentIndex) {
      case 1:
        return 'Add Habit';
      case 2:
        return 'Community';
      case 3:
        return 'Team';
      case 4:
        return 'Settings';
      default:
        return 'Commitly';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle()),
        centerTitle: true,
      ),
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
          AddHabitView(
            onCreateHabit: _handleHabitCreated,
            onSeedDummyHabits: _handleSeedDummyHabits,
          ),
          const SizedBox.shrink(),
          const SizedBox.shrink(),
          SettingsView(
            habits: _habits,
            isLoading: _isLoading,
            onDeleteHabits: _handleDeleteSelectedHabits,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onNavigationDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Main',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Add Habit',
          ),
          NavigationDestination(
            icon: Icon(Icons.public_outlined),
            selectedIcon: Icon(Icons.public),
            label: 'Community',
          ),
          NavigationDestination(
            icon: Icon(Icons.group_outlined),
            selectedIcon: Icon(Icons.group),
            label: 'Team',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
