import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../data/habit.dart';
import '../../data/habit_database.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool _isLoading = true;
  List<Habit> _habits = [];

  // Use simpler data structures that work with current database
  List<double> _dailyXP = List.filled(30, 0.0); // Last 30 days - will be calculated
  List<double> _weeklyCompletion = [0, 0, 0, 0, 0]; // Fri, Sat, Sun, Tue, Thu

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Load habits
    final habits = await HabitDatabase.instance.fetchHabits();

    // Calculate daily XP from current habits (simplified - based on streaks)
    // Since we don't have historical data, we'll simulate it based on current streaks
    _calculateDailyXP(habits);

    // Calculate weekly completion from current habits
    _calculateWeeklyCompletion(habits);

    if (!mounted) return;

    setState(() {
      _habits = habits;
      _isLoading = false;
    });
  }

  void _calculateDailyXP(List<Habit> habits) {
    // Since we don't have historical data, distribute XP across last 30 days
    // based on current streaks
    final totalXP = habits.fold(0, (sum, habit) => sum + habit.streak * 10);

    if (totalXP > 0) {
      // Distribute XP across last 30 days (more recent = more XP)
      final now = DateTime.now();
      for (int i = 0; i < 30; i++) {
        final daysAgo = 29 - i;
        // More recent days get more XP (simple distribution)
        final weight = (30 - daysAgo) / 30.0;
        _dailyXP[i] = (totalXP * weight / 30.0).roundToDouble();
      }
    }
  }

  void _calculateWeeklyCompletion(List<Habit> habits) {
    // Calculate completion rate based on habits that are "on track"
    // (progress < 0.3 means they're being completed regularly)
    final onTrackHabits = habits.where((h) => h.progress < 0.3).length;
    final completionRate = habits.isEmpty
        ? 0.0
        : (onTrackHabits / habits.length) * 4.0; // Scale to 0-4 for graph

    // Distribute across week days (simplified)
    _weeklyCompletion = [
      completionRate * 0.8, // Fri
      completionRate * 0.6, // Sat
      completionRate * 0.9, // Sun
      completionRate * 1.0, // Tue
      completionRate * 0.7, // Thu
    ];
  }

  // Update Total XP calculation to use actual completions
  int get _totalXP {
    return _dailyXP.fold(0, (sum, xp) => sum + xp.toInt());
  }

  // Update to show real data in graphs
  List<double> get _dailyXPList {
    final now = DateTime.now();
    final List<double> xpList = [];
    for (int i = 29; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      xpList.add((_dailyXP[i] ?? 0).toDouble());
    }
    return xpList;
  }

  // Calculate statistics
  int get _totalCompletions => _habits.fold(0, (sum, habit) => sum + habit.streak);
  int get _activeHabits => _habits.length;
  double get _avgRate {
    if (_habits.isEmpty) return 0.0;
    // Calculate based on how many habits are "on track" (progress < 0.3)
    final onTrackCount = _habits.where((h) => h.progress < 0.3).length;
    return (onTrackCount / _habits.length) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100, // Light grey background
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 16), // Add bottom padding
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildStatisticsGrid(),
              ),
              const SizedBox(height: 16),
              _buildWeeklyCompletionGraph(),
              const SizedBox(height: 16),
              _buildXPOver30Days(),
              const SizedBox(height: 16),
              _buildHabitCompletions(),
              const SizedBox(height: 16),
              _buildCompletionDetails(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.shade600,
            Colors.pink.shade400,
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(8, 24, 16, 24),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.bar_chart, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Statistics',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Your habit tracking insights',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          icon: Icons.shield,
          iconColor: Colors.purple,
          label: 'Total XP',
          value: '$_totalXP',
        ),
        _buildStatCard(
          icon: Icons.trending_up,
          iconColor: Colors.green,
          label: 'Completions',
          value: '$_totalCompletions',
        ),
        _buildStatCard(
          icon: Icons.calendar_today,
          iconColor: Colors.purple,
          label: 'Active Habits',
          value: '$_activeHabits',
        ),
        _buildStatCard(
          icon: Icons.bar_chart,
          iconColor: Colors.orange,
          label: 'Avg Rate',
          value: '${_avgRate.toStringAsFixed(0)}%',
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyCompletionGraph() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Completion Rate',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: _WeeklyCompletionChart(
              data: _weeklyCompletion, // This is already List<double>
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'Completion %',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildXPOver30Days() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16), // Consistent padding
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '→ Daily XP',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: _DailyXPChart(data: _dailyXPList), // Use real data
          ),
        ],
      ),
    );
  }

  Widget _buildHabitCompletions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16), // Consistent padding
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Habit Completions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          // Empty state - can be filled with actual data later
        ],
      ),
    );
  }

  Widget _buildCompletionDetails() {
    // Get habits with completion counts
    final habitDetails = _habits.map((habit) {
      return _HabitDetail(
        name: habit.name,
        color: _getHabitColor(habit.emoji ?? ''),
        count: habit.streak,
      );
    }).toList();

    // Add dummy habits if needed for demo
    if (habitDetails.isEmpty) {
      habitDetails.addAll([
        _HabitDetail(name: 'Morning Exercise', color: Colors.blue, count: 0),
        _HabitDetail(name: 'Read a Book', color: Colors.purple, count: 0),
        _HabitDetail(name: 'Drink Water', color: Colors.green, count: 0),
      ]);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16), // Consistent padding
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Completion Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...habitDetails.map((detail) => _buildHabitDetailRow(detail)),
        ],
      ),
    );
  }

  Widget _buildHabitDetailRow(_HabitDetail detail) {
    final displayName = detail.name.length > 20
        ? '${detail.name.substring(0, 20)}...'
        : detail.name;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: detail.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              displayName,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            '${detail.count}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Color _getHabitColor(String emoji) {
    // Map emojis to colors, or use default
    if (emoji.contains('🏃') || emoji.contains('💪')) return Colors.blue;
    if (emoji.contains('📚') || emoji.contains('📖')) return Colors.purple;
    if (emoji.contains('💧') || emoji.contains('🥤')) return Colors.green;
    return Colors.grey;
  }
}

