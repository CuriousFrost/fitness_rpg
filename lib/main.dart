import 'package:flutter/material.dart';
import 'screens/main_menu.dart';
import 'logic/visionary_data.dart';
import '../logic/workout_data.dart';

// 🔹 Add this:
final PageStorageBucket pageStorageBucket = PageStorageBucket();

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Crucial for SharedPreferences before runApp
  await workoutData
      .load(); // Make sure 'workoutData' is the SAME instance used throughout your app
  await VisionaryData.load(); // If it has a static load method
  await VisionaryData.initialize(); // Ensure descriptions and predefined are loaded
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
