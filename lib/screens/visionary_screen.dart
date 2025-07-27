import 'package:flutter/material.dart';
import '../models/visionary_data.dart';
import '../screens/visionary_combat_stats_screen.dart';
import '../models/combat_stats.dart';
import'../models/visionary_class.dart';


class VisionaryScreen extends StatelessWidget {
  const VisionaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final visionaries = VisionaryData.predefinedVisionaries;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visionaries'),
      ),
      body: ListView.builder(
        itemCount: visionaries.length,
        itemBuilder: (context, index) {
          final visionary = visionaries[index]; // This is a VisionaryData object
          final VisionaryClass visionaryEnum = VisionaryClass.fromString(visionary.classType); // Get the enum
          final CombatStats currentCombatStats = visionary.combatStats;

// CORRECT WAY to get level, XP, etc.
          final int level = VisionaryData.classLevel[visionaryEnum] ?? 1;
          final int xp = VisionaryData.classXp[visionaryEnum] ?? 0;
          final int xpToNext = VisionaryData.xpToNextLevel(level); // Call as a static method
          final double xpProgress = (xpToNext > 0) ? (xp / xpToNext) : 0.0;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 4,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blueGrey[100],
                child: Text(visionary.displayName[0]),
              ),
              title: Text(visionary.displayName),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Class: ${visionary.classType}'), // This is fine, classType is a String in VisionaryData
                  Text('Level: $level'), // Use the 'level' variable you defined above
                  if (xpToNext > 0) ...[ // Check to prevent division by zero and show relevant UI
                    LinearProgressIndicator(
                      value: xpProgress, // Use the 'xpProgress' variable
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                    Text('$xp / $xpToNext XP'), // Use 'xp' and 'xpToNext' variables
                  ] else ...[
                    Text('$xp XP (Max Level or Error)'), // Handle cases where xpToNext might be 0
                  ],
                ],
              ),
              // visionary_screen.dart - onTap
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VisionaryCombatStatsScreen(
                      actualVisionaryClass: visionaryEnum, // Pass the VisionaryClass enum
                      stats: currentCombatStats,
                      visionaryName: visionary.displayName,
                      level: level,
                      xp: xp,
                      xpToNextLevel: xpToNext,
                      xpProgress: xpProgress,
                      description: visionary.description, // Add this
                      weaponType: visionary.weaponType,   // Add this
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
