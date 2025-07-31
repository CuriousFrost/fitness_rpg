import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flame/components.dart';

class StoryMapGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    Flame.images.prefix = ''; // Keep this!
    final map = await TiledComponent.load('intro_scene.tmx', Vector2(64, 32),
      prefix: 'assets/maps/', // This helps find intro_scene.tmx
    );
    add(map);

    final spawnGroup = map.tileMap.getLayer<ObjectGroup>('Spawn Player 1');
    final spawnObj = spawnGroup?.objects.firstWhere((obj) =>
    obj.name == 'Spawn Player 1');

    if (spawnObj != null) {
      final player = SpriteComponent()
        ..sprite = await loadSprite(
            'images/game/player/airsnatcher_sprite_single.png') // Adjust sprite path
        ..position = Vector2(spawnObj.x, spawnObj.y)
        ..size = Vector2(64, 32);
      add(player);
    }
  }
}
