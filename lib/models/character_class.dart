
enum CharacterClass {
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

extension CharacterClassName on CharacterClass {
  String get displayName {
    switch (this) {
      case CharacterClass.bloodletter:
        return 'Bloodletter';
      case CharacterClass.airsnatcher:
        return 'Airsnatcher';
      case CharacterClass.saboteur:
        return 'Saboteur';
      case CharacterClass.lightTheologist:
        return 'Light Theologist';
      case CharacterClass.victimizer:
        return 'Victimizer';
      case CharacterClass.symbolist:
        return 'Symbolist';
      case CharacterClass.cosmologist:
        return 'Cosmologist';
      case CharacterClass.mossborn:
        return 'Mossborn';
      case CharacterClass.farseer:
        return 'Farseer';
      case CharacterClass.realist:
        return 'Realist';
    }
  }
}