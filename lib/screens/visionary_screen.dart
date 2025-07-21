import 'package:flutter/material.dart';
import '../models/character_class.dart';
import 'workout_screen.dart';
import '../widgets/xp_progress_bar.dart';
import '../main.dart';

class CharacterScreen extends StatefulWidget {
  const CharacterScreen({super.key});

  @override
  State<CharacterScreen> createState() => _CharacterScreenState();
}

class _CharacterScreenState extends State<CharacterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Visionary Progress')),
      body: ListView.builder(
        itemCount: CharacterClass.values.length,
        itemBuilder: (context, index) {
          final characterClass = CharacterClass.values[index];
          final xp = workoutData.characterXp[characterClass] ?? 0;

          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  characterClass.displayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                XPProgressBar(xp: xp),
                const SizedBox(height: 6),
                Text(
                  'Total: $xp XP',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Divider(thickness: 1, height: 20),
              ],
            ),
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
