import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:em_touch/presentation/components/panel_component.dart';
import 'package:em_touch/presentation/games/rec_emotion_game.dart';
import 'package:em_touch/data/constants/globals.dart';
import 'dart:math' as math;

class StarComponent extends SpriteComponent with HasGameRef<RecEmotionGame> {
  /// Height of the sprite.
  final double _spriteHeight = Globals.isTablet ? 160.0 : 40.0;

  /// Speed and direction of gift.
  late Vector2 _velocity;

  /// Speed of the gift.
  double speed = Globals.isTablet ? 600 : 300;

  /// Angle or the gift on bounce back.
  final double degree = math.pi / 180;

  bool stop = false;

  StarComponent();

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    sprite = await gameRef.loadSprite(Globals.star);
    gameRef.score++;

    position = gameRef.descendants().whereType<PanelComponent>().first.position;

    final double spawnAngle = _getSpawnAngle();

    final double vx = math.cos(spawnAngle * degree) * speed;
    final double vy = math.sin(spawnAngle * degree) * speed;

    _velocity = Vector2(vx, vy);

    // Set dimensions of santa sprite.
    width = _spriteHeight;
    height = _spriteHeight;

    // Set anchor of component.
    anchor = Anchor.center;

    add(CircleHitbox()..radius = 1);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!stop) position += _velocity * dt;
    if (position.y < 0) {
      position = Vector2(gameRef.score * 45, 70);
      stop = true;
    }
  }

  double _getSpawnAngle() {
    return 270;
  }
}
