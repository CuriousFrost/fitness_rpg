// workout_screen.dart

import 'package:fitness_rpg/utils/ui_helpers.dart';
import 'package:flutter/material.dart';
import '../models/visionary_class.dart';
import '../models/workout_entry.dart';
import '../widgets/workout_input_dialog.dart';
import '../logic/workout_data.dart';
import '../models/visionary_data.dart';
import 'package:collection/collection.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  VisionaryClass? selectedClass;

  @override
  void initState() {
    super.initState();
    // It's good practice to ensure context is available for PageStorage.
    // Also, make sure that VisionaryData.load() and workoutData.load()
    // are called before this screen might try to use their data.
    // Often this is done in main.dart or a loading screen.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Ensure data is loaded before trying to read from it or PageStorage
      // If these are already loaded reliably at app startup, you might not need to await them here.
      // However, it's safer if this screen might be the first to access them.
      // await workoutData.load(); // Assuming workoutData is an instance you can call load on
      // await VisionaryData.load(); // Assuming VisionaryData has a static load method

      if (!mounted) return; // Check if the widget is still in the tree

      final stored = PageStorage.of(context)
          .readState(context, identifier: 'selectedClass') as String?;
      if (stored != null) {
        setState(() { // Call setState to update the UI if selectedClass changes
          selectedClass = VisionaryClass.values.firstWhere(
                (c) => c.name == stored);
        });
      } else if (VisionaryClass.values.isNotEmpty) {
        // Optionally set a default if none is stored and you want one
        // setState(() {
        //   selectedClass = VisionaryClass.values.first;
        // });
      }
      // If you modify selectedClass here, ensure it's within a setState call
      // if it's meant to trigger a rebuild.
    });
  } // <--- initState ENDS HERE

  // _onClassChanged should be a method of _WorkoutScreenState, not inside initState
  void _onClassChanged(VisionaryClass? newValue) {
    setState(() {
      selectedClass = newValue;
      PageStorage.of(
        context,
      ).writeState(context, newValue?.name, identifier: 'selectedClass');
    });
  }

  // build method should be a method of _WorkoutScreenState, not inside initState
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout Log')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<VisionaryClass>(
              key: const PageStorageKey<String>('classDropdown'),
              value: selectedClass,
              decoration: const InputDecoration(
                labelText: 'Select Visionary',
                border: OutlineInputBorder(),
              ),
              isExpanded: true,
              onChanged: _onClassChanged, // Correctly references the method
              items: VisionaryClass.values.map((c) {
                return DropdownMenuItem<VisionaryClass>(
                  value: c,
                  child: Text(c.displayName),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48)),
              onPressed: selectedClass == null
                  ? null
                  : () {
                showDialog(
                  context: context,
                  builder: (context) => WorkoutInputDialog(
                    onWorkoutLogged: (workoutType, description,
                        xpFromDialog, {double? distance}) async {
                      if (selectedClass == null) return;

                      final entry = WorkoutEntry(
                        visionary: selectedClass!,
                        type: workoutType,
                        xp: xpFromDialog,
                        description: description,
                        distance: distance,
                        timestamp: DateTime.now(),
                      );

                      // 1. Add entry to WorkoutData.
                      // This should ONLY update WorkoutData's internal state and save itself.
                      workoutData.addWorkout(entry);

                      // 2. Update VisionaryData with the XP from THIS workout entry.
                      VisionaryData.addXpAndLevelUp(
                          selectedClass!, xpFromDialog);

                      // UI Update and Popup
                      if (mounted) {
                        setState(() {}); // Update WorkoutScreen UI

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted) return; // Check mounted again

                          final int actualGainedXp = xpFromDialog;
                          final int finalLevel =
                              VisionaryData.classLevel[selectedClass!] ?? 1;
                          final int finalXpIntoLevel =
                              VisionaryData.classXp[selectedClass!] ?? 0;
                          final int xpNeededForFinalLevel =
                          VisionaryData.xpToNextLevel(finalLevel);

                          int oldXpDisplayForPopup;
                          // If a level up happened, the xp gain in the new level starts from 0 (or from what was left after previous level)
                          // If no level up, it's finalXp - gain.
                          if (VisionaryData.classLevel[selectedClass!]! > (VisionaryData.classLevel[selectedClass!]! - (finalXpIntoLevel < actualGainedXp ? 1:0) ) && finalXpIntoLevel < actualGainedXp) {
                            // This logic is trying to determine if a level up occurred from this XP.
                            // A simpler way: was the XP *before* adding xpFromDialog in a lower level or same level but less XP?
                            // Let's use the logic provided for oldXpDisplayForPopup
                            oldXpDisplayForPopup = (finalXpIntoLevel - actualGainedXp).clamp(0, xpNeededForFinalLevel);
                            if (finalXpIntoLevel < actualGainedXp) { // Indicates a level up likely happened and current finalXpIntoLevel is for the new level
                              oldXpDisplayForPopup = 0; // Start animation from 0 for the new level bar
                            }

                          } else {
                            oldXpDisplayForPopup = (finalXpIntoLevel - actualGainedXp).clamp(0, xpNeededForFinalLevel);
                          }
                          // Ensure it's not negative and not more than needed for the level
                          oldXpDisplayForPopup = oldXpDisplayForPopup.clamp(0, xpNeededForFinalLevel);


                          // More robust calculation for oldXpDisplayForPopup
                          // This requires knowing total XP *before* VisionaryData.addXpAndLevelUp processed xpFromDialog for the current level
                          // For simplicity, we're using the difference in the *final* level's XP.
                          // If finalXpIntoLevel is 50, and actualGainedXp is 30 (no level up), old was 20.
                          // If finalXpIntoLevel is 20 (new level), and actualGainedXp was 100 (level up), old on new bar is 0.
                          int previousXpForPopupCalculation = (VisionaryData.classXp[selectedClass!] ?? 0) - actualGainedXp;
                          int previousLevelForPopup = VisionaryData.classLevel[selectedClass!] ?? 1;

                          if (previousXpForPopupCalculation < 0) {
                            // Went into negative, meaning a level up occurred
                            oldXpDisplayForPopup = 0; // Start new level bar from 0
                            // A more complex scenario would track how much was needed for the *previous* level
                            // but for animating the *current/final* level bar, starting from 0 is often fine.
                          } else {
                            oldXpDisplayForPopup = previousXpForPopupCalculation;
                          }
                          oldXpDisplayForPopup = oldXpDisplayForPopup.clamp(0, xpNeededForFinalLevel);


                          showXpGainPopupWithBar(
                            context,
                            selectedClass!,
                            oldXpDisplayForPopup,
                            finalXpIntoLevel,
                            finalLevel,
                            xpNeededForFinalLevel,
                            actualGainedXp,
                          );
                        });
                      }
                    },
                  ),
                );
              },
              child: const Text('Log Workout'),
            ),
            const SizedBox(height: 20),
            if (selectedClass != null)
            // Using a simple ValueListenableBuilder for demonstration.
            // If VisionaryData's maps are not ValueNotifiers,
            // this will only build once unless the key changes or an ancestor rebuilds.
            // setState() in onWorkoutLogged will trigger a rebuild of this part.
              Builder( // Using Builder to get updated values after setState
                builder: (context) {
                  final level = VisionaryData.classLevel[selectedClass!] ?? 1;
                  final currentXp = VisionaryData.classXp[selectedClass!] ?? 0;
                  final nextXp = VisionaryData.xpToNextLevel(level);
                  // Ensure nextXp is not zero to avoid division by zero,
                  // and progress is clamped between 0.0 and 1.0.
                  final double progress = (nextXp > 0 && currentXp <= nextXp)
                      ? (currentXp.toDouble() / nextXp.toDouble())
                      : (level >= VisionaryData.maxLevel || currentXp >=nextXp && nextXp > 0 ? 1.0 : 0.0) ;


                  return Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${selectedClass!.displayName} - Level $level",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          if (level < VisionaryData.maxLevel) ...[
                            Text("XP: $currentXp / $nextXp"),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: progress.clamp(0.0, 1.0), // Ensure clamped
                              minHeight: 10,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).primaryColor),
                            ),
                          ] else ...[
                            Text("XP: $currentXp (Max Level Reached)"), // Show current XP even at max
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: 1.0, // Full bar at max level
                              minHeight: 10,
                              backgroundColor: Colors.grey[300],
                              valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.amber),
                            ),
                          ]
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  } // <--- build method ENDS HERE
}