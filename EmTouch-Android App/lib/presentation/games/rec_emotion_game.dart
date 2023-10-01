import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:em_touch/data/constants/screens.dart';
import 'package:em_touch/presentation/components/background_component.dart';
import 'package:em_touch/presentation/components/fimg_component.dart';
import 'package:em_touch/presentation/components/panel_component.dart';
import 'package:em_touch/presentation/components/magnifier_component.dart';
import 'package:em_touch/data/constants/globals.dart';
import 'package:em_touch/presentation/components/star_component.dart';
import 'package:em_touch/presentation/inputs/joystick.dart';

class RecEmotionGame extends FlameGame
    with DragCallbacks, HasCollisionDetection {
  /// Background of snow landscape.
  final BackgroundComponent _backgroundComponent = BackgroundComponent();

  final PanelComponent _panelComponent = PanelComponent(joystick: joystick);

  /// Number of presents Santa has grabbed.
  int star = 0;
  int score = 0;

  // quiz target
  String _target = "H";

  /// Total seconds for each game.
  static int _remainingTime = Globals.gameTimeLimit;

  /// Timer for game countdown.
  late Timer gameTimer;

  /// Text UI component for timer.
  late TextComponent _timerText;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    pauseEngine();

    // Configure countdown timer.
    gameTimer = Timer(
      1,
      repeat: true,
      onTick: () {
        if (_remainingTime == 0) {
          // Pause the game.
          pauseEngine();
          // Display game over menu.
          addMenu(menu: Screens.gameOver);
        }
        _remainingTime -= 1;
      },
    );
    // Preload audio files.
    await FlameAudio.audioCache.loadAll(
      [
        // Globals.freezeSound,
        // Globals.itemGrabSound,
        // Globals.flameSound,
        Globals.starSound,
        Globals.rightSound,
        Globals.wrongSound
      ],
    );

    // Add background.
    add(_backgroundComponent);

    // Add face image blocks.
    add(FImgComponent(startY: 0));
    add(FImgComponent(startY: -230));

    // Add magnifier.
    add(MagnifierComponent(joystick: joystick));

    // Add joystick.
    add(joystick);

    // Add panel
    add(_panelComponent);
    // Add ScreenHitBox for boundries for ice blocks.
    add(ScreenHitbox());

    // Configure TextComponent
    _timerText = TextComponent(
      text: '',
      position: Vector2(size.x - 40, 50),
      anchor: Anchor.topRight,
      textRenderer: TextPaint(
        style: TextStyle(
          color: const Color.fromARGB(255, 228, 64, 97),
          fontSize: Globals.isTablet ? 50 : 40,
        ),
      ),
    );

    // Add Score TextComponent.
    add(_timerText);

    gameTimer.start();
  }

  @override
  void update(double dt) {
    super.update(dt);
    gameTimer.update(dt);
    _timerText.text = '$_remainingTime 秒';
  }

  /// Reset score and remaining time to default values.
  void reset() {
    // Scores
    star = 0;
    score = 0;

    // Timers
    _remainingTime = Globals.gameTimeLimit;

    // set up FImgComponents
    removeAll(descendants().whereType<FImgComponent>());
    removeAll(descendants().whereType<StarComponent>());
    add(FImgComponent(startY: 0));
    add(FImgComponent(startY: -230));

    // set up panelcomponent
    descendants().whereType<PanelComponent>().first.position.x = -120;
  }

  void addMenu({
    required Screens menu,
  }) {
    overlays.add(menu.name);
  }

  void removeMenu({
    required Screens menu,
  }) {
    overlays.remove(menu.name);
  }

  String getTarget() {
    return _target;
  }

  String getStar() {
    var s = "";
    for (var i = 0; i < score; i++) {
      s = "$s⭐";
    }
    return s;
  }

  void updateTarget(String target) {
    _target = target;
  }
}
