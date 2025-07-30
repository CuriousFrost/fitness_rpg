import 'package:flutter/material.dart';
import '../logic/visionary_data.dart';
import '../models/visionary_class.dart';
import '../models/combat_stats.dart';
import '../screens/visionary_combat_stats_screen.dart';

class VisionaryCard extends StatelessWidget {
  final VisionaryData visionary;
  final VoidCallback onTap;

  const VisionaryCard({super.key, required this.visionary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final stats = combatStatsMap[visionary.combatStats]!;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.green[100],
        margin: const EdgeInsets.all(8),
        child: Column(
          children: [
            // Visionary Name Header (tappable)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.green[300],
              width: double.infinity,
              child: Text(
                visionary.displayName,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),

            Expanded(
              child: Row(
                children: [
                  // Left: Base Stats
                  Expanded(
                    child: Container(
                      color: Colors.red[100],
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text("ATK: ${stats.atk}"),
                          Text("DEF: ${stats.def}"),
                          Text("SPD: ${stats.spd}"),
                          Text("HP: ${stats.hp}"),
                        ],
                      ),
                    ),
                  ),

                  // Right: Sprite Image (placeholder for now)
                  FittedBox(
                    fit: BoxFit.none,
                    child: SizedBox(
                      width: visionary.avatarSpriteRect.width,
                      height: visionary.avatarSpriteRect.height,
                      child: OverflowBox(
                        maxWidth: double.infinity,
                        maxHeight: double.infinity,
                        alignment: Alignment.topLeft,
                        child: Transform.translate(
                          offset: Offset(-visionary.avatarSpriteRect.left, -visionary.avatarSpriteRect.top),
                          child: Image.asset(visionary.spriteSheetPath!),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}