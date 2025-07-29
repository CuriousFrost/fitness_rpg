// ui_helpers.dart (Revised)
import 'package:flutter/material.dart';
import '../widgets/xp_progress_bar.dart'; // Ensure this path is correct
import 'dart:ui'; // For lerpDouble
import '../models/visionary_class.dart';
// import '../models/visionary_data.dart'; // No longer strictly needed here if all data is passed

void showXpGainPopupWithBar(
  BuildContext context,
  VisionaryClass
  visionary, // We might not directly need visionary object if we pass all data
  int oldXpIntoCurrentLevel,
  int newXpIntoCurrentLevel,
  int currentLevel, // The level *after* the XP gain
  int xpNeededForThisLevel, // XP needed for the currentLevel
  int gainedTotalXpAmount, { // The actual amount of XP the user earned
  // Add curly braces for named optional parameters
  int? levelBefore, // <<< --- ADD THIS (named optional parameter)
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => _XpPopupOverlay(
      // visionary: visionary, // visionary object might not be needed
      oldXpDisplay: oldXpIntoCurrentLevel,
      newXpDisplay: newXpIntoCurrentLevel,
      currentLevelDisplay: currentLevel,
      xpNeededForNextLevelDisplay: xpNeededForThisLevel,
      gainedAmount: gainedTotalXpAmount,
      levelBeforeDisplay: levelBefore, // <<< --- PASS IT TO THE WIDGET
      onComplete: () {
        if (overlayEntry.mounted) {
          overlayEntry.remove();
        }
      },
    ),
  );

  overlay.insert(overlayEntry);
}

class _XpPopupOverlay extends StatefulWidget {
  // final VisionaryClass visionary; // Potentially remove if not used
  final int oldXpDisplay;
  final int newXpDisplay;
  final int currentLevelDisplay;
  final int? levelBeforeDisplay; // <<< --- ADD FIELD HERE (nullable)
  final int xpNeededForNextLevelDisplay;
  final int gainedAmount;
  final VoidCallback onComplete;

  const _XpPopupOverlay({
    // required this.visionary,
    required this.oldXpDisplay,
    required this.newXpDisplay,
    required this.currentLevelDisplay,
    this.levelBeforeDisplay, // <<< --- ADD TO CONSTRUCTOR (optional)
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
  bool _didLevelUp = false; // <<< --- ADD A STATE VARIABLE FOR LEVEL UP

  @override
  void initState() {
    super.initState();

    // Determine if a level up occurred
    if (widget.levelBeforeDisplay != null &&
        widget.currentLevelDisplay > widget.levelBeforeDisplay!) {
      _didLevelUp = true;
    }

    _xpTextController =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 1500),
          )
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
                // Shortened delay a bit
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
                  key: const ValueKey('xpBarContainer'),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black87.withAlpha(199),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      const BoxShadow(
                        color: Colors
                            .black38, // This one is fine, it's already a Color constant
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  // <<< --- MODIFIED TO INCLUDE LEVEL UP TEXT AND XP BAR --- >>>
                  child: Column(
                    // Use a Column to stack Level Up text and XP Bar
                    mainAxisSize:
                        MainAxisSize.min, // Important for Column in Overlay
                    children: [
                      if (_didLevelUp) // Conditionally show Level Up text
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            'LEVEL UP!',
                            style: TextStyle(
                              color: Colors.amber[600],
                              fontSize: 20, // A bit larger for emphasis
                              fontWeight: FontWeight.bold,
                              shadows: const [
                                Shadow(
                                  blurRadius: 2.0,
                                  color: Colors.black54,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      AnimatedBuilder(
                        // Your existing XP Bar
                        animation: _xpBarController,
                        builder: (context, child) {
                          final animatedXpIntoLevel = lerpDouble(
                            widget.oldXpDisplay.toDouble(),
                            widget.newXpDisplay.toDouble(),
                            _xpBarController.value,
                          )!.toInt();

                          return XPProgressBar(
                            currentLevel: widget.currentLevelDisplay,
                            xpIntoCurrentLevel: animatedXpIntoLevel,
                            xpNeededForNextLevel:
                                widget.xpNeededForNextLevelDisplay,
                            // Optional: You could pass _didLevelUp to XPProgressBar
                            // if it needs to change appearance on level up.
                          );
                        },
                      ),
                    ],
                  ),
                )
              : Container(
                  // This is the "You gained X XP!" text part
                  key: const ValueKey('xpTextContainer'),
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
                    child: FadeTransition(
                      opacity: _xpTextController,
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
