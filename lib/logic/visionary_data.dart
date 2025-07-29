// visionary_data.dart
import 'dart:convert';
import 'dart:math';
import '../models/visionary_class.dart';
import '../models/combat_stats.dart'; // Ensure this is correctly imported
import 'package:flutter/services.dart' show rootBundle;

class VisionaryData {
  // ------------------------------------------------------------------
  // Instance Members (Blueprint for ONE Visionary)
  // ------------------------------------------------------------------
  final String id;
  final String displayName;
  final String description;
  final String classType; // Or VisionaryClass
  final String weaponType;
  final CombatStats combatStats; // This needs CombatStats to be defined

  VisionaryData({
    required this.id,
    required this.displayName,
    required this.description,
    required this.classType,
    required this.weaponType,
    required this.combatStats,
  });

  // ------------------------------------------------------------------
  // Static Members (Global data/utilities related to all Visionaries)
  // ------------------------------------------------------------------

  static const int maxXpTotal =
      152960; // Max XP a character can effectively have for leveling
  static const int maxLevel = 150;
  static const double levelXpMultiplier = 1.2;
  static const int baseXpForLevelUp = 100;

  static int xpToNextLevel(int currentLevel) {
    if (currentLevel >= maxLevel) {
      return 0; // Or a very large number if you want to show a full bar but no more levels
    }
    if (currentLevel < 1) currentLevel = 1;
    return (baseXpForLevelUp * (pow(levelXpMultiplier, currentLevel - 1)))
        .round();
  }

  /// Calculates the current level, XP into that level, and XP needed for the next level
  /// based on the total historical XP accumulated for a visionary.
  static Map<String, int> calculateLevelAndProgress(int totalHistoricalXp) {
    int currentLevel = 1;
    int xpIntoCurrentLevel = 0;
    int accumulatedXpForPriorLevels = 0;

    // Cap totalHistoricalXp at what's effectively needed for max level,
    // though UI might show total if it exceeds this.
    // This helps prevent infinite loops if totalHistoricalXp is unexpectedly huge.
    int cappedHistoricalXp = totalHistoricalXp.clamp(0, maxXpTotal);

    while (currentLevel < maxLevel) {
      int xpNeededForThisLevel = xpToNextLevel(currentLevel);
      if (xpNeededForThisLevel == 0) {
        // Should only happen if currentLevel is already maxLevel
        break;
      }
      if (cappedHistoricalXp >=
          accumulatedXpForPriorLevels + xpNeededForThisLevel) {
        accumulatedXpForPriorLevels += xpNeededForThisLevel;
        currentLevel++;
      } else {
        break;
      }
    }

    xpIntoCurrentLevel = cappedHistoricalXp - accumulatedXpForPriorLevels;

    // If at max level, ensure xpIntoCurrentLevel doesn't exceed what's needed for the final bar
    if (currentLevel == maxLevel) {
      int xpForMaxLevelBar = xpToNextLevel(
        maxLevel - 1,
      ); // XP to complete level before max
      if (xpForMaxLevelBar > 0) {
        xpIntoCurrentLevel = xpIntoCurrentLevel.clamp(0, xpForMaxLevelBar);
      } else {
        // If maxLevel is 1, or xpToNextLevel(maxLevel-1) is 0 for some reason
        xpIntoCurrentLevel = 0;
      }
    }

    return {
      'level': currentLevel,
      'xpIntoCurrentLevel': xpIntoCurrentLevel,
      'xpNeededForNextLevel': xpToNextLevel(
        currentLevel,
      ), // XP needed to complete the currentLevel
    };
  }

  static Future<void> save() async {}

