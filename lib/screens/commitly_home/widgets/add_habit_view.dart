import 'package:flutter/material.dart';

import '../../../data/habit.dart';

class AddHabitView extends StatefulWidget {
  const AddHabitView({
    required this.onCreateHabit,
    required this.onSeedDummyHabits,
    super.key,
  });

  final Future<void> Function(Habit) onCreateHabit;
  final Future<void> Function() onSeedDummyHabits;

  @override
  State<AddHabitView> createState() => _AddHabitViewState();
}

class _AddHabitViewState extends State<AddHabitView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController =
      TextEditingController();

  String? _selectedEmoji;
  HabitFrequency _selectedFrequency = HabitFrequency.daily;
  int _customDayCount = 1;
  bool _notifyBeforeHour = false;
  bool _isSubmitting = false;
  bool _isSeeding = false;

  static const List<String> _emojiOptions = [
    '🧘',
    '📚',
    '🏃',
    '🥤',
    '📝',
    '💪',
    '🛏️',
    '🍎',
    '🎧',
    '🧠',
    '🚴',
    '🧹',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final customDayCount = _selectedFrequency == HabitFrequency.custom
        ? _customDayCount
        : null;

    final newHabit = Habit(
      emoji: _selectedEmoji,
      name: name,
      description: description.isEmpty ? null : description,
      frequency: _selectedFrequency,
      customDayCount: customDayCount,
      notifyBeforeHour: _notifyBeforeHour,
      progress: 0.0,
      streak: 0,
    );

    setState(() {
      _isSubmitting = true;
    });

    try {
      await widget.onCreateHabit(newHabit);
      if (!mounted) {
        return;
      }
      _resetForm();
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _seedDummyHabits() async {
    if (_isSeeding) {
      return;
    }

    setState(() {
      _isSeeding = true;
    });

    try {
      await widget.onSeedDummyHabits();
    } finally {
      if (mounted) {
        setState(() {
          _isSeeding = false;
        });
      }
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    FocusScope.of(context).unfocus();
    _nameController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedEmoji = null;
      _selectedFrequency = HabitFrequency.daily;
      _customDayCount = 1;
      _notifyBeforeHour = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Habit',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(
                'Emoji (optional)',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('None'),
                    selected: _selectedEmoji == null,
                    onSelected: (_) {
                      setState(() {
                        _selectedEmoji = null;
                      });
                    },
                  ),
                  ..._emojiOptions.map(
                    (emoji) => ChoiceChip(
                      label: Text(emoji, style: const TextStyle(fontSize: 20)),
                      selected: _selectedEmoji == emoji,
                      onSelected: (selected) {
                        setState(() {
                          _selectedEmoji = selected ? emoji : null;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Habit name',
                  hintText: 'Enter a descriptive name',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a habit name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownMenu<HabitFrequency>(
                initialSelection: _selectedFrequency,
                label: const Text('Frequency'),
                dropdownMenuEntries: HabitFrequency.values.map((frequency) {
                  final text = switch (frequency) {
                    HabitFrequency.hourly => 'Hourly',
                    HabitFrequency.daily => 'Daily',
                    HabitFrequency.weekly => 'Weekly',
                    HabitFrequency.monthly => 'Monthly',
                    HabitFrequency.custom => 'Custom',
                  };
                  return DropdownMenuEntry(value: frequency, label: text);
                }).toList(),
                onSelected: (frequency) {
                  if (frequency == null) {
                    return;
                  }
                  setState(() {
                    _selectedFrequency = frequency;
                  });
                },
              ),
              if (_selectedFrequency == HabitFrequency.custom) ...[
                const SizedBox(height: 16),
                Text(
                  'Custom recurrence days: $_customDayCount',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Slider(
                  value: _customDayCount.toDouble(),
                  min: 1,
                  max: 30,
                  divisions: 29,
                  label: '$_customDayCount days',
                  onChanged: (value) {
                    setState(() {
                      _customDayCount = value.round();
                    });
                  },
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _customDayCount / 30,
                    minHeight: 8,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              CheckboxListTile(
                value: _notifyBeforeHour,
                contentPadding: EdgeInsets.zero,
                title: const Text('Notify me until 1 hour before'),
                onChanged: (value) {
                  setState(() {
                    _notifyBeforeHour = value ?? false;
                  });
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Create Habit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSeeding ? null : _seedDummyHabits,
                      child: _isSeeding
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Load Dummy Habits'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
