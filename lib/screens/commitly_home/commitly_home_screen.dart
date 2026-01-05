import 'package:commitly/screens/weekly_tracker/weekly_tracker_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/habit.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
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
      // Use AlertDialog for success message as per rubric
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Success'),
          content: const Text('Habit created successfully!'),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
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
      // Use AlertDialog for success message as per rubric
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Success'),
          content: Text('"${habit.name}" deleted successfully.'),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
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

      // Use AlertDialog for success message as per rubric
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Great Job!'),
          content: Text(
            '"${habit.name}" streak is now ${updatedHabit.streak}.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
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
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HabitListView(
            hoveredHabitIndex: _hoveredHabitIndex,
            onHabitSelected: _promptHabitCompletion,
            onHoverChanged: _onHoverChanged,
            onDelete: _handleDeleteHabit,
            onComplete: _promptHabitCompletion,
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
          backgroundColor: AppColors.primaryPurple, // same purple as header
          indicatorColor: AppColors.navigationIndicator,
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => AppTextStyles.navigationBarLabel,
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onNavigationDestinationSelected,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: AppColors.navigationIconUnselected),
              selectedIcon: Icon(Icons.home, color: AppColors.navigationIconSelected),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_today_outlined, color: AppColors.navigationIconUnselected),
              selectedIcon: Icon(Icons.calendar_today, color: AppColors.navigationIconSelected),
              label: 'Week',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_circle_outline, color: AppColors.navigationIconUnselected),
              selectedIcon: Icon(Icons.add_circle, color: AppColors.navigationIconSelected),
              label: 'Add',
            ),
            NavigationDestination(
              icon: Icon(Icons.group_outlined, color: AppColors.navigationIconUnselected),
              selectedIcon: Icon(Icons.group, color: AppColors.navigationIconSelected),
              label: 'Groups',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline, color: AppColors.navigationIconUnselected),
              selectedIcon: Icon(Icons.person, color: AppColors.navigationIconSelected),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
