// models/visionary_data.dart
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/visionary_class.dart';
import '../models/combat_stats.dart';


class VisionaryData {
  final String id;
  final String displayName;
  final String description;
  final String classType;
  final String weaponType;
  final CombatStats combatStats;

  VisionaryData({
    required this.id,
    required this.displayName,
    required this.description,
    required this.classType,
    required this.weaponType,
    required this.combatStats,
  });

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
}
