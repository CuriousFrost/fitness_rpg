import 'package:flutter/material.dart';
import 'screens/main_menu.dart';
import '../models/visionary_data.dart';
import '../logic/workout_data.dart';


// 🔹 Add this:
final PageStorageBucket pageStorageBucket = PageStorageBucket();

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Crucial for SharedPreferences before runApp

  print("MAIN: Initializing app...");

  // Create instances if they are not singletons managed elsewhere
  // final workoutData = WorkoutData(); // If it's not a global instance already

  print("MAIN: Loading WorkoutData...");
  await workoutData.load(); // Make sure 'workoutData' is the SAME instance used throughout your app
  print("MAIN: WorkoutData loaded. Entries: ${workoutData.entries.length}");

  print("MAIN: Loading VisionaryData...");
  await VisionaryData.load(); // If it has a static load method
  // Add a way to print loaded VisionaryData for verification if needed
  // VisionaryData.classLevel.forEach((key, value) {
  //   print("MAIN: Visionary ${key.name} Level: $value, XP: ${VisionaryData.classXp[key]}");
  // });


  await VisionaryData.initialize(); // Ensure descriptions and predefined are loaded
  print("MAIN: VisionaryData initialized (predefined visionaries).");


  print("MAIN: Running app...");
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


