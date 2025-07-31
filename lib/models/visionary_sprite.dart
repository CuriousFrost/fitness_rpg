// visionary_sprite.dart
import 'package:flame/components.dart';
import 'package:flame/flame.dart';


class VisionarySprite extends SpriteComponent {
  VisionarySprite({required Vector2 position})
      : super(position: position, size: Vector2(64, 64));

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('assets/game/player/airsnatcher_sprite_sheet.png');
  }
}