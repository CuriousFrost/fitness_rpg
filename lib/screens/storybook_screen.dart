import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../game/story_map_game.dart';

class StoryBookScreen extends StatelessWidget {
  const StoryBookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget<StoryMapGame>(
        game: StoryMapGame(),
        overlayBuilderMap: const {}, // you can remove or leave this empty for now
      ),
    );
  }
}