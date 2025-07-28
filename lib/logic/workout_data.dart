// workout_data.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/visionary_class.dart';
import '../models/workout_entry.dart';
import 'package:flutter/foundation.dart';




// Updated workout_data.dart
const int maxXpTotal = 152960; // Is this a per-character max, or overall?
// If per-character, VisionaryData should probably know about it too.

class WorkoutData with ChangeNotifier { // Mixin ChangeNotifier
  final List<WorkoutEntry> _entries = [];
  final Map<VisionaryClass, int> _characterXp = {
    for (var c in VisionaryClass.values) c: 0,
  };

  List<WorkoutEntry> get entries => List.unmodifiable(_entries); // Good practice
  Map<VisionaryClass, int> get characterXp => Map.unmodifiable(_characterXp);

  void addWorkout(WorkoutEntry entry) {
    _entries.add(entry);
    _characterXp[entry.visionary] = (_characterXp[entry.visionary] ?? 0) + entry.xp;

    // --- VisionaryData.addXpAndLevelUp IS NO LONGER CALLED HERE ---
    // --- VisionaryData.save() IS NO LONGER CALLED HERE ---

    if (_characterXp[entry.visionary]! > maxXpTotal) {
      _characterXp[entry.visionary] = maxXpTotal;
    }

    save(); // Saves WorkoutData's state (_entries and _characterXp)
    notifyListeners(); // <--- Notify listeners


    print("WorkoutData: Added workout for ${entry.visionary.name}, Entry XP: ${entry.xp}");
    print("WorkoutData: Total XP in _characterXp for ${entry.visionary.name}: ${_characterXp[entry.visionary]}");
  }

  void updateWorkout(WorkoutEntry oldEntry, WorkoutEntry newEntry) {
    final index = _entries.indexOf(oldEntry);
    if (index != -1) {
      // Adjust WorkoutData's total XP for the old entry
      _characterXp[oldEntry.visionary] =
          ((_characterXp[oldEntry.visionary] ?? 0) - oldEntry.xp)
              .clamp(0, maxXpTotal); // Clamp to 0 and its own max
      _entries[index] = newEntry; // Replace the entry

      // Add XP for the new entry to WorkoutData's total
      _characterXp[newEntry.visionary] =
          ((_characterXp[newEntry.visionary] ?? 0) + newEntry.xp)
              .clamp(0, maxXpTotal);
      save();
      notifyListeners();
    }
  }

  void deleteWorkout(WorkoutEntry entry) {
    _entries.remove(entry);
    _characterXp[entry.visionary] =
        ((_characterXp[entry.visionary] ?? 0) - entry.xp)
            .clamp(0, maxXpTotal); // maxXpTotal for _characterXp
    // VisionaryData.removeXpAndAdjustLevel IS CALLED EXTERNALLY BEFORE THIS
    save();
    notifyListeners();
    print("WorkoutData: Deleted workout for ${entry.visionary.name}. XP removed: ${entry.xp}");
    print("WorkoutData: Total XP in _characterXp for ${entry.visionary.name}: ${_characterXp[entry.visionary]}");
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    print("WorkoutData: Attempting to save...");

    // SAVING _entries
    if (_entries.isEmpty) {
      print("WorkoutData SAVE: _entries is EMPTY. Saving an empty list representation.");
    } else {
      print("WorkoutData SAVE: _entries has ${_entries.length} items. First item desc: ${_entries.first.description}");
    }
    final List<Map<String, dynamic>> entriesJsonList = _entries.map((e) => e.toJson()).toList();
    final String jsonString = jsonEncode(entriesJsonList);
    print("WorkoutData SAVE: JSON string for 'workouts': $jsonString"); // Log the actual JSON

    try {
      await prefs.setString('workouts', jsonString);
      print("WorkoutData SAVE: Successfully saved 'workouts'.");
    } catch (e) {
      print("WorkoutData SAVE: ERROR saving 'workouts': $e");
    }

    // SAVING _characterXp
    if (_characterXp.isEmpty) {
      print("WorkoutData SAVE: _characterXp is EMPTY.");
    } else {
      print("WorkoutData SAVE: _characterXp content: $_characterXp");
    }
    final xpMap = _characterXp.map((k, v) => MapEntry(k.name, v));
    final String characterXpJsonString = jsonEncode(xpMap);
    print("WorkoutData SAVE: JSON string for 'characterXp': $characterXpJsonString");

    try {
      await prefs.setString('characterXp', characterXpJsonString);
      print("WorkoutData SAVE: Successfully saved 'characterXp'.");
      print("WorkoutData: Save completed.");
    } catch (e) {
      print("WorkoutData SAVE: ERROR saving 'characterXp': $e");
    }
  }

