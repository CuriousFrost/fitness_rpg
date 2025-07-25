import 'package:flutter/material.dart';
import 'screens/main_menu.dart';
//import 'package:shared_preferences/shared_preferences.dart';

// 🔹 Add this:
final PageStorageBucket pageStorageBucket = PageStorageBucket();

void main() {
  runApp(const FitnessRPGApp());
}

class FitnessRPGApp extends StatelessWidget {
  const FitnessRPGApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness RPG',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const MainMenuScreen(), // 👈 Switch to your new main menu
    );
  }
}
// lib/logic/workout_data.dart

