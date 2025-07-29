// workout_data.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/visionary_class.dart';
import '../models/workout_entry.dart';
import 'package:flutter/foundation.dart';
import 'visionary_data.dart';

// Updated workout_data.dart
const int maxXpTotal = 152960; // Is this a per-character max, or overall?
// If per-character, VisionaryData should probably know about it too.

class WorkoutData with ChangeNotifier {
  final List<WorkoutEntry> _entries = [];
  final Map<VisionaryClass, int> _characterXp = {
    for (var c in VisionaryClass.values) c: 0,
  };

  List<WorkoutEntry> get entries => List.unmodifiable(_entries);
  Map<VisionaryClass, int> get characterXp =>
      Map.unmodifiable(_characterXp); // This is our source of total XP

  void addWorkout(WorkoutEntry entry) {
    _entries.add(entry);
    _characterXp[entry.visionary] =
        ((_characterXp[entry.visionary] ?? 0) + entry.xp).clamp(
          0,
          VisionaryData.maxXpTotal,
        ); // Clamp using VisionaryData's max

    save();
    notifyListeners();
  }

  void updateWorkout(WorkoutEntry oldEntry, WorkoutEntry newEntry) {
    final index = _entries.indexOf(oldEntry);
    if (index != -1) {
      // Adjust WorkoutData's total XP for the old entry
      _characterXp[oldEntry.visionary] =
          ((_characterXp[oldEntry.visionary] ?? 0) - oldEntry.xp);

      _entries[index] = newEntry; // Replace the entry

      // Add XP for the new entry to WorkoutData's total
      _characterXp[newEntry.visionary] =
          ((_characterXp[newEntry.visionary] ?? 0) + newEntry.xp).clamp(
            0,
            VisionaryData.maxXpTotal,
          );

      save();
      notifyListeners();
    }
  }

  void deleteWorkout(WorkoutEntry entry) {
    _entries.remove(entry);
    _characterXp[entry.visionary] =
        ((_characterXp[entry.visionary] ?? 0) - entry.xp).clamp(
          0,
          VisionaryData.maxXpTotal,
        );

    save();
    notifyListeners();
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();

    // SAVING _entries
    if (_entries.isEmpty) {
    } else {}
    final List<Map<String, dynamic>> entriesJsonList = _entries
        .map((e) => e.toJson())
        .toList();
    final String jsonString = jsonEncode(entriesJsonList);
    // Log the actual JSON

    try {
      await prefs.setString('workouts', jsonString);
    } catch (e) {}

    // SAVING _characterXp
    if (_characterXp.isEmpty) {
    } else {}
    final xpMap = _characterXp.map((k, v) => MapEntry(k.name, v));
    final String characterXpJsonString = jsonEncode(xpMap);

    try {
      await prefs.setString('characterXp', characterXpJsonString);
    } catch (e) {}
  }

  Future<void> load({bool resetXp = false}) async {
    final prefs = await SharedPreferences.getInstance();

    // --- LOADING _entries ---
    _entries.clear(); // Good.

    final String? jsonString = prefs.getString('workouts'); // Key: "workouts"
    if (jsonString == null) {
    } else if (jsonString.isEmpty || jsonString == "[]") {
    } else {
      try {
        final List<dynamic> decodedList = jsonDecode(
          jsonString,
        ); // Use List<dynamic>

        if (decodedList.isNotEmpty) {}

        _entries.addAll(
          decodedList
              .map((e) {
                try {
                  // Explicitly cast 'e' to Map<String, dynamic>
                  if (e is Map<String, dynamic>) {
                    WorkoutEntry entry = WorkoutEntry.fromJson(e);
                    return entry;
                  } else {
                    return null; // Will be filtered out by .where((entry) => entry != null)
                  }
                } catch (ex) {
                  return null; // Skip problematic entries
                }
              })
              .where((entry) => entry != null)
              .cast<WorkoutEntry>()
              .toList(),
        ); // Filter out nulls and cast

        if (_entries.isNotEmpty) {}
      } catch (e) {
        // _entries will remain empty or partially filled if decoding fails mid-way
      }
    }

    // --- LOADING _characterXp --- (Keep your existing try-catch and logging here too)
    _characterXp.clear();
    for (var c in VisionaryClass.values) {
      _characterXp[c] = 0;
    }

    if (!resetXp) {
      final String? xpString = prefs.getString('characterXp');
      if (xpString == null) {
      } else if (xpString.isEmpty || xpString == "{}") {
      } else {
        try {
          final Map<String, dynamic> decodedXpMap = jsonDecode(xpString);
          decodedXpMap.forEach((key, value) {
            try {
              final classEnum = VisionaryClass.values.firstWhere(
                (e) => e.name == key,
              );
              if (value is int) {
                _characterXp[classEnum] = value;
              } else {
                _characterXp[classEnum] = 0;
              }
            } catch (e) {
              // Attempt to find enum again just in case, though it should be caught by outer try-catch for malformed key.
              try {
                final classEnum = VisionaryClass.values.firstWhere(
                  (e) => e.name == key,
                );
                _characterXp[classEnum] = 0;
              } catch (_) {}
            }
          });
        } catch (e) {}
      }
    }
    // No notifyListeners() here usually.
  }
}

final WorkoutData workoutData = WorkoutData();
