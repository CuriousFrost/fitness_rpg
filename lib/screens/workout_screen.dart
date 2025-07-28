// workout_screen.dart

import 'package:fitness_rpg/utils/ui_helpers.dart';
import 'package:flutter/material.dart';
import '../models/visionary_class.dart';
import '../models/workout_entry.dart';
import '../widgets/workout_input_dialog.dart';
import '../logic/workout_data.dart'; // Ensure this is your global instance or provided
import '../models/visionary_data.dart'; // For calculateLevelAndProgress and constants
// import 'package:collection/collection.dart'; // Not strictly needed here anymore for this logic
// import 'package:provider/provider.dart'; // UNCOMMENT if you set up Provider for workoutData

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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final stored =
          PageStorage.of(
                context,
              ).readState(context, identifier: 'selectedClass')
              as String?;
      if (stored != null) {
        setState(() {
          selectedClass = VisionaryClass.values.firstWhereOrNull(
            (c) => c.name == stored,
          ); // Use firstWhereOrNull
        });
      }
      // If using Provider for workoutData, you might listen to it here for updates
      // workoutData.addListener(_onWorkoutDataChanged);
    });
  }

  // Optional: If not using Provider's Consumer/watch, a listener can help
  // void _onWorkoutDataChanged() {
  //   if (mounted) {
  //     setState(() {
  //       // This will cause the Builder widget to rebuild if selectedClass is not null
  //     });
  //   }
  // }

  // @override
  // void dispose() {
  //   // workoutData.removeListener(_onWorkoutDataChanged); // If you added a listener
  //   super.dispose();
  // }

  void _onClassChanged(VisionaryClass? newValue) {
    setState(() {
      selectedClass = newValue;
      PageStorage.of(
        context,
      ).writeState(context, newValue?.name, identifier: 'selectedClass');
    });
  }

  @override
  Widget build(BuildContext context) {
    // If using Provider:
    // final workoutDataProvider = context.watch<WorkoutData>(); // Rebuilds when workoutData notifies

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
              onChanged: _onClassChanged,
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
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: selectedClass == null
                  ? null
                  : () {
                      showDialog(
                        context: context,
                        builder: (context) => WorkoutInputDialog(
                          onWorkoutLogged: (workoutType, description, xpFromDialog, {double? distance}) async {
                            if (selectedClass == null) return;

                            // --- Logic for XP Gain Popup ---
                            // 1. Get total XP *before* adding the new workout's XP
                            final int totalXpBeforeThisWorkout =
                                workoutData.characterXp[selectedClass!] ?? 0;

                            // 2. Calculate level/progress *before*
                            final Map<String, int> progressBefore =
                                VisionaryData.calculateLevelAndProgress(
                                  totalXpBeforeThisWorkout,
                                );

                            // 3. Create the workout entry
                            final entry = WorkoutEntry(
                              visionary: selectedClass!,
                              type: workoutType,
                              xp: xpFromDialog,
                              description: description,
                              distance: distance,
                              timestamp: DateTime.now(),
                            );

                            // 4. Add entry to WorkoutData. This updates its internal state (_characterXp)
                            // and calls notifyListeners().
                            workoutData.addWorkout(entry);

                            // 5. If not using Provider.watch or Consumer for the XP bar below,
                            //    this setState will help trigger its rebuild.
                            if (mounted) {
                              setState(() {});
                            }

                            // --- UI Update and Popup Call ---
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (!mounted) return;

                              // 6. Get total XP *after* adding the new workout's XP
                              final int totalXpAfterThisWorkout =
                                  workoutData.characterXp[selectedClass!] ?? 0;

                              // 7. Calculate level/progress *after*
                              final Map<String, int> progressAfter =
                                  VisionaryData.calculateLevelAndProgress(
                                    totalXpAfterThisWorkout,
                                  );

                              final int actualGainedXp = xpFromDialog;
                              final int finalLevel = progressAfter['level']!;
                              final int finalXpIntoLevel =
                                  progressAfter['xpIntoCurrentLevel']!;
                              final int xpNeededForFinalLevel =
                                  progressAfter['xpNeededForNextLevel']!;

                              // oldXpDisplayForPopup should be the xpIntoCurrentLevel *before* this workout,
                              // but for the level the character *ended up in*.
                              // If a level up occurred, the "old" XP on the new level's bar is 0.
                              // If no level up, it's currentXP - gainedXP for that same level.
                              int oldXpDisplayForPopup;
                              if (progressAfter['level']! >
                                  progressBefore['level']!) {
                                // Level up occurred
                                oldXpDisplayForPopup = 0;
                              } else {
                                // Same level
                                oldXpDisplayForPopup =
                                    progressBefore['xpIntoCurrentLevel']!;
                              }

                              // This ensures the animation doesn't start from a negative or beyond the bar.
                              oldXpDisplayForPopup = oldXpDisplayForPopup.clamp(
                                0,
                                xpNeededForFinalLevel,
                              );

                              showXpGainPopupWithBar(
                                context,
                                selectedClass!,
                                oldXpDisplayForPopup, // XP bar starts here for animation
                                finalXpIntoLevel, // XP bar ends here for animation
                                finalLevel, // The level achieved
                                xpNeededForFinalLevel, // Total XP needed for this (final) level
                                actualGainedXp, // The amount of XP just gained
                                // Optional: pass levelBefore if your popup uses it for "Level Up!" text
                                levelBefore: progressBefore['level']!,
                              );
                            });
                          },
                        ),
                      );
                    },
              child: const Text('Log Workout'),
            ),
            const SizedBox(height: 20),
            if (selectedClass != null)
              // OPTION 1: Using the existing Builder and relying on setState in onWorkoutLogged
              // This works because workoutData is global, and setState will rebuild this part.
              Builder(
                builder: (context) {
                  // Fetch total XP from the global workoutData instance
                  final int totalHistoricalXp =
                      workoutData.characterXp[selectedClass!] ?? 0;

                  // Calculate current level and progress using VisionaryData utility
                  final Map<String, int> levelProgress =
                      VisionaryData.calculateLevelAndProgress(
                        totalHistoricalXp,
                      );
                  final int level = levelProgress['level']!;
                  final int currentXp = levelProgress['xpIntoCurrentLevel']!;
                  final int nextXp = levelProgress['xpNeededForNextLevel']!;

                  final double progressFraction = (nextXp > 0)
                      ? (currentXp.toDouble() / nextXp.toDouble()).clamp(
                          0.0,
                          1.0,
                        )
                      : (level >= VisionaryData.maxLevel ? 1.0 : 0.0);

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
                          if (level < VisionaryData.maxLevel && nextXp > 0) ...[
                            Text("XP: $currentXp / $nextXp"),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: progressFraction,
                              minHeight: 10,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor,
                              ),
                            ),
                          ] else ...[
                            Text("XP: $currentXp (Max Level Reached)"),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: 1.0, // Full bar at max level
                              minHeight: 10,
                              backgroundColor: Colors.grey[300],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.amber,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            // OPTION 2: If you use Provider for workoutData (recommended for larger apps)
            // UNCOMMENT this and COMMENT OUT the Builder above if you go with Provider
            // Consumer<WorkoutData>(
            //   builder: (context, wd, child) {
            //     if (selectedClass == null) return const SizedBox.shrink();

            //     final int totalHistoricalXp = wd.characterXp[selectedClass!] ?? 0;
            //     final Map<String, int> levelProgress = VisionaryData.calculateLevelAndProgress(totalHistoricalXp);
            //     final int level = levelProgress['level']!;
            //     final int currentXp = levelProgress['xpIntoCurrentLevel']!;
            //     final int nextXp = levelProgress['xpNeededForNextLevel']!;
            //     final double progressFraction = (nextXp > 0)
            //         ? (currentXp.toDouble() / nextXp.toDouble()).clamp(0.0, 1.0)
            //         : (level >= VisionaryData.maxLevel ? 1.0 : 0.0);

            //     return Card( /* ... same card structure as above ... */ );
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}

// Helper for firstWhereOrNull if you don't have collection package or want to avoid it for one use
extension FirstWhereOrNullExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E element) test) {
    for (E element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
