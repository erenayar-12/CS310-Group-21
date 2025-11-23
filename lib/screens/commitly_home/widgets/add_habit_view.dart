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

  String _selectedEmoji = '🎯';
  Color _selectedColor = Colors.blue;
  HabitFrequency _selectedFrequency = HabitFrequency.daily;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  bool _makePublic = true;
  bool _isSubmitting = false;
  bool _isSeeding = false;

  static const List<String> _emojiOptions = [
    '💪',
    '📚',
    '💧',
    '🧘',
    '🏃',
    '🎨',
    '✍️',
    '🎵',
    '🧹',
    '🌱',
    '😴',
    '🍎',
    '🎯',
    '💼',
    '🧠',
    '❤️',
  ];

  static const List<Color> _colorOptions = [
    Color(0xFF22C55E), // green
    Color(0xFF3B82F6), // blue
    Color(0xFFA855F7), // purple
    Color(0xFFEF4444), // red
    Color(0xFFF97316), // orange
    Color(0xFFEC4899), // pink
    Color(0xFF06B6D4), // cyan
    Color(0xFFEAB308), // yellow
  ];

  @override
  void initState() {
    super.initState();
    // Add listeners to update preview in real-time
    _nameController.addListener(() {
      setState(() {});
    });
    _descriptionController.addListener(() {
      setState(() {});
    });
  }

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

    final newHabit = Habit(
      emoji: _selectedEmoji,
      name: name,
      description: description.isEmpty ? null : description,
      frequency: _selectedFrequency,
      customDayCount: null,
      notifyBeforeHour: false,
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
      _selectedEmoji = '🎯';
      _selectedColor = Colors.blue;
      _selectedFrequency = HabitFrequency.daily;
      _reminderTime = const TimeOfDay(hour: 9, minute: 0);
      _makePublic = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: theme.dividerColor,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Habit Title Input
                  _buildSection(
                    label: 'Habit Title *',
                    child: TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'e.g., Morning Exercise',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a habit name';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Description Input
                  _buildSection(
                    label: 'Description',
                    child: TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        hintText: 'e.g., 30 minutes of cardio',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      maxLines: 3,
                      minLines: 3,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Frequency Selector
                  _buildSection(
                    label: 'Frequency',
                    child: DropdownButtonFormField<HabitFrequency>(
                      value: _selectedFrequency,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: HabitFrequency.values.map((frequency) {
                        final text = switch (frequency) {
                          HabitFrequency.hourly => 'Hourly',
                          HabitFrequency.daily => 'Daily',
                          HabitFrequency.weekly => 'Weekly',
                          HabitFrequency.monthly => 'Monthly',
                          HabitFrequency.custom => 'Custom',
                        };
                        return DropdownMenuItem(
                          value: frequency,
                          child: Text(text),
                        );
                      }).toList(),
                      onChanged: (frequency) {
                        if (frequency != null) {
                          setState(() {
                            _selectedFrequency = frequency;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Reminder Time
                  _buildSection(
                    label: 'Reminder Time',
                    child: InkWell(
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _reminderTime,
                        );
                        if (time != null) {
                          setState(() {
                            _reminderTime = time;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        child: Text(
                          _reminderTime.format(context),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Icon Selector
                  _buildSection(
                    label: 'Choose Icon',
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 8,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1,
                      ),
                      itemCount: _emojiOptions.length,
                      itemBuilder: (context, index) {
                        final emoji = _emojiOptions[index];
                        final isSelected = _selectedEmoji == emoji;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedEmoji = emoji;
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.blue.shade500
                                    : Colors.grey.shade300,
                                width: 2,
                              ),
                              color: isSelected
                                  ? Colors.blue.shade50
                                  : Colors.transparent,
                            ),
                            child: Center(
                              child: Text(
                                emoji,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Color Selector
                  _buildSection(
                    label: 'Choose Color',
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 3,
                      ),
                      itemCount: _colorOptions.length,
                      itemBuilder: (context, index) {
                        final color = _colorOptions[index];
                        final isSelected = _selectedColor == color;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedColor = color;
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.grey.shade900
                                    : Colors.white,
                                width: 4,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: Colors.grey.shade400,
                                        blurRadius: 0,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Make Public Switch
                  _buildSection(
                    label: '',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Make Public',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Allow friends to see this habit',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _makePublic,
                          onChanged: (value) {
                            setState(() {
                              _makePublic = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Preview Card
                  _buildSection(
                    label: 'Preview',
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.dividerColor,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _selectedColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                _selectedEmoji,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _nameController.text.isEmpty
                                      ? 'Habit Title'
                                      : _nameController.text,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _descriptionController.text.isEmpty
                                      ? 'Description'
                                      : _descriptionController.text,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _submit,
                      icon: _isSubmitting
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save, size: 18),
                      label: Text(_isSubmitting ? 'Saving...' : 'Save Habit'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),

                  // Load Dummy Habits Button (hidden in card but kept for functionality)
                  if (_isSeeding) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: null,
                        child: const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],
        child,
      ],
    );
  }
}
