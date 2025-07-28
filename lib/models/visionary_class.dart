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
