import '../models/character_class.dart';

enum WorkoutType {
  running,
  walking,
  weightArm,
  weightLeg,
  weightChest,
  weightBack,
  biking,
  stairs,
}

extension WorkoutTypeDisplayName on WorkoutType {
  String get displayName {
    switch (this) {
      case WorkoutType.running:
        return 'Running';
      case WorkoutType.walking:
        return 'Walking';
      case WorkoutType.weightArm:
        return 'Weight Training (Arms)';
      case WorkoutType.weightLeg:
        return 'Weight Training (Legs)';
      case WorkoutType.weightChest:
        return 'Weight Training (Chest)';
      case WorkoutType.weightBack:
        return 'Weight Training (Back)';
      case WorkoutType.biking:
        return 'Biking';
      case WorkoutType.stairs:
        return 'Stairs';
    }
  }
}

extension WorkoutTypeName on WorkoutType {
  String generateDescription(double value, [int? reps]) {
    switch (this) {
      case WorkoutType.running:
        return 'Ran ${value.toStringAsFixed(1)} km';
      case WorkoutType.walking:
        return 'Walked ${value.toStringAsFixed(1)} km';
      case WorkoutType.biking:
        return 'Biked ${value.toStringAsFixed(1)} km';
      case WorkoutType.stairs:
        return 'Climbed ${value.toInt()} steps';
      case WorkoutType.weightArm:
        return 'Lifted ${value.toInt()} lbs x $reps (Arms)';
      case WorkoutType.weightLeg:
        return 'Lifted ${value.toInt()} lbs x $reps (Legs)';
      case WorkoutType.weightChest:
        return 'Lifted ${value.toInt()} lbs x $reps (Chest)';
      case WorkoutType.weightBack:
        return 'Lifted ${value.toInt()} lbs x $reps (Back)';
    }
  }
}

class WorkoutEntry {
  final CharacterClass characterClass;
  final WorkoutType type;
  String description;
  int xp;
  final DateTime timestamp;
  double? distance;

  WorkoutEntry({
    required this.characterClass,
    required this.type,
    required this.description,
    required this.xp,
    required this.timestamp,
    this.distance,
  });

  Map<String, dynamic> toJson() => {
    'characterClass': characterClass.name,
    'type': type.name,
    'description': description,
    'xp': xp,
    'timestamp': timestamp.toIso8601String(),
    'distance': distance,
  };

  factory WorkoutEntry.fromJson(Map<String, dynamic> json) => WorkoutEntry(
    characterClass: CharacterClass.values.firstWhere(
      (e) => e.name == json['characterClass'],
    ),
    type: WorkoutType.values.firstWhere((e) => e.name == json['type']),
    description: json['description'],
    xp: json['xp'],
    timestamp: DateTime.parse(json['timestamp']),
    distance: (json['distance'] as num?)?.toDouble(),
  );
}
