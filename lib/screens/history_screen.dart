// screens/history_screen.dart
import 'package:flutter/material.dart';
import '../models/workout_entry.dart';
import '../models/character_class.dart';
import '../logic/workout_data.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  CharacterClass? _selectedClassFilter;
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

                if (isDistanceBased) {
                  final double distance =
                      double.tryParse(distanceController.text) ?? 0;
                  newXp = (entry.type == WorkoutType.running)
                      ? (distance * 10).round()
                      : (entry.type == WorkoutType.walking)
                      ? (distance * 5).round()
                      : (distance * 4).round(); // biking fallback
                  newDescription = entry.type.generateDescription(distance);
                } else {
                  final int reps = int.tryParse(repsController.text) ?? 0;
                  final int weight = int.tryParse(weightController.text) ?? 0;

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

                final int oldXp = entry.xp;
                workoutData.characterXp[entry.characterClass] =
                    (workoutData.characterXp[entry.characterClass] ?? 0) -
                    oldXp +
                    newXp;
                if (workoutData.characterXp[entry.characterClass]! < 0) {
                  workoutData.characterXp[entry.characterClass] = 0;
                }

                final updatedEntry = WorkoutEntry(
                  characterClass: entry.characterClass,
                  type: entry.type,
                  description: newDescription,
                  xp: newXp,
                  timestamp: DateTime.now(),
                );

                setState(() {
                  final oldEntry = workoutData.entries[index];
                  workoutData.updateWorkout(oldEntry, updatedEntry);
                });
                Navigator.pop(context);
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
          .where((entry) => entry.characterClass == _selectedClassFilter)
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
                  child: DropdownButton<CharacterClass>(
                    value: _selectedClassFilter,
                    isExpanded: true,
                    hint: const Text('Filter by Visionary'),
                    onChanged: (newClass) {
                      setState(() => _selectedClassFilter = newClass);
                    },
                    items: CharacterClass.values.map((c) {
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
                                setState(() {
                                  final xp = entry.xp;
                                  final classKey = entry.characterClass;
                                  workoutData.characterXp[classKey] =
                                      (workoutData.characterXp[classKey] ?? 0) -
                                      xp;
                                  if (workoutData.characterXp[classKey]! < 0) {
                                    workoutData.characterXp[classKey] = 0;
                                  }
                                  final entryToDelete =
                                      workoutData.entries[actualIndex];
                                  workoutData.deleteWorkout(entryToDelete);
                                });
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
