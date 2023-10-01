import 'package:flame/components.dart';
import 'package:em_touch/data/constants/globals.dart';
import 'package:em_touch/presentation/games/rec_emotion_game.dart';

class BackgroundComponent extends SpriteComponent
    with HasGameRef<RecEmotionGame> {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await gameRef.loadSprite(Globals.backgroundGame);
    size = gameRef.size;
  }
}
