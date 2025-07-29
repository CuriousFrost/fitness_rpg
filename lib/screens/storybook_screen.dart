// lib/screens/storybook_screen.dart
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../game/visionaries_of_sol_game.dart';

class StorybookScreen extends StatelessWidget {
  const StorybookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // You might have an AppBar or other Flutter UI elements here
      // if you want them to overlay or be part of the game screen.
      // appBar: AppBar(title: const Text("Game Active")),
      body: GameWidget(
        game: MyFitnessRpgGame(), // Create an instance of your game
        // You can add loadingBuilder, errorBuilder, backgroundBuilder
        // for more control over the GameWidget's appearance during these states.
      ),
    );
  }
}