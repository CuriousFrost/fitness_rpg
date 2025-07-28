import 'package:flutter/material.dart';
import '../models/visionary_data.dart'; // Import VisionaryData
import '../models/visionary_class.dart';
import '../models/combat_stats.dart';
import './visionary_stats_screen.dart';

class VisionaryCombatStatsScreen extends StatelessWidget {
  final VisionaryData visionaryData; // Changed from individual fields
  final CombatStats currentDisplayStats; // Potentially modified stats for display
  final String visionaryName; // Can still be useful for title, or get from visionaryData
  final int level;
  final int xp;
  final int xpToNextLevel;
  final double xpProgress;
  // description and weaponType can be accessed from visionaryData.description, visionaryData.weaponType
  // combatStats (base stats) can be accessed from visionaryData.combatStats

  const VisionaryCombatStatsScreen({
    super.key,
    required this.visionaryData, // Expect VisionaryData
    required this.currentDisplayStats, // This would be the stats possibly modified by level/gear etc.
    required this.visionaryName, // Or derive from visionaryData.displayName
    required this.level,
    required this.xp,
    required this.xpToNextLevel,
    required this.xpProgress,
  });

  @override
  Widget build(BuildContext context) {
    // Use visionaryData for stats and info
    final CombatStats baseCombatStats = visionaryData.combatStats;
    final String description = visionaryData.description;
    final String weaponType = visionaryData.weaponType;
    final VisionaryClass classEnum = VisionaryClass.fromString(visionaryData.classType);


    return Scaffold(
      appBar: AppBar(
        title: Text(visionaryName), // Or visionaryData.displayName
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Workout Stats',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VisionaryStatsScreen(
                    visionary: visionaryData, // Pass the full VisionaryData object
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text('Level: $level, XP: $xp / $xpToNextLevel (${(xpProgress * 100).toStringAsFixed(1)}%)'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                // Use currentDisplayStats for what's shown, baseCombatStats if you want to show base
                _buildStatTile(context, 'HP', currentDisplayStats.hp.toString()),
                _buildStatTile(context, 'ATK', currentDisplayStats.atk.toString()),
                _buildStatTile(context, 'DEF', currentDisplayStats.def.toString()),
                _buildStatTile(context, 'SPD', currentDisplayStats.spd.toString()),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildAttributeTag(context, 'Class: ${classEnum.displayName}'), // Use displayName from enum
                const SizedBox(width: 12),
                _buildAttributeTag(context, 'Weapon: $weaponType'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Updated to accept BuildContext
  Widget _buildStatTile(BuildContext context, String label, String value) {
    return Container(
      width: 80,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  // Updated to accept BuildContext
  Widget _buildAttributeTag(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onTertiaryContainer,
        ),
      ),
    );
  }
}
