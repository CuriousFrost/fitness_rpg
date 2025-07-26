import 'package:flutter/material.dart';
import '../models/visionary_class.dart';
import 'workout_screen.dart';
import '../widgets/xp_progress_bar.dart';
import '../screens/visionary_stats_screen.dart';
import '../logic/workout_data.dart';
import '../models/visionary_data.dart';


class CharacterScreen extends StatelessWidget {
  const CharacterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final characters = VisionaryData.characters;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visionaries'),
      ),
      body: ListView.builder(
        itemCount: characters.length,
        itemBuilder: (context, index) {
          final character = characters[index];
          final stats = combatStatsMap[character.characterClass];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 4,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blueGrey[100],
                child: Text(character.name[0]),
              ),
              title: Text(character.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Class: ${character.characterClass.displayName}'),
                  Text('Level: ${character.level}'),
                  LinearProgressIndicator(
                    value: character.xp / character.xpToNextLevel,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                  Text('${character.xp} / ${character.xpToNextLevel} XP'),
                ],
              ),
              onTap: () {
                if (stats != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VisionaryCombatStatsScreen(
                        characterClass: character.characterClass,
                        stats: stats,
                      ),
                    ),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}
