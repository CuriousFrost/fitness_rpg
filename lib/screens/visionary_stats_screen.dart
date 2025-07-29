// Converted version of your existing VisionaryStatsScreen to a StatefulWidget
// Includes your original logic with automatic refresh via setState if needed

import 'package:fitness_rpg/logic/visionary_data.dart';
import 'package:flutter/material.dart';
import '../models/workout_entry.dart';
import 'package:fl_chart/fl_chart.dart';
import '../logic/workout_data.dart';
import '../models/visionary_class.dart';

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
  final VisionaryData visionary;

  const VisionaryStatsScreen({super.key, required this.visionary});

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
    _calculateStatsAndUpdateUI();
    workoutData.addListener(_onWorkoutDataChanged);
    final now = DateTime.now();
    final weekStart = now
        .subtract(Duration(days: now.weekday - 1))
        .copyWith(hour: 5);
    final weekEnd = weekStart.add(const Duration(days: 6));

    String formatDate(DateTime date) {
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[date.month - 1]} ${date.day}';
    }

    dateRange = weekStart.month == weekEnd.month
        ? '${formatDate(weekStart)} - ${weekEnd.day}'
        : '${formatDate(weekStart)} - ${formatDate(weekEnd)}';

    _calculateStatsAndUpdateUI();
  }

  @override
  void dispose() {
    // ALWAYS remove listeners in dispose
    workoutData.removeListener(_onWorkoutDataChanged);
    super.dispose();
  }

  void _onWorkoutDataChanged() {
    // When workoutData notifies of a change, recalculate and rebuild
    _calculateStatsAndUpdateUI();
  }

  // New method to combine calculation and UI update
  void _calculateStatsAndUpdateUI() {
    _calculateStats(); // Your existing calculation logic
    if (mounted) {
      // Ensure the widget is still in the tree
      setState(() {}); // Trigger a rebuild
    }
  }

  void _calculateStats() {
    final now = DateTime.now();
    // Ensure weekStart is midnight at the beginning of Monday
    final weekStart = now
        .subtract(Duration(days: now.weekday - 1))
        .copyWith(
          hour: 0,
          minute: 0,
          second: 0,
          millisecond: 0,
          microsecond: 0,
        );

    final VisionaryClass visionaryEnumForScreen = VisionaryClass.fromString(
      widget.visionary.classType,
    );

    entries = workoutData.entries
        .where((e) => e.visionary == visionaryEnumForScreen)
        .toList();

    xpByType = {};
    // Initialize distanceByType for all relevant types, not just cardio if you want to display them
    distanceByType = {for (var type in WorkoutType.values) type: 0.0};

    // Initialize xpPerDay for the 7 days of the week, ensuring order
    final List<String> weekDays = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];
    final Map<String, int> xpPerDay = {for (var day in weekDays) day: 0};

    for (var e in entries) {
      xpByType[e.type] = (xpByType[e.type] ?? 0) + e.xp;

      // Make sure distance is only added for types that have distance
      if (e.distance != null &&
          (e.type == WorkoutType.running ||
              e.type == WorkoutType.walking ||
              e.type == WorkoutType.biking ||
              e.type == WorkoutType.stairs)) {
        distanceByType[e.type] = (distanceByType[e.type] ?? 0.0) + e.distance!;
      }

      // Check if the entry's timestamp is within the current week
      if (!e.timestamp.isBefore(weekStart) &&
          e.timestamp.isBefore(weekStart.add(const Duration(days: 7)))) {
        final dayString =
            weekDays[e.timestamp.weekday - 1]; // Monday is 1 -> index 0
        xpPerDay[dayString] = (xpPerDay[dayString] ?? 0) + e.xp;
      }
    }

    // Create FlSpots in the correct Monday-Sunday order
    xpSpots = [];
    for (int i = 0; i < weekDays.length; i++) {
      xpSpots.add(
        FlSpot(i.toDouble(), (xpPerDay[weekDays[i]] ?? 0).toDouble()),
      );
    }
    // Update dateRange string here as well if it might change,
    // though for "current week" it's fine in initState.
    // final weekEnd = weekStart.add(const Duration(days: 6));
    // dateRange = ... (your formatDate logic)
  }

  @override
  Widget build(BuildContext context) {
    const List<WorkoutType> distanceWorkoutTypes = [
      WorkoutType.running,
      WorkoutType.walking,
      WorkoutType.biking,
      WorkoutType.stairs,
    ];
    final List<MapEntry<WorkoutType, double>> filteredDistanceEntries =
        distanceByType.entries.where((entry) {
          return distanceWorkoutTypes.contains(entry.key) && entry.value > 0;
        }).toList();
    return Scaffold(
      appBar: AppBar(title: Text('${widget.visionary.displayName} Stats')),
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
            if (filteredDistanceEntries.isNotEmpty) ...[
              // Only show if there are entries
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
                // Use the filtered list here
                children: filteredDistanceEntries.map((entry) {
                  // <--- MAKE SURE THIS USES filteredDistanceEntries
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
              const SizedBox(
                height: 24,
              ), // This SizedBox is part of the conditional section
            ],
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
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
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
