import 'package:flutter/material.dart';
import 'screens/main_menu.dart';
import '../models/visionary_data.dart';
//import 'package:shared_preferences/shared_preferences.dart';

// 🔹 Add this:
final PageStorageBucket pageStorageBucket = PageStorageBucket();

Future <void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await VisionaryData.initialize();
  await VisionaryData.load();
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


