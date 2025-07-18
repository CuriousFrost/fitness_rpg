import 'package:flutter/material.dart';
import 'screens/main_menu.dart';
import '../models/character_data.dart';
import '../logic/workout_data.dart';

// 🔹 Add this:
final PageStorageBucket pageStorageBucket = PageStorageBucket();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CharacterData.load();
  await workoutData.load();

  runApp(const FitnessRPGApp());
}
final workoutData = WorkoutData();

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
        child: MainMenu(),
      ),
    );
  }
}