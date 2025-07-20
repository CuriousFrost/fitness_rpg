import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitness_rpg/models/workout_entry.dart';
import '../models/character_class.dart';

// Updated workout_data.dart


class WorkoutData {
  final List<WorkoutEntry> _entries = [];
  final Map<CharacterClass, int> _characterXp = {
    for (var c in CharacterClass.values) c: 0,
  };

  List<WorkoutEntry> get entries => _entries;

  Map<CharacterClass, int> get characterXp => _characterXp;

  void addWorkout(WorkoutEntry entry) {
    _entries.add(entry);
    _characterXp[entry.characterClass] =
        (_characterXp[entry.characterClass] ?? 0) + entry.xp;
    save();
  }

  void updateWorkout(WorkoutEntry oldEntry, WorkoutEntry newEntry) {
    final index = _entries.indexOf(oldEntry);
    if (index != -1) {
      _entries[index] = newEntry;
      _characterXp[oldEntry.characterClass] =
          ((_characterXp[oldEntry.characterClass] ?? 0) - oldEntry.xp).clamp(
              0, double.infinity).toInt();
      _characterXp[newEntry.characterClass] =
          (_characterXp[newEntry.characterClass] ?? 0) + newEntry.xp;
      save();
    }
  }

  void deleteWorkout(WorkoutEntry entry) {
    _entries.remove(entry);
    _characterXp[entry.characterClass] =
        ((_characterXp[entry.characterClass] ?? 0) - entry.xp).clamp(
            0, double.infinity).toInt();
    save();
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(_entries.map((e) => e.toJson()).toList());
    await prefs.setString('workouts', jsonString);

    final xpMap = _characterXp.map((k, v) => MapEntry(k.toString(), v));
    await prefs.setString('characterXp', jsonEncode(xpMap));
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    // Load workouts
    final jsonString = prefs.getString('workouts');
    if (jsonString != null) {
      final List decoded = jsonDecode(jsonString);
      _entries.clear();
      _entries.addAll(decoded.map((e) => WorkoutEntry.fromJson(e)).toList());
    }

    // Reset XP map to 0
    _characterXp.clear();
    for (var c in CharacterClass.values) {
      _characterXp[c] = 0;
    }

    // Load XP values if present
    final xpString = prefs.getString('characterXp');
    if (xpString != null) {
      final Map<String, dynamic> decoded = jsonDecode(xpString);
      for (var entry in decoded.entries) {
        try {
          final classEnum = CharacterClass.values.firstWhere(
                (e) => e.toString() == entry.key,
            orElse: () => CharacterClass.bloodletter, // fallback
          );
          _characterXp[classEnum] = (entry.value as int?) ?? 0;
        } catch (_) {
          // Silently skip bad data
        }
      }
    }
  }
  }