  Future<void> load({bool resetXp = false}) async {
    final prefs = await SharedPreferences.getInstance();
    print("WorkoutData: Attempting to load data...");

    // --- LOADING _entries ---
    _entries.clear(); // Good.
    print("WorkoutData LOAD: _entries cleared.");

    final String? jsonString = prefs.getString('workouts'); // Key: "workouts"
    if (jsonString == null) {
      print("WorkoutData LOAD: No data found for key 'workouts' in SharedPreferences.");
    } else if (jsonString.isEmpty || jsonString == "[]") {
      print("WorkoutData LOAD: Found key 'workouts', but it's empty or an empty list string: '$jsonString'");
    } else {
      print("WorkoutData LOAD: Found data for 'workouts': $jsonString");
      try {
        final List<dynamic> decodedList = jsonDecode(jsonString); // Use List<dynamic>
        print("WorkoutData LOAD: Successfully decoded 'workouts' JSON. Number of items in decoded list: ${decodedList.length}");

        if (decodedList.isNotEmpty) {
          print("WorkoutData LOAD: First item in decoded list (raw): ${decodedList.first}");
        }

        _entries.addAll(decodedList.map((e) {
          try {
            // Explicitly cast 'e' to Map<String, dynamic>
            if (e is Map<String, dynamic>) {
              print("WorkoutData LOAD: Attempting WorkoutEntry.fromJson for item: $e");
              WorkoutEntry entry = WorkoutEntry.fromJson(e);
              print("WorkoutData LOAD: Successfully created WorkoutEntry: ${entry.description}");
              return entry;
            } else {
              print("WorkoutData LOAD: ERROR - Decoded item is not a Map<String, dynamic>: $e. Skipping.");
              return null; // Will be filtered out by .where((entry) => entry != null)
            }
          } catch (ex) {
            print("WorkoutData LOAD: ERROR in WorkoutEntry.fromJson for item $e: $ex");
            return null; // Skip problematic entries
          }
        }).where((entry) => entry != null).cast<WorkoutEntry>().toList()); // Filter out nulls and cast

        print("WorkoutData LOAD: After processing, _entries has ${_entries.length} items.");
        if (_entries.isNotEmpty) {
          print("WorkoutData LOAD: First loaded entry desc: ${_entries.first.description}");
        }
      } catch (e) {
        print("WorkoutData LOAD: ERROR decoding 'workouts' JSON or processing entries: $e");
        // _entries will remain empty or partially filled if decoding fails mid-way
      }
    }
    print("WorkoutData LOAD: Finished loading _entries. Count: ${_entries.length}");

    // --- LOADING _characterXp --- (Keep your existing try-catch and logging here too)
    _characterXp.clear();
    for (var c in VisionaryClass.values) {
      _characterXp[c] = 0;
    }
    print("WorkoutData LOAD: _characterXp cleared and initialized.");

    if (!resetXp) {
      final String? xpString = prefs.getString('characterXp');
      if (xpString == null) {
        print("WorkoutData LOAD: No data found for key 'characterXp'.");
      } else if (xpString.isEmpty || xpString == "{}") {
        print("WorkoutData LOAD: Found key 'characterXp', but it's empty or an empty map string: '$xpString'");
      } else {
        print("WorkoutData LOAD: Found data for 'characterXp': $xpString");
        try {
          final Map<String, dynamic> decodedXpMap = jsonDecode(xpString);
          print("WorkoutData LOAD: Successfully decoded 'characterXp' JSON.");
          decodedXpMap.forEach((key, value) {
            try {
              final classEnum = VisionaryClass.values.firstWhere((e) => e.name == key);
              if (value is int) {
                _characterXp[classEnum] = value;
                print("WorkoutData LOAD: Loaded XP for $key: $value");
              } else {
                print("WorkoutData LOAD: ERROR - XP value for $key is not an int: $value. Setting to 0.");
                _characterXp[classEnum] = 0;
              }
            } catch (e) {
              print("WorkoutData LOAD: ERROR processing _characterXp for key $key (value: $value): $e. Setting to 0.");
              // Attempt to find enum again just in case, though it should be caught by outer try-catch for malformed key.
              try {
                final classEnum = VisionaryClass.values.firstWhere((e) => e.name == key);
                _characterXp[classEnum] = 0;
              } catch (_) {
                print("WorkoutData LOAD: ERROR - Could not find VisionaryClass for key $key during error handling.");
              }
            }
          });
        } catch (e) {
          print("WorkoutData LOAD: ERROR decoding 'characterXp' JSON: $e");
        }
      }
    }
    print("WorkoutData LOAD: Finished loading _characterXp: $_characterXp");
    print("WorkoutData: Load data completed.");
    // No notifyListeners() here usually.
  }
}

final WorkoutData workoutData = WorkoutData();