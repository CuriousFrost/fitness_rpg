// visionary_combat_stats_screen.dart

import 'package:flutter/material.dart';
import '../models/visionary_class.dart';
import 'visionary_stats_screen.dart';
import '../models/combat_stats.dart';

class VisionaryCombatStatsScreen extends StatelessWidget {
  final VisionaryClass actualVisionaryClass;
  final CombatStats stats;
  final String visionaryName;
  final int level;
  final int xp;
  final int xpToNextLevel;
  final double xpProgress;
  final String description;
  final String weaponType;

  const VisionaryCombatStatsScreen({
    super.key,
    required this.actualVisionaryClass,
    required this.stats,
    required this.visionaryName,
    required this.level,
    required this.xp,
    required this.xpToNextLevel,
    required this.xpProgress,
    required this.description,
    required this.weaponType,
  });

  @override
  Widget build(BuildContext context) { // context is available here
    return Scaffold(
      appBar: AppBar(
        title: Text(visionaryName),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Workout Stats',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('VisionaryStatsScreen navigation needs review.'))
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
                _buildStatTile(context, 'HP', stats.hp.toString()),      // Pass context
                _buildStatTile(context, 'ATK', stats.atk.toString()),    // Pass context
                _buildStatTile(context, 'DEF', stats.def.toString()),    // Pass context
                _buildStatTile(context, 'SPD', stats.spd.toString()),    // Pass context
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildAttributeTag(context, 'Class: ${actualVisionaryClass.displayName}'), // Pass context
                const SizedBox(width: 12),
                _buildAttributeTag(context, 'Weapon: $weaponType'),                    // Pass context
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
