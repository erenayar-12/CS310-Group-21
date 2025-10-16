import 'package:flutter/material.dart';

import 'screens/commitly_home/commitly_home_screen.dart';

class CommitlyApp extends StatelessWidget {
  const CommitlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Commitly',
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
      ),
      home: const CommitlyHomeScreen(),
    );
  }
}
