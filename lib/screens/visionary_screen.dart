import 'package:flutter/material.dart';
import '../models/visionary_class.dart';
import 'workout_screen.dart';
import '../widgets/xp_progress_bar.dart';
import '../screens/visionary_stats_screen.dart';
import '../logic/workout_data.dart';
import '../models/visionary_data.dart';
import '../screens/visionary_combat_stats_screen.dart';
import '../models/combat_stats.dart';


class VisionaryScreen extends StatelessWidget {
  const VisionaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final visionaries = VisionaryData.visionaries;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visionaries'),
      ),
      body: ListView.builder(
        itemCount: visionaries.length,
        itemBuilder: (context, index) {
          final visionary = visionaries[index];
          final stats = combatStatsMap[visionary.visionaryClass];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 4,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blueGrey[100],
                child: Text(visionary.name[0]),
              ),
              title: Text(visionary.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Class: ${visionary.visionaryClass.displayName}'),
                  Text('Level: ${visionary.level}'),
                  LinearProgressIndicator(
                    value: visionary.xp / visionary.xpToNextLevel,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                  Text('${visionary.xp} / ${visionary.xpToNextLevel} XP'),
                ],
              ),
              onTap: () {
                if (stats != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VisionaryCombatStatsScreen(
                        visionaryClass: visionary.visionaryClass,
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
