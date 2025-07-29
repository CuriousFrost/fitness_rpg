// visionary_screen.dart

import 'package:flutter/material.dart';
import '../logic/visionary_data.dart';
import '../screens/visionary_combat_stats_screen.dart';
import '../models/visionary_class.dart';
import '../logic/workout_data.dart'; // Import WorkoutData

class VisionaryScreen extends StatelessWidget {
  const VisionaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Assuming workoutData is available via Provider or as a global instance
    // If global: final wd = workoutData;
    // If Provider: final wd = Provider.of<WorkoutData>(context);
    // For simplicity, let's use the global instance workoutData directly here.
    // It's better to use Provider for cleaner dependency management.

    final visionaries = VisionaryData.predefinedVisionaries;

    return Scaffold(
      appBar: AppBar(title: const Text('Visionaries')),
      body: ListView.builder(
        itemCount: visionaries.length,
        itemBuilder: (context, index) {
          final visionaryDef =
              visionaries[index]; // This is a VisionaryData object (definition)
          final VisionaryClass visionaryEnum = VisionaryClass.fromString(
            visionaryDef.classType,
          );
          // Get total historical XP from WorkoutData
          final int totalHistoricalXp =
              workoutData.characterXp[visionaryEnum] ?? 0;
          // Calculate current level and progress using VisionaryData utility
          final Map<String, int> levelProgress =
              VisionaryData.calculateLevelAndProgress(totalHistoricalXp);
          final int currentLevel = levelProgress['level']!;
          final int xpIntoCurrentLevel = levelProgress['xpIntoCurrentLevel']!;
          final int xpNeededForNext = levelProgress['xpNeededForNextLevel']!;
          final double xpProgressFraction = (xpNeededForNext > 0)
              ? (xpIntoCurrentLevel.toDouble() / xpNeededForNext.toDouble())
                    .clamp(0.0, 1.0)
              : (currentLevel >= VisionaryData.maxLevel ? 1.0 : 0.0);

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 4,
            child: ListTile(
              leading: CircleAvatar(/* ... */),
              title: Text(visionaryDef.displayName),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Class: ${visionaryEnum.displayName}',
                  ), // <--- USE THE ENUM'S DISPLAY NAME HERE
                  Text('Level: $currentLevel'),
                  if (currentLevel < VisionaryData.maxLevel &&
                      xpNeededForNext > 0) ...[
                    LinearProgressIndicator(
                      value: xpProgressFraction,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                    Text('$xpIntoCurrentLevel / $xpNeededForNext XP'),
                  ] else ...[
                    Text('$xpIntoCurrentLevel XP (Max Level)'),
                    LinearProgressIndicator(
                      // Show full bar at max
                      value: 1.0,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                    ),
                  ],
                ],
              ),
              onTap: () {
                // Pass the calculated data to the stats screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VisionaryCombatStatsScreen(
                      visionaryData: visionaryDef,
                      currentDisplayStats: visionaryDef
                          .combatStats, // Base stats, adjust if they scale with level
                      visionaryName: visionaryDef.displayName,
                      level: currentLevel,
                      xp: xpIntoCurrentLevel,
                      xpToNextLevel: xpNeededForNext,
                      xpProgress: xpProgressFraction,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
