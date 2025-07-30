import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';

class StoryMapGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    final map = await TiledComponent.load('intro_scene.tmx', Vector2(64, 32));
    add(map); // this adds the map to the game
  }
}