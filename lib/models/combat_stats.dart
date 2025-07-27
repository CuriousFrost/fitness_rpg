import '../models/visionary_class.dart';

class CombatStats {
  final int atk;
  final int defense;
  final int spd;
  final int hp;

  CombatStats({
    required this.atk,
    required this.defense,
    required this.spd,
    required this.hp,
  });
  final Map<VisionaryClass, CombatStats> combatStatsMap = {
    VisionaryClass.bloodletter: CombatStats(
      hp: 100,
      atk: 10,
      defense: 10,
      spd: 10,
    ),
    VisionaryClass.airsnatcher: CombatStats(
      hp: 100,
      atk: 10,
      defense: 10,
      spd: 10,
    ),
    VisionaryClass.saboteur: CombatStats(
      hp: 100,
      atk: 10,
      defense: 10,
      spd: 10,
    ),
    VisionaryClass.lightTheologist: CombatStats(
      hp: 100,
      atk: 10,
      defense: 10,
      spd: 10,
    ),
    VisionaryClass.victimizer: CombatStats(
      hp: 100,
      atk: 10,
      defense: 10,
      spd: 10,
    ),
    VisionaryClass.symbolist: CombatStats(
      hp: 100,
      atk: 10,
      defense: 10,
      spd: 10,
    ),
    VisionaryClass.cosmologist: CombatStats(
      hp: 100,
      atk: 10,
      defense: 10,
      spd: 10,
    ),
    VisionaryClass.mossborn: CombatStats(
      hp: 100,
      atk: 10,
      defense: 10,
      spd: 10,
    ),
    VisionaryClass.farseer: CombatStats(
        hp: 100,
        atk: 10,
        defense: 10,
        spd: 10),
    VisionaryClass.realist: CombatStats(
        hp: 100,
        atk: 10,
        defense: 10,
        spd: 10),
  };
}
