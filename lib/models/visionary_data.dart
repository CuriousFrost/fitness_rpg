// visionary_data.dart
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
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
  static final Map<VisionaryClass, int> classXp = {
    for (var c in VisionaryClass.values) c: 0,
  };

  static final Map<VisionaryClass, int> classLevel = {
    for (var c in VisionaryClass.values) c: 1,
  };

  static const int maxXpTotal = 152960;
  static const int maxLevel = 150;
  static const double levelXpMultiplier = 1.2;
  static const int baseXpForLevelUp = 100;

  static int xpToNextLevel(int currentLevel) {
    if (currentLevel >= maxLevel) {
      return 0; // Or a very large number if you want to show a full bar but no more levels
    }
    if (currentLevel < 1) currentLevel = 1;
    // Example: XP needed to complete currentLevel and reach currentLevel + 1
    return (baseXpForLevelUp * (pow(levelXpMultiplier, currentLevel - 1)))
        .round();
  }

  // --- XP AND LEVELING LOGIC ---
  // V V V V V V V V V V V V V V V V V V V V V V V V V V V V V V V V V V V
  // THIS IS WHERE THE MISSING METHOD GOES
  // V V V V V V V V V V V V V V V V V V V V V V V V V V V V V V V V V V V
  static void addXpAndLevelUp(VisionaryClass visionary, int xpGained) {
    if (xpGained <= 0) return;

    int currentLevel = classLevel[visionary] ?? 1;
    int currentXpInLevel = classXp[visionary] ?? 0;

    // Prevent XP gain if already at max level
    if (currentLevel >= maxLevel) {
      print(
        "${visionary.name} is at max level ($maxLevel). No XP gained for leveling.",
      );
      // You might still want to call save() if other data could have changed,
      // but for simple XP/Level, no change means no save needed for this path.
      return;
    }

    currentXpInLevel += xpGained;

    int xpNeededForNext = xpToNextLevel(currentLevel);

    // Loop to handle multiple level-ups from a single XP gain
    while (currentLevel < maxLevel &&
        xpNeededForNext > 0 &&
        currentXpInLevel >= xpNeededForNext) {
      currentLevel++;
      currentXpInLevel -= xpNeededForNext; // Subtract XP used for this level-up
      classLevel[visionary] = currentLevel;
      print("LEVEL UP! ${visionary.name} reached Level $currentLevel!");

      if (currentLevel >= maxLevel) {
        // If max level is reached, cap XP to the amount needed for the final level's bar
        // or set to 0 if you prefer an empty bar at max (though full is common)
        classXp[visionary] = xpToNextLevel(
          maxLevel - 1,
        ); // Fills the bar of the max level
        classLevel[visionary] = maxLevel; // Ensure level is capped
        print("${visionary.name} reached MAX Level $maxLevel!");
        save(); // Save changes
        return; // Exit as max level is reached
      }
      xpNeededForNext = xpToNextLevel(
        currentLevel,
      ); // Get XP needed for the new current level
    }

    // Update XP for the current level (which might be the same or a new one after leveling)
    classXp[visionary] = currentXpInLevel;

    print(
      "VisionaryData: ${visionary.name} gained $xpGained XP. Level: $currentLevel, XP: ${classXp[visionary]}/$xpNeededForNext",
    );
    save(); // Save changes to SharedPreferences
  }

  static void removeXpAndAdjustLevel(VisionaryClass visionary, int xpToRemove) {
    if (xpToRemove <= 0) return;

    int currentLevel = classLevel[visionary] ?? 1;
    int currentXpInLevel = classXp[visionary] ?? 0;
    int totalXpForClass = 0; // We need the TOTAL XP for this visionary

    // Calculate total historical XP for this visionary class
    // This is tricky because you only store currentXpInLevel.
    // Option A: Recalculate from level 1 up to currentLevel-1, then add currentXpInLevel
    for (int i = 1; i < currentLevel; i++) {
      totalXpForClass += xpToNextLevel(i);
    }
    totalXpForClass += currentXpInLevel;

    // Now subtract the xpToRemove from this total
    totalXpForClass -= xpToRemove;
    if (totalXpForClass < 0) totalXpForClass = 0;

    // Reset and recalculate level and XP from the new totalXpForClass
    classLevel[visionary] = 1;
    classXp[visionary] = 0;
    currentLevel = 1;   // Reset for recalculation
    currentXpInLevel = 0; // Reset for recalculation

    int tempAccumulatedXp = 0;
    while (true) {
      int xpNeededForNext = xpToNextLevel(currentLevel);
      if (currentLevel >= maxLevel) { // Reached max level during recalculation
        classLevel[visionary] = maxLevel;
        // If totalXpForClass exceeds XP for max level, cap it or show it as full.
        // For simplicity, let's just assign remaining. This might make the bar exceed 100% if not handled in UI.
        // A better way is to set classXp[visionary] to xpToNextLevel(maxLevel -1) if totalXpForClass is high enough.
        classXp[visionary] = totalXpForClass - tempAccumulatedXp;
        if (classXp[visionary]! > xpToNextLevel(maxLevel-1) && xpToNextLevel(maxLevel-1) > 0) {
          classXp[visionary] = xpToNextLevel(maxLevel-1);
        } else if (xpToNextLevel(maxLevel-1) == 0) { // Max level needs 0 more XP
          classXp[visionary] = 0;
        }
        break;
      }

      if (totalXpForClass >= tempAccumulatedXp + xpNeededForNext) {
        tempAccumulatedXp += xpNeededForNext;
        currentLevel++;
        classLevel[visionary] = currentLevel;
      } else {
        classXp[visionary] = totalXpForClass - tempAccumulatedXp;
        break;
      }
    }

    print(
      "VisionaryData: ${visionary.name} had $xpToRemove XP removed. New Level: ${classLevel[visionary]}, New XP: ${classXp[visionary]}",
    );
    save(); // Save changes
  }
  // ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^
  // END OF addXpAndLevelUp METHOD
  // ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^

  static Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    final xpJson = jsonEncode(classXp.map((k, v) => MapEntry(k.name, v)));
    final levelJson = jsonEncode(classLevel.map((k, v) => MapEntry(k.name, v)));
    await prefs.setString('classXp', xpJson);
    await prefs.setString('classLevel', levelJson);
  }

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final xpJson = prefs.getString('classXp');
    final levelJson = prefs.getString('classLevel');
    if (xpJson != null && levelJson != null) {
      final Map<String, dynamic> xpMap = jsonDecode(xpJson);
      final Map<String, dynamic> levelMap = jsonDecode(levelJson);
      for (var c in VisionaryClass.values) {
        classXp[c] = xpMap[c.name] ?? 0;
        classLevel[c] = levelMap[c.name] ?? 1;
      }
    }
  }

  // Static list of predefined VisionaryData instances
  // Now using combatStatsMap to get the base stats
  // ---- MODIFIED SECTION FOR DESCRIPTIONS AND PREDEFINED VISIONARIES ----

  // Private static field to hold the loaded descriptions
  static Map<String, String> _loadedDescriptions = {};

  // Public static getter for predefined visionaries.
  // It's 'late final' because it will be initialized by _initializeVisionaries.
  static late final List<VisionaryData> predefinedVisionaries;

  // A flag to ensure initialization happens only once.
  static bool _isInitialized = false;

  // Static method to load descriptions and initialize predefinedVisionaries
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
      print("Error loading visionary descriptions: $e");
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
