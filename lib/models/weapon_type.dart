// lib/models/weapon_type.dart (or your preferred models file)
import 'package:flutter/material.dart';

enum WeaponType {
  sword(displayName: 'Sword', color: Colors.blueGrey, textColor: Colors.white),
  axe(
    displayName: 'Particle Matter',
    color: Colors.brown,
    textColor: Colors.white,
  ),
  staff(
    displayName: 'Pistols',
    color: Colors.purpleAccent,
    textColor: Colors.white,
  ),
  bow(displayName: 'Bow', color: Colors.green, textColor: Colors.white),
  dagger(
    displayName: 'Manifestations',
    color: Colors.grey,
    textColor: Colors.white,
  ),
  firearm(
    displayName: 'Close Combat',
    color: Colors.orange,
    textColor: Colors.black,
  ),
  unknown(
    // Fallback for any weapon types not explicitly defined
    displayName: 'Unknown',
    color: Colors.black54,
    textColor: Colors.white,
  );

  const WeaponType({
    required this.displayName,
    required this.color,
    required this.textColor,
  });

  final String displayName;
  final Color color;
  final Color textColor;

  // Helper to get enum from string (if your visionaryData.weaponType is a string)
  static WeaponType fromString(String? typeName) {
    if (typeName == null) return WeaponType.unknown;
    try {
      return WeaponType.values.firstWhere(
        (e) =>
            e.name.toLowerCase() == typeName.toLowerCase().trim() ||
            e.displayName.toLowerCase() == typeName.toLowerCase().trim(),
      );
    } catch (e) {
      return WeaponType.unknown;
    }
  }
}
