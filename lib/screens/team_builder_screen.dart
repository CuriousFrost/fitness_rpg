import 'package:flutter/material.dart';
import '../logic/visionary_data.dart';
import '../widgets/visionary_card.dart';
import '../models/visionary_class.dart';
import '../models/combat_stats.dart';

class TeamBuilderScreen extends StatelessWidget {
  final List<VisionaryData> team;

  const TeamBuilderScreen({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Team Builder")),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: team.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2x2x2 layout
          childAspectRatio: 1,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          return VisionaryCard(
            visionary: team[index],
            onTap: () {
              // TODO: Add selection dialog to choose new Visionary
            },
          );
        },
      ),
    );
  }
}

final CombatStats _dummyDefaultStats = CombatStats(atk: 1, def: 1, spd: 1, hp: 10);

final List<VisionaryData> dummyTeam = [
  VisionaryData(
    id: 'dummy_aurelia',
    displayName: "Aurelia",
    description: "A Farseer dummy.",
    classType: VisionaryClass.farseer.name,
    weaponType: "Orb",
    combatStats: combatStatsMap[VisionaryClass.farseer] ?? _dummyDefaultStats,
    spriteSheetPath: 'assets/images/game/player/Farseer_Sprites.png', // You need this asset or a placeholder
    avatarSpriteRect: Rect.fromLTWH(0, 0, 64, 64), // Adjust as needed
  ),
  VisionaryData(
    id: 'dummy_galen',
    displayName: "Galen",
    description: "A Realist dummy.",
    classType: VisionaryClass.realist.name,
    weaponType: "Sword",
    combatStats: combatStatsMap[VisionaryClass.realist] ?? _dummyDefaultStats,
    spriteSheetPath: 'assets/images/game/player/Realist_Sprites.png', // You need this asset or a placeholder
    avatarSpriteRect: Rect.fromLTWH(0, 0, 64, 64), // Adjust as needed
  ),
  VisionaryData(
    id: 'dummy_mira',
    displayName: "Mira",
    description: "A Symbolist dummy.",
    classType: VisionaryClass.symbolist.name,
    weaponType: "Tome",
    combatStats: combatStatsMap[VisionaryClass.symbolist] ?? _dummyDefaultStats,
    spriteSheetPath: 'assets/images/game/player/Symbolist_Sprites.png', // You need this asset or a placeholder
    avatarSpriteRect: Rect.fromLTWH(0, 0, 64, 64), // Adjust as needed
  ),
  VisionaryData(
    id: 'dummy_kael',
    displayName: "Kael",
    description: "A Victimizer dummy.",
    classType: VisionaryClass.victimizer.name,
    weaponType: "Daggers",
    combatStats: combatStatsMap[VisionaryClass.victimizer] ?? _dummyDefaultStats,
    spriteSheetPath: 'assets/images/game/player/Victimizer_Sprites.png', // You need this asset or a placeholder
    avatarSpriteRect: Rect.fromLTWH(0, 0, 64, 64), // Adjust as needed
  ),
  VisionaryData(
    id: 'dummy_ira',
    displayName: "Ira",
    description: "A Cosmologist dummy.",
    classType: VisionaryClass.cosmologist.name,
    weaponType: "Scepter",
    combatStats: combatStatsMap[VisionaryClass.cosmologist] ?? _dummyDefaultStats,
    spriteSheetPath: 'assets/images/game/player/Cosmologist_Sprites.png', // You need this asset or a placeholder
    avatarSpriteRect: Rect.fromLTWH(0, 0, 64, 64), // Adjust as needed
  ),
  VisionaryData(
    id: 'dummy_thorne',
    displayName: "Thorne",
    description: "A Mossborn dummy.",
    classType: VisionaryClass.mossborn.name,
    weaponType: "Bow",
    combatStats: combatStatsMap[VisionaryClass.mossborn] ?? _dummyDefaultStats,
    spriteSheetPath: 'assets/images/game/player/Mossborn_Sprites.png', // You need this asset or a placeholder
    avatarSpriteRect: Rect.fromLTWH(0, 0, 64, 64), // Adjust as needed
  ),
];
