import 'package:flutter/material.dart';

import '../../../data/habit.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({
    required this.habits,
    required this.isLoading,
    required this.onDeleteHabits,
    super.key,
  });

  final List<Habit> habits;
  final bool isLoading;
  final Future<void> Function(List<int> habitIds) onDeleteHabits;

  void _openHabitEditor(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _HabitEditorSheet(
        habits: habits,
        onDeleteHabits: onDeleteHabits,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              'Manage your habits below.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: habits.isEmpty ? null : () => _openHabitEditor(context),
              icon: const Icon(Icons.edit),
              label: const Text('Edit Habits'),
            ),
            if (habits.isEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'There are no habits to edit yet. Create one from the Add Habit tab.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Theme.of(context).hintColor),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HabitEditorSheet extends StatefulWidget {
  const _HabitEditorSheet({
    required this.habits,
    required this.onDeleteHabits,
  });

  final List<Habit> habits;
  final Future<void> Function(List<int> habitIds) onDeleteHabits;

  @override
  State<_HabitEditorSheet> createState() => _HabitEditorSheetState();
}

class _HabitEditorSheetState extends State<_HabitEditorSheet> {
  final Set<int> _selectedHabitIds = <int>{};
  bool _isDeleting = false;

  Iterable<Habit> get _deletableHabits =>
      widget.habits.where((habit) => habit.id != null);

  void _toggleSelection(Habit habit, bool? selected) {
    final habitId = habit.id;
    if (habitId == null) {
      return;
    }

    setState(() {
      if (selected == true) {
        _selectedHabitIds.add(habitId);
      } else {
        _selectedHabitIds.remove(habitId);
      }
    });
  }

  Future<void> _handleDelete() async {
    if (_isDeleting || _selectedHabitIds.isEmpty) {
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    try {
      await widget.onDeleteHabits(_selectedHabitIds.toList());
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final habits = _deletableHabits.toList();

    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.7,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select habits to delete',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: habits.isEmpty
                    ? Center(
                        child: Text(
                          'No habits available to delete.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Theme.of(context).hintColor),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.separated(
                        itemCount: habits.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final habit = habits[index];
                          final habitId = habit.id!;
                          final isSelected =
                              _selectedHabitIds.contains(habitId);
                          return CheckboxListTile(
                            value: isSelected,
                            onChanged: (selected) =>
                                _toggleSelection(habit, selected),
                            title: Text(habit.name),
                            subtitle: Text(habit.streakLabel),
                            controlAffinity: ListTileControlAffinity.leading,
                          );
                        },
                      ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: (_isDeleting || _selectedHabitIds.isEmpty)
                    ? null
                    : _handleDelete,
                icon: _isDeleting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.delete),
                label: Text(
                  _selectedHabitIds.isEmpty
                      ? 'Delete selected habits'
                      : 'Delete ${_selectedHabitIds.length} habit${_selectedHabitIds.length == 1 ? '' : 's'}',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
