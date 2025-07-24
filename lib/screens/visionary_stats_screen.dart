// Converted version of your existing VisionaryStatsScreen to a StatefulWidget
// Includes your original logic with automatic refresh via setState if needed

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

class VisionaryStatsScreen extends StatefulWidget {
  final CharacterClass characterClass;

  const VisionaryStatsScreen({super.key, required this.characterClass});

  @override
  State<VisionaryStatsScreen> createState() => _VisionaryStatsScreenState();
}

class _VisionaryStatsScreenState extends State<VisionaryStatsScreen> {
  late List<WorkoutEntry> entries;
  late Map<WorkoutType, int> xpByType;
  late Map<WorkoutType, double> distanceByType;
  late List<FlSpot> xpSpots;
  late String dateRange;

  @override
  void initState() {
    super.initState();
    _calculateStats();
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1)).copyWith(hour: 5);
    final weekEnd = weekStart.add(const Duration(days: 6));

    String formatDate(DateTime date) {
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[date.month - 1]} ${date.day}';
    }

    dateRange = weekStart.month == weekEnd.month
        ? '${formatDate(weekStart)} - ${weekEnd.day}'
        : '${formatDate(weekStart)} - ${formatDate(weekEnd)}';

    _calculateStats();

  }

  void _calculateStats() {
    final now = DateTime.now();
    final weekStart = now
        .subtract(Duration(days: now.weekday - 1))
        .copyWith(hour: 5);

    entries = workoutData.entries
        .where((e) => e.characterClass == widget.characterClass)
        .toList();

    xpByType = {};
    distanceByType = {
      WorkoutType.running: 0,
      WorkoutType.walking: 0,
      WorkoutType.biking: 0,
      WorkoutType.stairs: 0,
    };

    final xpPerDay = {
      'Mon': 0,
      'Tue': 0,
      'Wed': 0,
      'Thu': 0,
      'Fri': 0,
      'Sat': 0,
      'Sun': 0,
    };

    for (var e in entries) {
      xpByType[e.type] = (xpByType[e.type] ?? 0) + e.xp;

      if (distanceByType.containsKey(e.type)) {
        distanceByType[e.type] =
            (distanceByType[e.type] ?? 0) + (e.distance ?? 0);
      }

      if (e.timestamp.isAfter(weekStart)) {
        final weekday = [
          'Mon',
          'Tue',
          'Wed',
          'Thu',
          'Fri',
          'Sat',
          'Sun',
        ][e.timestamp.weekday - 1];
        xpPerDay[weekday] = (xpPerDay[weekday] ?? 0) + e.xp;
      }
    }

    xpSpots = xpPerDay.entries
        .toList()
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.value.toDouble()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.characterClass.displayName} Stats')),
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
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
                String label = entry.key == WorkoutType.stairs
                    ? '${entry.value.toInt()} steps'
                    : '${entry.value.toStringAsFixed(1)} km';
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text(
              '7-Day XP Overview ($dateRange)',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    minX: 0,
                    maxX: 6,
                    minY: 0,
                    maxY: 700,
                    lineBarsData: [
                      LineChartBarData(
                        spots: xpSpots,
                        isCurved: true,
                        color: Colors.white,
                        barWidth: 3,
                        dotData: FlDotData(show: true),
                      ),
                    ],
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            const days = [
                              'Mon',
                              'Tue',
                              'Wed',
                              'Thu',
                              'Fri',
                              'Sat',
                              'Sun',
                            ];
                            if (value >= 0 && value < days.length) {
                              return Text(
                                days[value.toInt()],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 100,
                          getTitlesWidget: (value, meta) {
                            if (value % 100 == 0 && value <= 700) {
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(color: Colors.white, fontSize: 10),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
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
