import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitness_rpg/models/workout_entry.dart';
import '../models/visionary_class.dart';


// Updated workout_data.dart
const int maxXpTotal = 152960;

class WorkoutData {
  final List<WorkoutEntry> _entries = [];
  final Map<VisionaryClass, int> _characterXp = {
    for (var c in VisionaryClass.values) c: 0,
  };



  List<WorkoutEntry> get entries => _entries;

  Map<VisionaryClass, int> get characterXp => _characterXp;

  void addWorkout(WorkoutEntry entry) {
    _entries.add(entry);
    _characterXp[entry.characterClass] =
        (_characterXp[entry.characterClass] ?? 0) + entry.xp;
    save();
    if (_characterXp[entry.characterClass]! > maxXpTotal) {
      _characterXp[entry.characterClass] = maxXpTotal;
    }
  }

  void updateWorkout(WorkoutEntry oldEntry, WorkoutEntry newEntry) {
    final index = _entries.indexOf(oldEntry);
    if (index != -1) {
      _entries[index] = newEntry;
      _characterXp[oldEntry.characterClass] =
          ((_characterXp[oldEntry.characterClass] ?? 0) - oldEntry.xp)
              .clamp(0, double.infinity)
              .toInt();
      _characterXp[newEntry.characterClass] =
          (_characterXp[newEntry.characterClass] ?? 0) + newEntry.xp;
      save();
    }
  }

  void deleteWorkout(WorkoutEntry entry) {
    _entries.remove(entry);
    _characterXp[entry.characterClass] =
        ((_characterXp[entry.characterClass] ?? 0) - entry.xp)
            .clamp(0, double.infinity)
            .toInt();
    save();
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(_entries.map((e) => e.toJson()).toList());
    await prefs.setString('workouts', jsonString);

    final xpMap = _characterXp.map((k, v) => MapEntry(k.name, v));
    await prefs.setString('characterXp', jsonEncode(xpMap));
  }

  Future<void> load({bool resetXp = false}) async {
    final prefs = await SharedPreferences.getInstance();

    // Load workout entries
    final jsonString = prefs.getString('workouts');
    if (jsonString != null) {
      final List decoded = jsonDecode(jsonString);
      _entries.clear();
      _entries.addAll(decoded.map((e) => WorkoutEntry.fromJson(e)).toList());
    }

    // Load XP or reset conditionally
    _characterXp.clear();
    for (var c in VisionaryClass.values) {
      _characterXp[c] = 0;
    }

    if (!resetXp) {
      final xpString = prefs.getString('characterXp');
      if (xpString != null) {
        final Map<String, dynamic> decoded = jsonDecode(xpString);
        for (var entry in decoded.entries) {
          try {
            final classEnum = VisionaryClass.values.firstWhere(
              (e) => e.name == entry.key,
              orElse: () => VisionaryClass.bloodletter,
            );
            _characterXp[classEnum] = entry.value;
          } catch (_) {
            // Optionally log ignored enum value
          }
        }
      }
    }
  }
}
final WorkoutData workoutData = WorkoutData();