// ui_helpers.dart (Revised)
import 'package:flutter/material.dart';
import '../widgets/xp_progress_bar.dart'; // Ensure this path is correct
import 'dart:ui'; // For lerpDouble
import '../models/visionary_class.dart';
import '../models/visionary_data.dart'; // <--- IMPORT VisionaryData

void showXpGainPopupWithBar(
    BuildContext context,
    VisionaryClass visionary, // We might not directly need visionary object if we pass all data
    int oldXpIntoCurrentLevel,
    int newXpIntoCurrentLevel,
    int currentLevel, // The level *after* the XP gain, if a level up occurred during the gain being animated
    int xpNeededForThisLevel, // XP needed for the currentLevel (could be from start or for next, clarify use)
    // Let's assume this is xpNeededForNextLevel for the currentLevel
    int gainedTotalXpAmount, // The actual amount of XP the user earned in this transaction
    ) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => _XpPopupOverlay(
      // visionary: visionary, // visionary object might not be needed by popup if all display data is passed
        oldXpDisplay: oldXpIntoCurrentLevel,
        newXpDisplay: newXpIntoCurrentLevel,
        currentLevelDisplay: currentLevel,
        xpNeededForNextLevelDisplay: xpNeededForThisLevel, // Or rename to xpNeededForCurrentLevelProgress
        gainedAmount: gainedTotalXpAmount,
        onComplete: () {
          if (overlayEntry.mounted) {
            overlayEntry.remove();
          }
        }
    ),
  );

  overlay.insert(overlayEntry);
}

class _XpPopupOverlay extends StatefulWidget {
  // final VisionaryClass visionary; // Potentially remove if not used
  final int oldXpDisplay; // XP value to start animation from (for current level)
  final int newXpDisplay; // XP value to end animation at (for current level)
  final int currentLevelDisplay;
  final int xpNeededForNextLevelDisplay;
  final int gainedAmount; // The 'You gained X XP!' amount
  final VoidCallback onComplete;

  const _XpPopupOverlay({
    // required this.visionary,
    required this.oldXpDisplay,
    required this.newXpDisplay,
    required this.currentLevelDisplay,
    required this.xpNeededForNextLevelDisplay,
    required this.gainedAmount,
    required this.onComplete,
  });

  @override
  State<_XpPopupOverlay> createState() => _XpPopupOverlayState();
}

class _XpPopupOverlayState extends State<_XpPopupOverlay>
    with TickerProviderStateMixin {
  late AnimationController _xpTextController;
  late AnimationController _xpBarController;
  bool showBar = false;

  @override
  void initState() {
    super.initState();
    _xpTextController =
    AnimationController(vsync: this, duration: const Duration(milliseconds: 1500)) // Shorter duration for text
      ..forward().whenComplete(() {
        if (mounted) {
          setState(() => showBar = true);
          _xpBarController.forward();
        }
      });

    _xpBarController =
    AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              widget.onComplete();
            }
          });
        }
      });
  }

  @override
  void dispose() {
    _xpTextController.dispose();
    _xpBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 80,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: showBar
              ? Container(
            key: const ValueKey('xpBarContainer'), // Key for AnimatedSwitcher
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black87.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                const BoxShadow(
                  color: Colors.black38,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _xpBarController,
              builder: (context, child) {
                // Animate the xpIntoCurrentLevel value
                final animatedXpIntoLevel = lerpDouble(
                  widget.oldXpDisplay.toDouble(),
                  widget.newXpDisplay.toDouble(),
                  _xpBarController.value,
                )!
                    .toInt();

                return XPProgressBar(
                  currentLevel: widget.currentLevelDisplay,
                  xpIntoCurrentLevel: animatedXpIntoLevel,
                  xpNeededForNextLevel: widget.xpNeededForNextLevelDisplay,
                );
              },
            ),
          )
              : Container(
            key: const ValueKey('xpTextContainer'), // Key for AnimatedSwitcher
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[700],
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                const BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: FadeTransition( // Apply FadeTransition here if not handled by AnimatedSwitcher properly
                opacity: _xpTextController, // Use _xpTextController for the text fade
                child: Text(
                  'You gained ${widget.gainedAmount} XP!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}