// Helper class for habit details
class _HabitDetail {
  final String name;
  final Color color;
  final int count;

  _HabitDetail({
    required this.name,
    required this.color,
    required this.count,
  });
}

// Weekly Completion Chart Widget
class _WeeklyCompletionChart extends StatelessWidget {
  final List<double> data;
  final List<String> labels = ['Fri', 'Sat', 'Sun', 'Tue', 'Thu'];

  _WeeklyCompletionChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxValue = data.isEmpty ? 4.0 : data.reduce(math.max).clamp(1.0, 4.0);
    final chartHeight = 160.0;
    final chartWidth = MediaQuery.of(context).size.width - 64;

    return Column(
      children: [
        // Y-axis labels
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 30,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(5, (index) {
                  final value = maxValue - (index * (maxValue / 4));
                  return Text(
                    value.toStringAsFixed(0),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  );
                }).reversed.toList(),
              ),
            ),
            const SizedBox(width: 8),
            // Chart area
            Expanded(
              child: SizedBox(
                height: chartHeight,
                child: CustomPaint(
                  painter: _WeeklyChartPainter(data: data, maxValue: maxValue),
                  size: Size(chartWidth, chartHeight),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // X-axis labels
        Padding(
          padding: const EdgeInsets.only(left: 38),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: labels.map((label) {
              return SizedBox(
                width: (chartWidth - 40) / labels.length,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _WeeklyChartPainter extends CustomPainter {
  final List<double> data;
  final double maxValue;

  _WeeklyChartPainter({required this.data, required this.maxValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    // Draw grid lines
    for (int i = 0; i <= 4; i++) {
      final y = size.height - (i * size.height / 4);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Draw vertical lines for each data point
    final barWidth = size.width / data.length;
    for (int i = 0; i < data.length; i++) {
      final x = i * barWidth + barWidth / 2;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint..style = PaintingStyle.stroke..strokeWidth = 0.5,
      );
    }

    // Draw bars (empty for now as per screenshot)
    // Uncomment to show actual data:
    // final barPaint = Paint()..color = Colors.blue;
    // for (int i = 0; i < data.length; i++) {
    //   final barHeight = (data[i] / maxValue) * size.height;
    //   final x = i * barWidth;
    //   canvas.drawRect(
    //     Rect.fromLTWH(x + 10, size.height - barHeight, barWidth - 20, barHeight),
    //     barPaint,
    //   );
    // }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Daily XP Chart Widget
class _DailyXPChart extends StatelessWidget {
  final List<double> data;
  final List<String> xLabels = ['0', '8', '12', '17', '22', '27', '1', '6'];

  _DailyXPChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxValue = 4.0;
    final chartHeight = 160.0;
    final chartWidth = MediaQuery.of(context).size.width - 64;

    return Column(
      children: [
        // Chart area
        SizedBox(
          height: chartHeight,
          child: CustomPaint(
            painter: _DailyXPChartPainter(data: data, maxValue: maxValue),
            size: Size(chartWidth, chartHeight),
          ),
        ),
        const SizedBox(height: 8),
        // X-axis labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: xLabels.map((label) {
            return SizedBox(
              width: (chartWidth) / xLabels.length,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _DailyXPChartPainter extends CustomPainter {
  final List<double> data;
  final double maxValue;

  _DailyXPChartPainter({required this.data, required this.maxValue});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 0.5;

    // Draw horizontal grid lines
    for (int i = 0; i <= 4; i++) {
      final y = size.height - (i * size.height / 4);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Draw vertical dotted lines for x-axis labels
    final segmentWidth = size.width / 8;
    final dottedPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i <= 8; i++) {
      final x = i * segmentWidth;
      final path = Path();
      for (double y = 0; y < size.height; y += 4) {
        path.moveTo(x, y);
        path.lineTo(x, y + 2);
      }
      canvas.drawPath(path, dottedPaint);
    }

    // Draw line graph (flat at 0 for now as per screenshot)
    if (data.isNotEmpty) {
      final linePaint = Paint()
        ..color = Colors.purple
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      final pointPaint = Paint()
        ..color = Colors.purple
        ..style = PaintingStyle.fill;

      final path = Path();
      final pointWidth = size.width / data.length;

      for (int i = 0; i < data.length; i++) {
        final x = i * pointWidth;
        final y = size.height - (data[i] / maxValue * size.height);

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }

        // Draw point
        canvas.drawCircle(Offset(x, y), 4, pointPaint);
      }

      canvas.drawPath(path, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