  static Future<void> load() async {}
  static Map<String, String> _loadedDescriptions = {};
  static late final List<VisionaryData> predefinedVisionaries;
  static final bool _isInitialized = false;
  static Future<void> initialize() async {
    if (_isInitialized) return; // Prevent re-initialization

    // 1. Load Descriptions
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/text/visionary_descriptions.json',
      );
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      _loadedDescriptions = jsonMap.map(
        (key, value) => MapEntry(key, value.toString()),
      );
    } catch (e) {
      // Handle error, maybe load with default empty descriptions
      _loadedDescriptions = {};
    }

    predefinedVisionaries = [
      VisionaryData(
        id: 'bloodletter',
        // Unique ID for this visionary type
        displayName: 'Bloodletter',
        description:
            _loadedDescriptions['bloodletter_description'] ??
            'Default description',
        classType: VisionaryClass.bloodletter.name,
        // Storing the class name as a string
        weaponType: 'Sword',
        // Retrieve stats from combatStatsMap, provide a fallback if not found
        combatStats:
            combatStatsMap[VisionaryClass.bloodletter] ??
            CombatStats(atk: 1, def: 1, spd: 1, hp: 10),
      ),
      VisionaryData(
        id: 'airsnatcher',
        // Unique ID for this visionary type
        displayName: 'Airsnatcher',
        description:
            _loadedDescriptions['airsnatcher_description'] ??
            'Default description',
        classType: VisionaryClass.airsnatcher.name,
        // Storing the class name as a string
        weaponType: 'Particle Matter',
        // Retrieve stats from combatStatsMap, provide a fallback if not found
        combatStats:
            combatStatsMap[VisionaryClass.airsnatcher] ??
            CombatStats(atk: 1, def: 1, spd: 1, hp: 10),
      ),
      VisionaryData(
        id: 'saboteur',
        displayName: 'Saboteur',
        description:
            _loadedDescriptions['saboteur_description'] ??
            'Default description',
        classType: VisionaryClass.saboteur.name,
        weaponType: 'Pistols',
        combatStats:
            combatStatsMap[VisionaryClass.saboteur] ??
            CombatStats(atk: 1, def: 1, spd: 1, hp: 10),
      ),
      VisionaryData(
        id: 'light_theologist',
        displayName: 'Light Theologist',
        description:
            _loadedDescriptions['light_theologist_description'] ??
            'Default description',
        classType: VisionaryClass.lightTheologist.name,
        weaponType: 'Manifestations',
        combatStats:
            combatStatsMap[VisionaryClass.lightTheologist] ??
            CombatStats(atk: 1, def: 1, spd: 1, hp: 10),
      ),
      VisionaryData(
        id: 'victimizer',
        displayName: 'Victimizer',
        description:
            _loadedDescriptions['victimizer_description'] ??
            'Default description',
        classType: VisionaryClass.victimizer.name,
        weaponType: 'Close Combat',
        combatStats:
            combatStatsMap[VisionaryClass.victimizer] ??
            CombatStats(atk: 1, def: 1, spd: 1, hp: 10),
      ),
      VisionaryData(
        id: 'symbolist',
        displayName: 'Symbolist',
        description:
            _loadedDescriptions['symbolist_description'] ??
            'Default description',
        classType: VisionaryClass.symbolist.name,
        weaponType: 'Particle Matter',
        combatStats:
            combatStatsMap[VisionaryClass.symbolist] ??
            CombatStats(atk: 1, def: 1, spd: 1, hp: 10),
      ),
      VisionaryData(
        id: 'cosmologist',
        displayName: 'Cosmologist',
        description:
            _loadedDescriptions['cosmologist_description'] ??
            'Default description',
        classType: VisionaryClass.cosmologist.name,
        weaponType: 'Manifestations',
        combatStats:
            combatStatsMap[VisionaryClass.cosmologist] ??
            CombatStats(atk: 1, def: 1, spd: 1, hp: 10),
      ),
      VisionaryData(
        id: 'mossborn',
        displayName: 'Mossborn',
        description:
            _loadedDescriptions['mossborn_description'] ??
            'Default description',
        classType: VisionaryClass.mossborn.name,
        weaponType: 'Bow',
        combatStats:
            combatStatsMap[VisionaryClass.mossborn] ??
            CombatStats(atk: 1, def: 1, spd: 1, hp: 10),
      ),
      VisionaryData(
        id: 'farseer',
        displayName: 'Farseer',
        description:
            _loadedDescriptions['farseer_description'] ?? 'Default description',
        classType: VisionaryClass.farseer.name,
        weaponType: 'Pistols',
        combatStats:
            combatStatsMap[VisionaryClass.farseer] ??
            CombatStats(atk: 1, def: 1, spd: 1, hp: 10),
      ),
      VisionaryData(
        id: 'realist',
        displayName: 'Realist',
        description:
            _loadedDescriptions['realist_description'] ?? 'Default description',
        classType: VisionaryClass.realist.name,
        weaponType: 'Close Combat',
        combatStats:
            combatStatsMap[VisionaryClass.realist] ??
            CombatStats(atk: 1, def: 1, spd: 1, hp: 10),
      ),
    ];
  }
}
