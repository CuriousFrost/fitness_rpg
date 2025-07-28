//history_screen.dart
import 'package:flutter/material.dart';
import '../models/visionary_data.dart';
import '../models/workout_entry.dart';
import '../models/visionary_class.dart';
import '../logic/workout_data.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  VisionaryClass? _selectedClassFilter;
  String selectedFilter = 'Newest';

  final List<String> filterOptions = [
    'Newest',
    'Oldest',
    'Highest XP',
    'Lowest XP',
  ];

  void showEditWorkoutDialog(
    BuildContext context,
    int index,
    WorkoutEntry entry,
  ) {
    final TextEditingController distanceController = TextEditingController();
    final TextEditingController repsController = TextEditingController();
    final TextEditingController weightController = TextEditingController();

    bool isDistanceBased = [
      WorkoutType.walking,
      WorkoutType.running,
      WorkoutType.biking,
    ].contains(entry.type);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Workout'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isDistanceBased)
                TextField(
                  controller: distanceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Distance (km)'),
                )
              else ...[
                TextField(
                  controller: repsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Repetitions'),
                ),
                TextField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Weight (lbs)'),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                int newXp;
                String newDescription;
                double? newDistance; // For distance-based workouts

                // --- Calculate newXp, newDescription, newDistance based on inputs ---
                if (isDistanceBased) {
                  final double distanceVal =
                      double.tryParse(distanceController.text) ?? 0;
                  // Keep your existing XP calculation logic based on distance
                  newXp = (entry.type == WorkoutType.running)
                      ? (distanceVal * 10).round()
                      : (entry.type == WorkoutType.walking)
                      ? (distanceVal * 5).round()
                      : (distanceVal * 4).round(); // biking fallback
                  newDescription = entry.type.generateDescription(distanceVal);
                  newDistance = distanceVal;
                } else {
                  final int reps = int.tryParse(repsController.text) ?? 0;
                  final int weight = int.tryParse(weightController.text) ?? 0;
                  // Keep your existing XP calculation logic for weight/reps
                  double multiplier;
                  switch (entry.type) {
                    case WorkoutType.weightArm:
                      multiplier = 0.4;
                      break;
                    case WorkoutType.weightLeg:
                      multiplier = 0.2;
                      break;
                    case WorkoutType.weightChest:
                      multiplier = 0.3;
                      break;
                    case WorkoutType.weightBack:
                      multiplier = 0.4;
                      break;
                    default:
                      multiplier = 0.3;
                  }
                  newXp = (weight * reps * multiplier).round();
                  newDescription = entry.type.generateDescription(
                    weight.toDouble(),
                    reps,
                  );
                }

                // --- Create the new WorkoutEntry ---
                // IMPORTANT: Decide if you want to update the timestamp or keep the original.
                // Using entry.timestamp keeps the original workout time. DateTime.now() updates it.
                final WorkoutEntry originalEntry = entry; // The entry being edited

                final updatedEntry = WorkoutEntry(
                  visionary: originalEntry.visionary,
                  type: originalEntry.type,
                  description: newDescription,
                  xp: newXp,
                  timestamp: originalEntry.timestamp, // Or DateTime.now()
                  distance: newDistance,
                );


                // --- Update WorkoutData (which handles its own _characterXp) ---
                // 'actualIndex' was passed as 'index' to showEditWorkoutDialog,
                // or retrieve the original entry to pass to updateWorkout.
                // The 'entry' passed into this dialog is the original entry.
                workoutData.updateWorkout(
                  entry,
                  updatedEntry,
                ); // WorkoutData will notifyListeners

                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<WorkoutEntry> filteredHistory = List.from(workoutData.entries);

    if (_selectedClassFilter != null) {
      filteredHistory = filteredHistory
          .where((entry) => entry.visionary == _selectedClassFilter)
          .toList();
    }

    switch (selectedFilter) {
      case 'Newest':
        filteredHistory.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        break;
      case 'Oldest':
        filteredHistory.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        break;
      case 'Highest XP':
        filteredHistory.sort((a, b) => b.xp.compareTo(a.xp));
        break;
      case 'Lowest XP':
        filteredHistory.sort((a, b) => a.xp.compareTo(b.xp));
        break;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Workout History')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButton<VisionaryClass>(
                    value: _selectedClassFilter,
                    isExpanded: true,
                    hint: const Text('Filter by Visionary'),
                    onChanged: (newClass) {
                      setState(() => _selectedClassFilter = newClass);
                    },
                    items: VisionaryClass.values.map((c) {
                      return DropdownMenuItem(
                        value: c,
                        child: Text(c.displayName),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedFilter,
                    isExpanded: true,
                    onChanged: (value) {
                      setState(() {
                        selectedFilter = value!;
                      });
                    },
                    items: filterOptions.map((option) {
                      return DropdownMenuItem(
                        value: option,
                        child: Text(option),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: filteredHistory.isNotEmpty
                  ? ListView.builder(
                      itemCount: filteredHistory.length,
                      itemBuilder: (context, index) {
                        final entry = filteredHistory[index];
                        final actualIndex = workoutData.entries.indexOf(entry);

                        return Dismissible(
                          key: Key(entry.timestamp.toIso8601String()),
                          background: Container(
                            color: Colors.blue,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            child: const Icon(Icons.edit, color: Colors.white),
                          ),
                          secondaryBackground: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.startToEnd) {
                              showEditWorkoutDialog(
                                context,
                                actualIndex,
                                entry,
                              );
                              return false;
                            } else if (direction ==
                                DismissDirection.endToStart) {
                              final confirmed =
                                  await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Workout'),
                                      content: const Text(
                                        'Are you sure you want to delete this workout?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  ) ??
                                  false;

                              if (confirmed) {
                                final entryToDelete = entry; // 'entry' from the ListView.builder

                                // This single call updates _entries and _characterXp in WorkoutData
                                // and notifies listeners.
                                workoutData.deleteWorkout(entryToDelete);

                                // REMOVE VisionaryData.removeXpAndAdjustLevel(...)
                                return true;
                              }
                            }
                            return false;
                          },
                          child: ListTile(
                            title: Text(entry.description),
                            subtitle: Text(
                              '${entry.type.displayName} • ${entry.xp} XP • ${entry.timestamp.toLocal().toString().split('.')[0]}',
                            ),
                          ),
                        );
                      },
                    )
                  : const Center(child: Text('No workouts logged yet.')),
            ),
          ],
        ),
      ),
    );
  }
}
