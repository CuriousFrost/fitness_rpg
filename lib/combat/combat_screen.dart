// lib/combat/combat_screen.dart
import 'package:flutter/material.dart';
import '../models/character_data.dart';
import 'combat_unit.dart';

class CombatScreen extends StatefulWidget {
  final List<CharacterClass> team;

  const CombatScreen({super.key, required this.team});

  @override
  State<CombatScreen> createState() => _CombatScreenState();
}

class _CombatScreenState extends State<CombatScreen> {
  late List<CombatUnit> playerUnits;
  late List<CombatUnit> enemyUnits;

  @override
  void initState() {
    super.initState();
    _initializeUnits();
  }

  void _initializeUnits() {
    playerUnits = widget.team.map((c) => CombatUnit.fromClass(c, isPlayer: true)).toList();
    enemyUnits = List.generate(3, (i) => CombatUnit.enemy('Enemy $i', hp: 30 + i * 10));
  }

  Widget _buildGrid() {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1,
      ),
      itemCount: 16,
      itemBuilder: (context, index) {
        final unit = [...playerUnits, ...enemyUnits]
            .firstWhere((u) => u.position == index, orElse: () => CombatUnit.empty());
        return Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: unit.isEmpty ? Colors.grey[300] : (unit.isPlayer ? Colors.teal[200] : Colors.red[200]),
            border: Border.all(color: Colors.black12),
          ),
          child: Center(
            child: unit.isEmpty
                ? const SizedBox.shrink()
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(unit.name, style: const TextStyle(fontSize: 10)),
                Text('HP: ${unit.hp}', style: const TextStyle(fontSize: 10)),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Combat Test')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const Text('Isometric Grid (Placeholder)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildGrid(),
          ],
        ),
      ),
    );
  }
}