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
  realist,
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
