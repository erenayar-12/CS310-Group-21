import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/auth/login_screen.dart';
import 'screens/commitly_home/commitly_home_screen.dart';
import 'screens/commitly_leaderboard/leaderboard_screen.dart';
import 'friend_profile_page.dart';
import 'data/habit_group.dart';
import 'data/friend.dart';
import 'services/auth_service.dart';
import 'services/theme_service.dart';
import 'services/firestore_service.dart';
import 'utils/app_colors.dart';
import 'utils/loading_widgets.dart';
import 'routes/app_routes.dart';

class CommitlyApp extends StatelessWidget {
  const CommitlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider(create: (_) => FirestoreService()),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, _) {
          return MaterialApp(
            title: 'Commitly',
            theme: ThemeData.light(useMaterial3: true).copyWith(
              textTheme: ThemeData.light().textTheme.apply(fontFamily: 'Poppins'),
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.purple,
                brightness: Brightness.light,
              ),
              scaffoldBackgroundColor: Colors.grey.shade100,
            ),
            darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
              textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Poppins'),
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.purple,
                brightness: Brightness.dark,
              ),
              scaffoldBackgroundColor: AppColors.backgroundDark,
            ),
            themeMode: themeService.themeMode,
            initialRoute: AppRoutes.initial,
            routes: {
              AppRoutes.initial: (context) => const _AuthGate(),
              AppRoutes.login: (context) => const LoginScreen(),
              AppRoutes.home: (context) => const CommitlyHomeScreen(),
            },
            onGenerateRoute: (settings) {
              // Custom page transitions
              switch (settings.name) {
                case AppRoutes.login:
                  return _createRoute(const LoginScreen(), settings);
                case AppRoutes.home:
                  return _createRoute(
                    const CommitlyHomeScreen(
                      key: PageStorageKey<String>('commitly_home'),
                    ),
                    settings,
                  );
                case AppRoutes.leaderboard:
                  // Extract group from arguments
                  final group = settings.arguments as HabitGroup?;
                  if (group != null) {
                    return _createRoute(
                      LeaderboardScreen(group: group),
                      settings,
                    );
                  }
                  // Fallback to home if no group provided
                  return _createRoute(
                    const CommitlyHomeScreen(
                      key: PageStorageKey<String>('commitly_home'),
                    ),
                    settings,
                  );
                case AppRoutes.friendProfile:
                  // Extract friend from arguments
                  final friend = settings.arguments as Friend?;
                  if (friend != null) {
                    return _createRoute(
                      FriendProfilePage(
                        name: friend.name,
                        level: friend.level,
                        streak: friend.streak,
                        topHabit: friend.topHabit,
                        avatarColor: friend.color,
                      ),
                      settings,
                    );
                  }
                  // Fallback to home if no friend provided
                  return _createRoute(
                    const CommitlyHomeScreen(
                      key: PageStorageKey<String>('commitly_home'),
                    ),
                    settings,
                  );
                default:
                  return _createRoute(const _AuthGate(), settings);
              }
            },
          );
        },
      ),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate({super.key});

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();

    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AppLoadingOverlay(
            message: 'Checking authentication...',
          );
        }

        final user = snapshot.data;

        if (user != null) {
          // User is logged in, show home screen
          return const CommitlyHomeScreen(
            key: PageStorageKey<String>('commitly_home'),
          );
        }

        // User is not logged in, show login screen
        return const LoginScreen();
      },
    );
  }
}

// Helper function to create custom page transitions
PageRouteBuilder _createRoute(Widget page, RouteSettings settings) {
  return PageRouteBuilder(
    settings: settings,
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(
        CurveTween(curve: curve),
      );

      return SlideTransition(
        position: animation.drive(tween),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}
