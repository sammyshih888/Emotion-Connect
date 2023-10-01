import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:em_touch/presentation/components/panel_component.dart';
import 'package:em_touch/presentation/components/magnifier_component.dart';
import 'package:em_touch/presentation/games/rec_emotion_game.dart';
import 'package:em_touch/data/constants/globals.dart';
import 'dart:math' as math;

class FImgComponent extends SpriteComponent
    with HasGameRef<RecEmotionGame>, CollisionCallbacks {
  /// Height of the sprite.
  final double _spriteHeight = Globals.isTablet ? 200.0 : 100.0;

  /// Speed and direction of gift.
  late Vector2 _velocity;

  /// Speed of the gift.
  double speed = Globals.isTablet ? 300 : 100;

  /// Angle or the gift on bounce back.
  final double degree = math.pi / 180;

  /// Used for generating random position of gift.
  final math.Random _random = math.Random();

  bool createChild = false;

  String _tag = "";

  late Image _crossImg;
  late Image _checkImg;
  bool _hitWrong = false;
  bool _hitRight = false;
  double startY;

  FImgComponent({required this.startY});
  //FImgComponent();

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _createRandomQuiz();
    sprite = await gameRef.loadSprite("$_tag.png");

    position = _createRandomPosition(startY);
    final imagesCache = Flame.images;
    _crossImg = await imagesCache.load(Globals.cross);
    _checkImg = await imagesCache.load(Globals.check);

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
    position += _velocity * dt;

    final jsk = gameRef.descendants().whereType<JoystickComponent>().first;

    if (y >= jsk.y - 150) {
      if (!createChild) {
        gameRef.add(FImgComponent(startY: 0));
        createChild = true;
      }
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_hitRight) {
      canvas.drawImage(_checkImg, const Offset(60, 60), Paint());
    }
    if (_hitWrong) {
      canvas.drawImage(_crossImg, Offset.zero, Paint());
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (_hitRight || _hitWrong) {
      return;
    }

    PanelComponent p = gameRef.descendants().whereType<PanelComponent>().first;

    if (other is MagnifierComponent) {
      if (_tag.startsWith(gameRef.getTarget())) {
        FlameAudio.play(Globals.rightSound);
        _hitRight = true;
        p.addStar();
      } else {
        FlameAudio.play(Globals.wrongSound);
        _hitWrong = true;
        p.minusStar();
      }
    }
  }

  double _getSpawnAngle() {
    return 90;
  }

  Vector2 _createRandomPosition(double py) {
    final double x = _random.nextInt(gameRef.size.x.toInt() - 100).toDouble();
    return Vector2(x + 50, py);
  }

  void _createRandomQuiz() {
    if (_random.nextInt(3) == 0) {
      _tag = gameRef.getTarget();
    } else {
      switch (_random.nextInt(4)) {
        case 0:
          _tag = "A";
          break;
        case 1:
          _tag = "H";
          break;
        case 2:
          _tag = "S";
          break;
        case 3:
          _tag = "U";
          break;
      }
    }

    int id = _random.nextInt(31);
    _tag = _tag + id.toString();
  }
}
