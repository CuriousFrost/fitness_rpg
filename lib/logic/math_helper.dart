// logic/math_helper.dart

import '../models/workout_entry.dart';

class MathHelper {
  static int calculateXp(WorkoutType type, double primary, [int secondary = 1]) {
    switch (type) {
      case WorkoutType.running:
        return (primary * 10).ceil();
      case WorkoutType.walking:
        return (primary * 5).ceil();
      case WorkoutType.weightArm:
        return (primary * 0.4 * secondary).ceil();
      case WorkoutType.weightLeg:
        return (primary * 0.2 * secondary).ceil();
      case WorkoutType.weightChest:
        return (primary * 0.3 * secondary).ceil();
      case WorkoutType.weightBack:
        return (primary * 0.4 * secondary).ceil();
      case WorkoutType.biking:
        return (primary * 4).ceil();
      case WorkoutType.stairs:
        return (primary * 2).ceil();
    }
  }

  static String buildDescription(WorkoutType type, double primary, [int secondary = 1]) {
    switch (type) {
      case WorkoutType.running:
        return 'Ran ${primary.toStringAsFixed(1)} km';
      case WorkoutType.walking:
        return 'Walked ${primary.toStringAsFixed(1)} km';
      case WorkoutType.weightArm:
        return 'Lifted ${primary.toInt()} lbs x $secondary (Arms)';
      case WorkoutType.weightLeg:
        return 'Lifted ${primary.toInt()} lbs x $secondary (Legs)';
      case WorkoutType.weightChest:
        return 'Lifted ${primary.toInt()} lbs x $secondary (Chest)';
      case WorkoutType.weightBack:
        return 'Lifted ${primary.toInt()} lbs x $secondary (Back)';
      case WorkoutType.biking:
        return 'Biked ${primary.toStringAsFixed(1)} km';
      case WorkoutType.stairs:
        return 'Climbed ${primary.toInt()} steps';
    }
  }
}
