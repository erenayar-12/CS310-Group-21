import 'package:flutter/material.dart';

/// MODEL: tracks each member’s completion days
class MemberWeekProgress {
  final String name;
  final String initials;
  final Color color;
  final bool isYou;
  final Set<DateTime> completedDays;

  MemberWeekProgress({
    required this.name,
    required this.initials,
    required this.color,
    this.isYou = false,
    Set<DateTime>? completedDays,
  }) : completedDays = completedDays ?? {};

  int get completedCount => completedDays.length;
}

/// Utility: remove time from a DateTime
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// MAIN WIDGET
class WeeklyCalendar extends StatefulWidget {
  const WeeklyCalendar({super.key});

  @override
  State<WeeklyCalendar> createState() => _WeeklyCalendarState();
}

class _WeeklyCalendarState extends State<WeeklyCalendar> {
  late final List<MemberWeekProgress> members;

  @override
  void initState() {
    super.initState();

    // same users as before
    members = [
      MemberWeekProgress(
        name: "Mike Johnson",
        initials: "MJ",
        color: Colors.blue,
      ),
      MemberWeekProgress(
        name: "Emma Davis",
        initials: "ED",
        color: Colors.green,
      ),
      MemberWeekProgress(
        name: "You",
        initials: "YO",
        color: Colors.deepOrange,
        isYou: true, // <-- only this one should be clickable
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "This Week's Details",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Render each member’s weekly card
          Column(
            children: members
                .map(
                  (m) => _MemberWeekCard(
                member: m,
                onDayTapped: (member, day) =>
                    _handleDayTapped(context, member, day),
              ),
            )
                .toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDayTapped(
      BuildContext context,
      MemberWeekProgress member,
      DateTime day,
      ) async {
    final today = dateOnly(DateTime.now());
    final d = dateOnly(day);

    // 1) Only allow your own user to tap
    if (!member.isYou) return;

    // 2) Only allow tapping *today* box
    if (d != today) return;

    final isCompleted = member.completedDays.contains(d);

    // 3) Ask for confirmation
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          isCompleted ? 'Undo completion?' : 'Mark today as completed?',
        ),
        content: Text(
          isCompleted
              ? 'Do you want to mark today as NOT completed?'
              : 'Do you want to mark today as completed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              isCompleted ? 'Mark as not done' : 'Complete',
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // 4) Toggle completion
    setState(() {
      if (isCompleted) {
        member.completedDays.remove(d);
      } else {
        member.completedDays.add(d);
      }
    });
  }
}

/// ONE PERSON’S CARD
class _MemberWeekCard extends StatelessWidget {
  const _MemberWeekCard({
    required this.member,
    required this.onDayTapped,
  });

  final MemberWeekProgress member;
  final void Function(MemberWeekProgress, DateTime) onDayTapped;

  @override
  Widget build(BuildContext context) {
    final today = dateOnly(DateTime.now());
    final start = today.subtract(const Duration(days: 6));
    final weekDays = List.generate(7, (i) => start.add(Duration(days: i)));

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0E6FF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + name + You badge
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: member.color.withOpacity(0.15),
                child: Text(
                  member.initials,
                  style: TextStyle(
                    color: member.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        member.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      if (member.isYou) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'You',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${member.completedCount}/7 days',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // WEEK BOXES
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: weekDays.map((day) {
              final d = dateOnly(day);
              final isToday = d == today;
              final isCompleted = member.completedDays.contains(d);

              final box = _DayBox(
                label: _dayLabel(d),
                date: d.day.toString(),
                isToday: isToday,
                isCompleted: isCompleted,
                isClickable: member.isYou && isToday, // only your today is "active"
              );

              // Only wrap in GestureDetector if it's your row AND today.
              if (member.isYou && isToday) {
                return GestureDetector(
                  onTap: () => onDayTapped(member, d),
                  child: box,
                );
              } else {
                return box;
              }
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _dayLabel(DateTime d) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels[d.weekday - 1];
  }
}

/// INDIVIDUAL BOX (Fri 31)
class _DayBox extends StatelessWidget {
  const _DayBox({
    required this.label,
    required this.date,
    required this.isToday,
    required this.isCompleted,
    required this.isClickable,
  });

  final String label;
  final String date;
  final bool isToday;
  final bool isCompleted;
  final bool isClickable;

  @override
  Widget build(BuildContext context) {
    final borderColor = isToday ? const Color(0xFF6A4BFF) : Colors.grey.shade300;

    return Opacity(
      // Slightly dim other users if you want (optional)
      opacity: isClickable || !isToday ? 1.0 : 1.0,
      child: Container(
        width: 42,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isCompleted
              ? const Color(0xFF6A4BFF).withOpacity(0.15)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isToday ? const Color(0xFF6A4BFF) : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              date,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),

            // Completed = checkmark, else small "x"
            Icon(
              isCompleted ? Icons.check : Icons.close,
              size: 10,
              color: isCompleted ? const Color(0xFF6A4BFF) : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}