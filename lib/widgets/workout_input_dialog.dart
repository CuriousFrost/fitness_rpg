// Updated to support RPG classes, workouts, XP tracking, and new bottom menu system

import 'package:flutter/material.dart';
import 'package:fitness_rpg/models/workout_entry.dart';
import '../logic/math_helper.dart';
import '../main.dart';

// ========== Main Menu Navigation ==========
@override
Widget build(BuildContext context) {
  return Center(child: Text('Workout Screen (Coming Soon)'));
}

Future<void> showEditWorkoutDialog(
    BuildContext context,
    WorkoutEntry entry,
    VoidCallback onSave,
    ) async {
  final descController = TextEditingController(text: entry.description);
  final xpController = TextEditingController(text: entry.xp.toString());
  final distanceController = TextEditingController(text: entry.distance.toString());

  await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Edit Workout'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: descController,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: xpController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'XP Earned'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final newDesc = descController.text.trim();
            final newXp = int.tryParse(xpController.text) ?? entry.xp;
            final newDistance = double.tryParse(distanceController.text);

            entry.description = newDesc.isNotEmpty
                ? newDesc
                : entry.description;
            entry.xp = newXp;
            if (newDistance != null) {
              entry.distance = newDistance;
            }

            workoutData.save();
            onSave();
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

class WorkoutInputDialog extends StatefulWidget {
  final void Function(WorkoutType, String, int, {double? distance}) onWorkoutLogged;
  final WorkoutEntry? entry;
  const WorkoutInputDialog({super.key, required this.onWorkoutLogged, this.entry});

  @override
  State<WorkoutInputDialog> createState() => _WorkoutInputDialogState();
}

class _WorkoutInputDialogState extends State<WorkoutInputDialog> {
  WorkoutType? selectedWorkout;
  final TextEditingController primaryInput = TextEditingController();
  final TextEditingController secondaryInput = TextEditingController();
  final TextEditingController distanceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedWorkout = widget.entry?.type;
    primaryInput.text = widget.entry?.xp.toString() ?? '';
    secondaryInput.text = widget.entry?.characterClass.toString() ?? '';
    distanceController.text = widget.entry?.distance?.toString() ?? '';
  }

  @override
  void dispose() {
    primaryInput.dispose();
    secondaryInput.dispose();
    distanceController.dispose();
    super.dispose();
  }

  List<Widget> inputFields() {
    if (selectedWorkout == null) return [];

    switch (selectedWorkout!) {
      case WorkoutType.running:
      case WorkoutType.walking:
      case WorkoutType.biking:
        return [
          TextField(
            controller: primaryInput,
            decoration: const InputDecoration(labelText: 'Distance (km)'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ];
      case WorkoutType.stairs:
        return [
          TextField(
            controller: primaryInput,
            decoration: const InputDecoration(labelText: 'Steps'),
            keyboardType: TextInputType.number,
          ),
        ];
      default:
        return [
          TextField(
            controller: primaryInput,
            decoration: const InputDecoration(labelText: 'Weight (lbs)'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: secondaryInput,
            decoration: const InputDecoration(labelText: 'Reps'),
            keyboardType: TextInputType.number,
          ),
        ];
    }
  }

  void submit() {
    if (selectedWorkout == null) return;

    final double primary = double.tryParse(primaryInput.text) ?? 0;
    final int secondary = int.tryParse(secondaryInput.text) ?? 1;

    final int xp = MathHelper.calculateXp(selectedWorkout!, primary, secondary);
    final String desc = MathHelper.buildDescription(
      selectedWorkout!,
      primary,
      secondary,
    );

    double? distance;
    if (selectedWorkout == WorkoutType.running ||
        selectedWorkout == WorkoutType.walking ||
        selectedWorkout == WorkoutType.biking ||
        selectedWorkout == WorkoutType.stairs) {
      distance = primary;
    }

    widget.onWorkoutLogged(
      selectedWorkout!,
      desc,
      xp,
      distance: distance,
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Log Workout'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<WorkoutType>(
              isExpanded: true,
              hint: const Text('Select Workout Type'),
              value: selectedWorkout,
              onChanged: (type) => setState(() => selectedWorkout = type),
              items: WorkoutType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            ...inputFields(),
          ],
        ),
      ),
      actions: [TextButton(onPressed: submit, child: const Text('Add XP'))],
    );
  }
}
