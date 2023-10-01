import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:em_touch/presentation/components/star_component.dart';
import 'package:em_touch/presentation/games/rec_emotion_game.dart';
import 'package:em_touch/data/constants/globals.dart';
import 'dart:math' as math;

class PanelComponent extends SpriteComponent with HasGameRef<RecEmotionGame> {
  final JoystickComponent joystick;

  /// Height of the sprite.
  final double _spriteHeight = Globals.isTablet ? 200.0 : 100.0;

  /// Speed of the gift.
  double speed = Globals.isTablet ? 300 : 150;

  /// Speed and direction of gift.
  late Vector2 _velocity;

  /// Angle or the gift on bounce back.
  final double degree = math.pi / 180;

  /// Used for generating random position of gift.
  final math.Random _random = math.Random();

  late TextComponent _textComponent;
  late Sprite spAngry;
  late Sprite spHappy;
  late Sprite spSad;
  late Sprite spSurp;

  //FImgComponent({required this.startPosition});
  PanelComponent({required this.joystick});

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    Paint p = Paint();
    p.color = const Color.fromARGB(179, 255, 255, 255);

    canvas.drawRect(
        Rect.fromCenter(center: const Offset(100, 90), width: 60, height: 36),
        p);

    Paint pe = Paint();
    pe.color = const Color.fromARGB(255, 56, 90, 132);
    pe.strokeWidth = 3;
    pe.style = PaintingStyle.stroke;

    Paint pok = Paint();
    pok.color = const Color.fromARGB(255, 0, 200, 0);
    pok.style = PaintingStyle.fill;
    pe.strokeWidth = 3;

    for (int i = 1; i <= 3; i++) {
      double py = 100 - i * 30;
      if (gameRef.star >= i) {
        canvas.drawRect(
            Rect.fromCenter(center: Offset(-20, py), width: 20, height: 20),
            pok);
      } else {
        canvas.drawRect(
            Rect.fromCenter(center: Offset(-20, py), width: 20, height: 20),
            pe);
      }
    }
  }

  void resetTarget() {
    String tag = "";
    while (true) {
      int i = _random.nextInt(4);
      tag = "AHSU".substring(i, i + 1);
      if (!tag.contains(gameRef.getTarget())) {
        gameRef.updateTarget(tag);
        break;
      }
    }

    String text = "";
    switch (tag) {
      case "A":
        sprite = spAngry;
        text = "生氣";
        break;
      case "H":
        sprite = spHappy;
        text = "開心";
        break;
      case "S":
        sprite = spSad;
        text = "難過";
        break;
      case "U":
        sprite = spSurp;
        text = "驚訝";
        break;
    }
    _textComponent.text = text;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    spAngry = await gameRef.loadSprite(Globals.targetA);

    spHappy = await gameRef.loadSprite(Globals.targetH);

    spSad = await gameRef.loadSprite(Globals.targetS);

    spSurp = await gameRef.loadSprite(Globals.targetU);

    final double spawnAngle = _getSpawnAngle();

    /// Speed of the gift.
    double speed = Globals.isTablet ? 300 : 150;
    final double vx = math.cos(spawnAngle * degree) * speed;
    final double vy = math.sin(spawnAngle * degree) * speed;

    _velocity = Vector2(vx, vy);

    // Set Text
    _textComponent = TextComponent(
        text: "",
        position: position,
        anchor: Anchor.topLeft,
        textRenderer: TextPaint(
            style: TextStyle(
              color: const Color.fromARGB(255, 99, 0, 0),
              fontSize: Globals.isTablet ? 50 : 25,
            ),
            textDirection: TextDirection.ltr));
    gameRef.add(_textComponent);

    resetTarget();

    position = Vector2(0, 0);

    // Set dimensions of santa sprite.
    width = _spriteHeight;
    height = _spriteHeight;

    // Set anchor of component.
    anchor = Anchor.center;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameRef.star < 3 && position.x < 120) {
      position += _velocity * dt;
    }
    position.y = joystick.y;
    _textComponent.position = Vector2(position.x + 24, position.y + 20);

    if (gameRef.star >= 3) {
      if (gameRef.star == 3) {
        FlameAudio.play(Globals.starSound);
        gameRef.add(StarComponent());
        gameRef.star++;
      }
      position -= _velocity * dt;
      if (position.x < -100) {
        gameRef.star = 0;
        resetTarget();
      }
    }
  }

  double _getSpawnAngle() {
    return 0;
  }

  void addStar() {
    if (gameRef.star < 3) gameRef.star++;
  }

  void minusStar() {
    if (gameRef.star > 0) gameRef.star--;
  }
}
