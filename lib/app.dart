import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/commitly_home/commitly_home_screen.dart';
import 'services/auth_service.dart';

class CommitlyApp extends StatelessWidget {
  const CommitlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return MaterialApp(
      title: 'Commitly',
      theme: ThemeData.light(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.grey.shade100, // Light grey background
      ),
      home: StreamBuilder(
        stream: authService.authStateChanges,
        builder: (context, snapshot) {
          // Show loading indicator while checking auth state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // If user is logged in, show home screen
          // If user is logged out, show login screen
          final user = snapshot.data;
          if (user != null) {
            return const CommitlyHomeScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
