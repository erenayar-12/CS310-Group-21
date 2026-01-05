/// App route name constants
class AppRoutes {
  AppRoutes._(); // Private constructor to prevent instantiation

  static const String initial = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String weeklyTracker = '/weekly-tracker';
  static const String addHabit = '/add-habit';
  static const String groups = '/groups';
  static const String profile = '/profile';
  static const String leaderboard = '/leaderboard';
  static const String friendProfile = '/friend-profile';
  
  /// Helper method to generate route paths with parameters
  static String leaderboardWithGroup(String groupId) => '$leaderboard?groupId=$groupId';
  static String friendProfileWithId(String friendId) => '$friendProfile?friendId=$friendId';
}

