import '../models/visionary_class.dart';

class CombatStats {
  final int atk;
  final int def;
  final int spd;
  final int hp;

  CombatStats({
    required this.atk,
    required this.def,
    required this.spd,
    required this.hp,
  });
}

final Map<VisionaryClass, CombatStats> combatStatsMap = {
  VisionaryClass.bloodletter: CombatStats(hp: 30, atk: 10, def: 25, spd: 15),
  VisionaryClass.airsnatcher: CombatStats(hp: 20, atk: 30, def: 10, spd: 10),
  VisionaryClass.saboteur: CombatStats(hp: 15, atk: 27, def: 10, spd: 22),
  VisionaryClass.lightTheologist: CombatStats(hp: 20, atk: 20, def: 20, spd: 20),
  VisionaryClass.victimizer: CombatStats(hp: 35, atk: 10, def: 27, spd: 8),
  VisionaryClass.symbolist: CombatStats(hp: 20, atk: 22, def: 20, spd: 12),
  VisionaryClass.cosmologist: CombatStats(hp: 15, atk: 32, def: 10, spd: 13),
  VisionaryClass.mossborn: CombatStats(hp: 20, atk: 20, def: 25, spd: 15),
  VisionaryClass.farseer: CombatStats(hp: 20, atk: 22, def: 10, spd: 22),
  VisionaryClass.realist: CombatStats(hp: 30, atk: 12, def: 27, spd: 9),
};
