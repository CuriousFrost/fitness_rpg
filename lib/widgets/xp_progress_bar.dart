import 'package:flutter/material.dart';
import 'dart:math';

class XPProgressBar extends StatelessWidget {
  final int xp;
  const XPProgressBar({super.key, required this.xp});

  int xpForLevel(int level) => level == 1 ? 0 : (80 * pow(level, 1.3)).floor();

  int getLevelFromXp(int xp) {
    int level = 1;
    while (level < 150 && xp >= xpForLevel(level + 1)) {
      level++;
    }
    return level;
  }

  @override
  Widget build(BuildContext context) {
    final int level = getLevelFromXp(xp);
    final int currentLevelXp = xpForLevel(level);
    final int nextLevelXp = xpForLevel(level + 1);
    final int xpForNext = nextLevelXp - currentLevelXp;

    final int rawXpIntoLevel = xp - currentLevelXp;
    final int xpIntoLevel = rawXpIntoLevel.clamp(0, xpForNext);
    final double progress = (xpIntoLevel / xpForNext).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 12,
            backgroundColor: Colors.grey[800],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.tealAccent),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Level $level • $xpIntoLevel / $xpForNext XP',
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }
}
