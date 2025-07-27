// models/visionary_data.dart
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

  static int xpToNextLevel(int level) {
    return (100 * pow(1.1, level - 1)).ceil();
  }

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
