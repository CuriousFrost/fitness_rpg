import 'package:flutter/material.dart';
import '../widgets/xp_progress_bar.dart';
import 'dart:ui';
import '../models/visionary_class.dart';

void showXpGainPopupWithBar(
  BuildContext context,
  VisionaryClass characterClass,
  int oldXp,
  int newXp,
) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => _XpPopupOverlay(
      characterClass: characterClass,
      oldXp: oldXp,
      newXp: newXp,
      onComplete: () => overlayEntry.remove(),
    ),
  );

  overlay.insert(overlayEntry);
}

class _XpPopupOverlay extends StatefulWidget {
  final VisionaryClass characterClass;
  final int oldXp;
  final int newXp;
  final VoidCallback onComplete;

  const _XpPopupOverlay({
    required this.characterClass,
    required this.oldXp,
    required this.newXp,
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
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..forward().whenComplete(() {
            setState(() => showBar = true);
            _xpBarController.forward();
          });

    _xpBarController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              Future.delayed(const Duration(seconds: 1), widget.onComplete);
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
          child: showBar
              ? AnimatedBuilder(
                  animation: _xpBarController,
                  builder: (context, child) {
                    final animatedXp = lerpDouble(
                      widget.oldXp,
                      widget.newXp,
                      _xpBarController.value,
                    )!.toInt();
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: XPProgressBar(xp: animatedXp),
                    );
                  },
                )
              : FadeTransition(
                  opacity: _xpTextController,
                  child: Container(
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
                      child: Text(
                        'You gained ${widget.newXp - widget.oldXp} XP!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
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
