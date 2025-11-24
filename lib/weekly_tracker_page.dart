import 'package:flutter/material.dart';

/// Weekly Tracker page designed to match the PDF UI.
class WeeklyTrackerPage extends StatefulWidget {
  const WeeklyTrackerPage({super.key});

  @override
  State<WeeklyTrackerPage> createState() => _WeeklyTrackerPageState();
}

/// Local model ONLY for this screen – intentionally named
/// differently from your app's Habit model to avoid conflicts.
class WeeklyHabit {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  /// Status for each day of the week:
  ///  1 = completed (green)
  ///  0 = missed (X)
  /// -1 = future/disabled (grey)
  final List<int> dayStatuses;

  /// Target number of days per week (used in "This Week: X / target").
  final int targetPerWeek;

  WeeklyHabit({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.dayStatuses,
    this.targetPerWeek = 5,
  });
}

class _WeeklyTrackerPageState extends State<WeeklyTrackerPage> {
  int weekOffset = 0; // 0 = current week (just visual for now)

  final List<String> _dayNames = const ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  final List<int> _dayNumbers = const [2, 3, 4, 5, 6, 7, 8]; // same as in PDF screenshot

  // Sample habits mimicking the PDF design
  late List<WeeklyHabit> _habits;

  @override
  void initState() {
    super.initState();
    _habits = [
      WeeklyHabit(
        title: 'Morning Exercise',
        subtitle: '30 minutes of cardio',
        icon: Icons.fitness_center,
        color: const Color(0xFF31C36A),
        // Sun..Sat: X, X, ✓, ✓, ✓, (future), (future)
        dayStatuses: [0, 0, 1, 1, 1, -1, -1],
      ),
      WeeklyHabit(
        title: 'Read a Book',
        subtitle: 'Read for at least 20 minutes',
        icon: Icons.menu_book_rounded,
        color: const Color(0xFF1F8CFF),
        // Sun..Sat: X, X, X, ✓, X, (future), (future)
        dayStatuses: [0, 0, 0, 1, 0, -1, -1],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    const gradient = LinearGradient(
      colors: [Color(0xFF8A36FF), Color(0xFF3F6FFF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            // ---------------- HEADER (gradient) ----------------
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SizedBox(height: 4),
                  Text(
                    'Weekly Tracker',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Track your habit completion for the week',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ---------------- DATE RANGE CARD ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 1.5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () {
                          setState(() => weekOffset--);
                        },
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'November 2 - November 8, 2025',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            TextButton(
                              onPressed: () {
                                setState(() => weekOffset = 0);
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                              ),
                              child: const Text(
                                'Go to Current Week',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () {
                          setState(() => weekOffset++);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ---------------- HABIT CARDS LIST ----------------
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _habits.length,
                itemBuilder: (context, index) {
                  final habit = _habits[index];
                  return _buildHabitCard(habit, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitCard(WeeklyHabit habit, int habitIndex) {
    final completedCount = habit.dayStatuses.where((s) => s == 1).length;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1.5,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- Title row with icon ----
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: habit.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(habit.icon, color: habit.color, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        habit.subtitle,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ---- Days row ----
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(7, (dayIndex) {
                  final status = habit.dayStatuses[dayIndex];
                  final isCompleted = status == 1;
                  final isFuture = status == -1;

                  Color bgColor;
                  Color borderColor;
                  Color textColor;
                  Widget bottomWidget;

                  if (isFuture) {
                    bgColor = Colors.grey.shade200;
                    borderColor = Colors.grey.shade300;
                    textColor = Colors.grey.shade400;
                    bottomWidget = const SizedBox(height: 14);
                  } else if (isCompleted) {
                    bgColor = const Color(0xFF31C36A);
                    borderColor = const Color(0xFF29A658);
                    textColor = Colors.white;
                    bottomWidget = const Icon(Icons.check, size: 14, color: Colors.white);
                  } else {
                    bgColor = Colors.white;
                    borderColor = Colors.grey.shade300;
                    textColor = Colors.black87;
                    bottomWidget = Text(
                      'X',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }

                  return GestureDetector(
                    onTap: () {
                      if (isFuture) return; // do not toggle future days
                      setState(() {
                        // toggle 0 <-> 1
                        habit.dayStatuses[dayIndex] =
                            habit.dayStatuses[dayIndex] == 1 ? 0 : 1;
                      });
                    },
                    child: Container(
                      width: 52,
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: borderColor, width: 1.1),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _dayNames[dayIndex],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _dayNumbers[dayIndex].toString(),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          bottomWidget,
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 12),

            // ---- This Week summary ----
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'This Week:',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  '$completedCount / ${habit.targetPerWeek} days',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

