import 'package:flutter/material.dart';
import '../models/character_class.dart';
import '../models/workout_entry.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fitness_rpg/main.dart';

extension WorkoutTypeIcon on WorkoutType {
  IconData get icon {
    switch (this) {
      case WorkoutType.running:
        return Icons.directions_run;
      case WorkoutType.walking:
        return Icons.directions_walk;
      case WorkoutType.biking:
        return Icons.pedal_bike;
      case WorkoutType.stairs:
        return Icons.stairs;
      case WorkoutType.weightArm:
        return Icons.fitness_center;
      case WorkoutType.weightBack:
        return Icons.accessibility_new;
      case WorkoutType.weightChest:
        return Icons.sports_gymnastics;
      case WorkoutType.weightLeg:
        return Icons.directions_bike;
    }
  }
}

class VisionaryStatsScreen extends StatelessWidget {
  final CharacterClass characterClass;

  const VisionaryStatsScreen({super.key, required this.characterClass});

  @override
  Widget build(BuildContext context) {
    // Filter entries for the selected character
    final entries = workoutData.entries
        .where((e) => e.characterClass == characterClass)
        .toList();

    // XP by workout type
    final Map<WorkoutType, int> xpByType = {};
    for (var e in entries) {
      xpByType[e.type] = (xpByType[e.type] ?? 0) + e.xp;
    }

    // Distance tracker
    final Map<WorkoutType, double> distanceByType = {
      WorkoutType.running: 0,
      WorkoutType.walking: 0,
      WorkoutType.biking: 0,
      WorkoutType.stairs: 0,
    };
    for (var e in entries) {
      if (distanceByType.containsKey(e.type)) {
        distanceByType[e.type] = (distanceByType[e.type] ?? 0) + (e.distance ?? 0);
      }
    }

    // 7-day XP overview
    final Map<String, int> xpPerDay = {
      'Mon': 0,
      'Tue': 0,
      'Wed': 0,
      'Thu': 0,
      'Fri': 0,
      'Sat': 0,
      'Sun': 0,
    };
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1)).copyWith(hour: 5);
    for (var e in entries) {
      if (e.timestamp.isAfter(weekStart)) {
        final weekday = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][e.timestamp.weekday - 1];
        xpPerDay[weekday] = (xpPerDay[weekday] ?? 0) + e.xp;
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text('${characterClass.displayName} Stats')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'XP Gained by Workout Type',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: xpByType.entries.map((entry) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[800],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(entry.key.icon, color: Colors.white),
                      const SizedBox(height: 6),
                      Text(
                        '${entry.value} XP',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text(
              'Cardio Distance Tracker',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: distanceByType.entries.map((entry) {
                String label;
                if (entry.key == WorkoutType.stairs) {
                  label = '${entry.value.toInt()} steps';
                } else {
                  label = '${entry.value.toStringAsFixed(1)} km';
                }
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.teal[700],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(entry.key.icon, color: Colors.white),
                      const SizedBox(height: 6),
                      Text(
                        label,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text(
              '7-Day Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.indigo[700],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: LineChart(
                  LineChartData(
                    lineBarsData: [
                      LineChartBarData(
                        spots: xpPerDay.entries
                            .toList()
                            .asMap()
                            .entries
                            .map((e) => FlSpot(
                          e.key.toDouble(),
                          e.value.value.toDouble(),
                        ))
                            .toList(),
                        isCurved: true,
                        color: Colors.white,
                        barWidth: 3,
                        dotData: FlDotData(show: true),
                      )
                    ],
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                            return Text(days[value.toInt()], style: const TextStyle(color: Colors.white, fontSize: 10));
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                      ),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(show: true),
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
