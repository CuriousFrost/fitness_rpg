// lib/models/visionary_class.dart
enum VisionaryClass {
  bloodletter,
  airsnatcher,
  saboteur,
  lightTheologist,
  victimizer,
  symbolist,
  cosmologist,
  mossborn,
  farseer,
  realist; // Semicolon is essential here to separate enum values from members.

  // Ensure there are no stray characters or comments that look like code
  // between the semicolon above and this static method.

  static VisionaryClass fromString(String? className) { // Made className nullable for safety
    if (className == null || className.trim().isEmpty) {
      print(
          "Warning: Received null or empty className. Defaulting to ${VisionaryClass.values.first.name}.");
      return VisionaryClass.values.first;
    }
    try {
      return VisionaryClass.values.firstWhere(
            (e) => e.name.toLowerCase() == className.toLowerCase().trim(),
      );
    } catch (e) {
      print(
          "Warning: Could not find VisionaryClass for name: '$className'. Defaulting to ${VisionaryClass.values.first.name}.");
      return VisionaryClass.values.first;
    }
  }
}
extension CharacterClassName on VisionaryClass {
  String get displayName {
    switch (this) {
      case VisionaryClass.bloodletter:
        return 'Bloodletter';
      case VisionaryClass.airsnatcher:
        return 'Airsnatcher';
      case VisionaryClass.saboteur:
        return 'Saboteur';
      case VisionaryClass.lightTheologist:
        return 'Light Theologist';
      case VisionaryClass.victimizer:
        return 'Victimizer';
      case VisionaryClass.symbolist:
        return 'Symbolist';
      case VisionaryClass.cosmologist:
        return 'Cosmologist';
      case VisionaryClass.mossborn:
        return 'Mossborn';
      case VisionaryClass.farseer:
        return 'Farseer';
      case VisionaryClass.realist:
        return 'Realist';
    }
  }
}
