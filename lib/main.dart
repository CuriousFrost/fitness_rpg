import 'package:flutter/material.dart';
import 'screens/main_menu.dart';
import '../models/character_data.dart'; // Assuming this exists
import '../logic/workout_data.dart';   // Assuming this exists
import 'package:shared_preferences/shared_preferences.dart';

// 🔹 Add this:
final PageStorageBucket pageStorageBucket = PageStorageBucket();

void main() async {
  // Ensure Flutter is initialized first
  WidgetsFlutterBinding.ensureInitialized();
  print("DEBUG: Flutter Binding Initialized.");

  final prefs = await SharedPreferences.getInstance();
  print("DEBUG: SharedPreferences instance obtained.");
  print("DEBUG: Keys before clear: ${prefs.getKeys()}");

  await prefs.clear();
  print("DEBUG: SharedPreferences cleared.");
  print("DEBUG: Keys after clear: ${prefs.getKeys()}"); // Should be empty

  // Temporarily comment these out to isolate the issue
  // await CharacterData.load();
  // print("DEBUG: CharacterData loaded.");
  // print("DEBUG: Keys after CharacterData.load: ${prefs.getKeys()}");

  // await workoutData.load();
  // print("DEBUG: WorkoutData loaded.");
  // print("DEBUG: Keys after workoutData.load: ${prefs.getKeys()}");

  runApp(const FitnessRPGApp());
}

final workoutData = WorkoutData(); // Make sure WorkoutData class is defined

class FitnessRPGApp extends StatelessWidget {
  const FitnessRPGApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fitness RPG',
      theme: ThemeData.dark(),
      // 🔹 Wrap your root screen with PageStorage
      home: PageStorage(
        bucket: pageStorageBucket,
        child: MainMenu(), // Make sure MainMenu widget is defined
      ),
    );
  }
}

// Dummy classes if they are not defined elsewhere, for the sake of the example
// class CharacterData {
//   static Future<void> load() async {
//     print("CharacterData.load() called");
//     // Simulate loading and potentially saving data
//     // final prefs = await SharedPreferences.getInstance();
//     // await prefs.setString("character_xp", "80/116"); // Example of re-saving
//   }
// }

// class WorkoutData {
//   Future<void> load() async {
//     print("WorkoutData.load() called");
//     // Simulate loading and potentially saving data
//   }
// }

// class MainMenu extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(body: Center(child: Text("Main Menu")));
//   }
// }