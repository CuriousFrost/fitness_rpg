import 'package:flutter/material.dart';
import '../models/character_class.dart';
import 'workout_screen.dart';
import '../widgets/xp_progress_bar.dart';
import '../main.dart';
import'package:shared_preferences/shared_preferences.dart';

class CharacterScreen extends StatefulWidget {
  const CharacterScreen({super.key});

  @override
  State<CharacterScreen> createState() => _CharacterScreenState();
}

class _CharacterScreenState extends State<CharacterScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Character Progress')),
      body: ListView.builder(
        itemCount: CharacterClass.values.length,
        itemBuilder: (context, index) {
          final characterClass = CharacterClass.values[index];
          final xp = workoutData.characterXp[characterClass] ?? 0;

          return ListTile(
            title: Text(characterClass.displayName),
            subtitle: XPProgressBar(xp: xp),
            trailing: Text('$xp XP'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WorkoutScreen()),
          );
          setState(() {}); // Refresh after returning from workout screen
        },
        child: const Icon(Icons.fitness_center),
      ),
    );
  }
}
