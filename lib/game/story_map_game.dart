import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'dart:developer' as developer; // For logging

class StoryMapGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    Flame.images.prefix = ''; // Keep this!
    try {
      developer.log("Attempting TiledComponent.load with prefix: 'assets/maps/' and file: 'intro_scene.tmx'");
      final map = await TiledComponent.load(
        'intro_scene.tmx',
        Vector2(64, 32),
        prefix: 'assets/maps/', // This helps find intro_scene.tmx and test_tiles.tsx
      );
      add(map);
      developer.log("SUCCESS with TiledComponent.load and prefix.");
    } catch (e) {
      developer.log("ERROR with TiledComponent.load and prefix: $e");
      rethrow; // Rethrow to see the error if it still occurs
    }
  }
}