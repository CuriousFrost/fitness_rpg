// xp_progress_bar.dart (Modified)
import 'package:flutter/material.dart';
import '../models/visionary_data.dart';

// No longer need 'dart:math' here if formulas are external
class XPProgressBar extends StatelessWidget {
  final int currentLevel;
  final int xpIntoCurrentLevel;
  final int xpNeededForNextLevel;

  const XPProgressBar({
    super.key,
    required this.currentLevel,
    required this.xpIntoCurrentLevel,
    required this.xpNeededForNextLevel,
  });

  @override
  Widget build(BuildContext context) {
    final int safeXpIntoLevel = xpIntoCurrentLevel.clamp(
      0,
      xpNeededForNextLevel,
    );
    final double progress = (xpNeededForNextLevel > 0)
        ? (safeXpIntoLevel / xpNeededForNextLevel).clamp(0.0, 1.0)
        : (currentLevel >= VisionaryData.maxLevel
              ? 1.0
              : 0.0); // Show full if max level

    final String xpText =
        (xpNeededForNextLevel > 0 && currentLevel < VisionaryData.maxLevel)
        ? '$safeXpIntoLevel / $xpNeededForNextLevel XP'
        : (currentLevel >= VisionaryData.maxLevel
              ? "Max Level"
              : "$safeXpIntoLevel / $xpNeededForNextLevel XP");

    return Column(
      // ... same layout as before using these parameters ...
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
          'Level $currentLevel • $xpText',
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }
}
