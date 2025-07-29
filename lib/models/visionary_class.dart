// lib/models/visionary_class.dart
import 'package:flutter/material.dart';

enum VisionaryClass {
  // VisionaryClass.bloodletter corresponds to the Class Type "Blade Artist" via displayName
  bloodletter(
    classColor:
        Colors.deepOrangeAccent, // Example: Darker red (Colors.red[900])
    classTextColor: Colors.white,
  ),
  airsnatcher(
    classColor: Colors.blue, // Example: Darker blue (Colors.lightBlue[800])
    classTextColor: Colors.white,
  ),
  saboteur(classColor: Colors.greenAccent, classTextColor: Colors.white),
  lightTheologist(classColor: Colors.pink, classTextColor: Colors.black),
  victimizer(classColor: Colors.purple, classTextColor: Colors.white),
  symbolist(classColor: Colors.pink, classTextColor: Colors.black),
  cosmologist(classColor: Colors.blue, classTextColor: Colors.white),
  mossborn(classColor: Colors.teal, classTextColor: Colors.white),
  farseer(classColor: Colors.greenAccent, classTextColor: Colors.white),
  realist(
    classColor: Colors.purple,
    classTextColor: Colors.white,
  ); // Semicolon is essential here

  // Constructor to assign the colors
  const VisionaryClass({
    required this.classColor,
    required this.classTextColor,
  });

  // Fields to hold the colors
  final Color classColor;
  final Color classTextColor;

  // Ensure there are no stray characters or comments that look like code
  // between the semicolon above and this static method.

  static VisionaryClass fromString(String? className) {
    // Made className nullable for safety
    if (className == null || className.trim().isEmpty) {
      return VisionaryClass.values.first;
    }
    try {
      return VisionaryClass.values.firstWhere(
        (e) => e.name.toLowerCase() == className.toLowerCase().trim(),
      );
    } catch (e) {
      return VisionaryClass.values.first;
    }
  }
}

extension CharacterClassName on VisionaryClass {
  String get displayName {
    switch (this) {
      case VisionaryClass.bloodletter:
        return 'Blade Artist';
      case VisionaryClass.airsnatcher:
        return 'Elementalist';
      case VisionaryClass.saboteur:
        return 'Gunsmith';
      case VisionaryClass.lightTheologist:
        return 'Materialist';
      case VisionaryClass.victimizer:
        return 'Traditionalist';
      case VisionaryClass.symbolist:
        return 'Materialist';
      case VisionaryClass.cosmologist:
        return 'Elementalist';
      case VisionaryClass.mossborn:
        return 'Ranger';
      case VisionaryClass.farseer:
        return 'Gunsmith';
      case VisionaryClass.realist:
        return 'Traditionalist';
    }
  }
}
