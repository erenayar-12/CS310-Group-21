import 'package:commitly/screens/weekly_tracker/weekly_tracker_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/habit.dart';
import '../../services/firestore_service.dart';
import 'widgets/add_habit_view.dart';
import 'widgets/habit_list_view.dart';
import '../../screens/profile/profile_view.dart';
import '../groups/groups_screen.dart';

class CommitlyHomeScreen extends StatefulWidget {
  const CommitlyHomeScreen({super.key});

  @override
  State<CommitlyHomeScreen> createState() => _CommitlyHomeScreenState();
}

class _CommitlyHomeScreenState extends State<CommitlyHomeScreen> {
  int _currentIndex = 0;
  int? _hoveredHabitIndex;

  Future<void> _handleHabitCreated(Habit habit) async {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    try {
      await firestoreService.createHabit(habit);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Habit created successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create habit: $e')),
      );
    }
  }

  Future<void> _handleDeleteHabit(Habit habit) async {
    if (habit.id == null) return;
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    try {
      await firestoreService.deleteHabit(habit.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${habit.name}" deleted successfully.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete habit: $e')),
      );
    }
  }

  Future<void> _promptHabitCompletion(Habit habit) async {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
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

    if (habit.progress >= 1.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${habit.name}" is already completed today.'),
        ),
      );
      return;
    }

    try {
      final updatedHabit = habit.copyWith(
        progress: 1.0,
        streak: habit.streak + 1,
      );

      if (habit.id != null) {
        await firestoreService.updateHabit(habit.id!, updatedHabit);
        await firestoreService.createHabitCompletion(
          habitId: habit.id!,
          completedAt: DateTime.now(),
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Great job! "${habit.name}" streak is now ${updatedHabit.streak}.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update habit: $e')),
      );
    }
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
    final firestoreService = Provider.of<FirestoreService>(context);
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          StreamBuilder<List<Habit>>(
            stream: firestoreService.getHabitsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return HabitListView(
                  habits: [],
                  hoveredHabitIndex: _hoveredHabitIndex,
                  isLoading: true,
                  onHabitSelected: _promptHabitCompletion,
                  onHoverChanged: _onHoverChanged,
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: ${snapshot.error}'),
                    ],
                  ),
                );
              }

              final habits = snapshot.data ?? [];
              habits.sort((a, b) => (1 - a.progress).compareTo(1 - b.progress));

              return HabitListView(
                habits: habits,
                hoveredHabitIndex: _hoveredHabitIndex,
                isLoading: false,
                onHabitSelected: _promptHabitCompletion,
                onHoverChanged: _onHoverChanged,
                onDelete: _handleDeleteHabit,
                onComplete: _promptHabitCompletion,
              );
            },
          ),
          const WeeklyTrackerPage(),
          AddHabitView(
            onCreateHabit: _handleHabitCreated,
          ),
          const GroupsScreen(),
          const ProfileView(),
        ],
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: const Color(0xFF6A4BFF), // same purple as header
          indicatorColor: Colors.white24,
          labelTextStyle: WidgetStateProperty.resolveWith(
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
