import 'package:flutter/material.dart';
import '../models/character_data.dart';
import 'visionary_stats_screen.dart';


class VisionaryCombatStatsScreen extends StatelessWidget {
  final CharacterData characterClass;

  const VisionaryCombatStatsScreen({super.key, required this.characterClass});

  @override
  Widget build(BuildContext context) {
    final combatStats = characterClass.combatStats;

    return Scaffold(
      appBar: AppBar(
        title: Text(characterClass.displayName),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Workout Stats',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VisionaryStatsScreen(characterClass: characterClass),
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
              characterClass.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildStatTile('HP', combatStats.hp.toString()),
                _buildStatTile('ATK', combatStats.atk.toString()),
                _buildStatTile('DEF', combatStats.defense.toString()),
                _buildStatTile('SPD', combatStats.spd.toString()),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildAttributeTag('Class: ${characterClass.classType}'),
                const SizedBox(width: 12),
                _buildAttributeTag('Weapon: ${characterClass.weaponType}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(String label, String value) {
    return Container(
      width: 80,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.indigo[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildAttributeTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }
}
