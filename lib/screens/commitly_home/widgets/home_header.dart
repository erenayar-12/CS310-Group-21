import 'package:flutter/material.dart';
import '../../../services/firestore_service.dart';
import '../../../utils/app_colors.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  // Basit level sistemi: her level 100 XP
  int _levelFromTotalXp(int totalXp) => (totalXp ~/ 100) + 1;
  int _xpIntoCurrentLevel(int totalXp) => totalXp % 100;

  String _levelLabel(int level) {
    if (level <= 1) return 'Beginner';
    if (level <= 3) return 'Explorer';
    if (level <= 6) return 'Builder';
    return 'Master';
  }

  String _dateText() {
    final now = DateTime.now();
    const weekdays = [
      'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'
    ];
    const months = [
      'January','February','March','April','May','June',
      'July','August','September','October','November','December'
    ];
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final service = FirestoreService();

    return StreamBuilder<Map<String, dynamic>>(
      stream: service.getUserStatsStream(),
      builder: (context, snapshot) {
        final data = snapshot.data ?? <String, dynamic>{};

        final totalXp = (data['totalXp'] as num?)?.toInt() ?? 0;
        final totalCompletions = (data['totalCompletions'] as num?)?.toInt() ?? 0;

        // Eğer streak field’ınız yoksa şimdilik completion gösterelim
        // (istersen streak alanını bulunca bunu da bağlarız)
        final streakDays = (data['streakDays'] as num?)?.toInt();

        const nextLevelXp = 100;
        final level = _levelFromTotalXp(totalXp);
        final xpThisLevel = _xpIntoCurrentLevel(totalXp);
        final progress = (xpThisLevel / nextLevelXp).clamp(0.0, 1.0);

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryPurple, AppColors.primaryPurpleLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TITLE
                Text(
                  'Habit Tracker',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),

                // DATE (dinamik)
                Text(
                  _dateText(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 16),

                // LEVEL, XP, PROGRESS BAR (Firestore’dan)
                Text(
                  'Level $level · ${_levelLabel(level)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$xpThisLevel / $nextLevelXp XP  (Total: $totalXp)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(height: 16),

                // STREAK CHIP LEFT ALIGNED (streak yoksa completion göster)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        size: 16,
                        color: Colors.orangeAccent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        streakDays != null
                            ? '$streakDays Day Streak'
                            : '$totalCompletions Completions',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // QUOTE LEFT ALIGNED
                const Text(
                  '“Small steps lead to big changes! 💪”',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}