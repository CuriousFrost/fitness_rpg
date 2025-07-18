import 'package:flutter/material.dart';
import '../models/character_class.dart';
import '../models/workout_entry.dart';
import '../widgets/workout_input_dialog.dart';
import '../main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  CharacterClass? selectedClass;

  @override
  void initState() {
    super.initState();
    final stored = PageStorage.of(context).readState(context, identifier: 'selectedClass') as String?;
    if (stored != null) {
      selectedClass = CharacterClass.values.firstWhere((c) => c.name == stored, orElse: () => CharacterClass.values.first);
    }
  }

  void _onClassChanged(CharacterClass? newValue) {
    setState(() {
      selectedClass = newValue;
      PageStorage.of(context).writeState(context, newValue?.name, identifier: 'selectedClass');
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<CharacterClass> classNames = CharacterClass.values;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<CharacterClass>(
              key: const PageStorageKey<String>('classDropdown'),
              value: selectedClass,
              hint: const Text('Select a class'),
              isExpanded: true,
              onChanged: _onClassChanged,
              items: classNames.map((c) {
                return DropdownMenuItem<CharacterClass>(
                  value: c,
                  child: Text(c.displayName),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: selectedClass == null
                  ? null
                  : () {
                showDialog(
                  context: context,
                  builder: (context) => WorkoutInputDialog(
                      onWorkoutLogged: (workoutType, description, xp) {
                        if (selectedClass == null) return;

                        final entry = WorkoutEntry(
                          characterClass: selectedClass!,
                          type: workoutType,
                          xp: xp,
                          description: description,
                          timestamp: DateTime.now(),
                        );

                        workoutData.entries.add(entry);
                        workoutData.characterXp[selectedClass!] =
                            (workoutData.characterXp[selectedClass!] ?? 0) + xp;
                        workoutData.save();

                        setState(() {});
                      },
                  ),
                );
              },
              child: const Text('Log Workout'),
            ),
          ],
        ),
      ),
    );
  }
}
