import 'package:flutter/material.dart';

class AchievementsView extends StatefulWidget {
  const AchievementsView({super.key});

  @override
  State<AchievementsView> createState() => _AchievementsViewState();
}

class _AchievementsViewState extends State<AchievementsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Placeholder data - will be replaced with actual data later
  int _currentXP = 0;
  int _nextLevelXP = 100;
  int _level = 1;
  String _levelTitle = '🌱 Beginner';
  int _unlockedCount = 0;
  int _lockedCount = 8;
  int _totalXP = 0;

  final List<Map<String, dynamic>> _upcomingGoals = [
    {'name': 'First Step', 'xp': 50},
    {'name': 'Getting Started', 'xp': 100},
    {'name': 'Dedicated', 'xp': 250},
  ];

  final List<Map<String, dynamic>> _lockedAchievements = [
    {
      'icon': '🎯',
      'title': 'First Habit',
      'description': 'Create your first habit',
      'xp': 50,
    },
    {
      'icon': '🔥',
      'title': '7 Day Streak',
      'description': 'Maintain a habit for 7 days',
      'xp': 100,
    },
    {
      'icon': '💪',
      'title': 'Consistency King',
      'description': 'Complete 10 habits',
      'xp': 150,
    },
    {
      'icon': '⭐',
      'title': 'Power User',
      'description': 'Complete 50 habits',
      'xp': 300,
    },
    {
      'icon': '🏆',
      'title': 'Champion',
      'description': 'Maintain a 30 day streak',
      'xp': 500,
    },
    {
      'icon': '👑',
      'title': 'Legendary',
      'description': 'Complete 100 habits',
      'xp': 1000,
    },
    {
      'icon': '💎',
      'title': 'Diamond Status',
      'description': 'Maintain a 90 day streak',
      'xp': 2000,
    },
    {
      'icon': '🌟',
      'title': 'Master',
      'description': 'Complete 500 habits',
      'xp': 5000,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      body: Container(
        color: theme.colorScheme.surface,
        child: Column(
          children: [
            // Header with gradient background
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.brightness == Brightness.dark
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFFFBBF24), // yellow
                      theme.brightness == Brightness.dark
                          ? const Color(0xFFEA580C)
                          : const Color(0xFFF97316), // orange
                      theme.brightness == Brightness.dark
                          ? const Color(0xFFDC2626)
                          : const Color(0xFFEF4444), // red
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Title Row
                      Row(
                        children: [
                          // Back Button
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const SizedBox(width: 8),
                          // Trophy Icon
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.emoji_events,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Achievements & XP',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Level $_level • $_levelTitle',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // XP Progress Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Current XP',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.8),
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$_currentXP',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Next Level',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.8),
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$_nextLevelXP',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: _currentXP / _nextLevelXP,
                                minHeight: 12,
                                backgroundColor: Colors.white.withValues(alpha: 0.2),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$_nextLevelXP XP needed for Level ${_level + 1}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Content Section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Stats Grid
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.emoji_events,
                            iconColor: const Color(0xFFCA8A04), // yellow-600
                            label: 'Unlocked',
                            value: '$_unlockedCount',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.star,
                            iconColor: const Color(0xFF2563EB), // blue-600
                            label: 'Total XP',
                            value: '$_totalXP',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.local_fire_department,
                            iconColor: const Color(0xFFEA580C), // orange-600
                            label: 'Level',
                            value: '$_level',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Upcoming Goals Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.brightness == Brightness.dark
                                ? theme.colorScheme.primary.withValues(alpha: 0.1)
                                : const Color(0xFFEFF6FF), // blue-50
                            theme.brightness == Brightness.dark
                                ? theme.colorScheme.secondary.withValues(alpha: 0.1)
                                : const Color(0xFFFAF5FF), // purple-50
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.dividerColor,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '🎯 Upcoming Goals',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ..._upcomingGoals.map((goal) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '• ${goal['name']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.brightness == Brightness.dark
                                        ? theme.colorScheme.onSurface.withValues(alpha: 0.8)
                                        : Colors.grey.shade700,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.secondary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '+${goal['xp']} XP',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tabs Section
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(3),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: theme.colorScheme.onSurface,
                        unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        dividerColor: Colors.transparent,
                        labelStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        tabs: const [
                          Tab(text: 'Unlocked (0)'),
                          Tab(text: 'Locked (8)'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tab Content
                    SizedBox(
                      height: 400,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // Unlocked Tab
                          _buildEmptyState(),
                          // Locked Tab
                          _buildLockedAchievements(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: theme.brightness == Brightness.dark
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                    : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '🏆',
                style: TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 16),
              Text(
                'Complete habits to unlock achievements!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.brightness == Brightness.dark
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                      : Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLockedAchievements() {
    final theme = Theme.of(context);
    
    return ListView.builder(
      padding: const EdgeInsets.only(top: 12),
      itemCount: _lockedAchievements.length,
      itemBuilder: (context, index) {
        final achievement = _lockedAchievements[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: theme.dividerColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon Container
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Opacity(
                      opacity: 0.5,
                      child: Text(
                        achievement['icon'],
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Achievement Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        achievement['title'],
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        achievement['description'],
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.brightness == Brightness.dark
                              ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                // XP Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '+${achievement['xp']} XP',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
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