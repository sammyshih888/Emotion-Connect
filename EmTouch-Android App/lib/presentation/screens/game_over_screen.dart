import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:em_touch/data/constants/globals.dart';
import 'package:em_touch/data/constants/screens.dart';
import 'package:em_touch/presentation/games/rec_emotion_game.dart';
import 'package:em_touch/presentation/widgets/screen_background_widget.dart';

class GameOverScreen extends ConsumerWidget {
  final RecEmotionGame gameRef;
  const GameOverScreen({Key? key, required this.gameRef}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenBackgroundWidget(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 50),
              child: Text(
                '遊戲結束',
                style: TextStyle(
                    fontSize: Globals.isTablet ? 100 : 50,
                    color: const Color.fromARGB(255, 184, 49, 0)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(
                gameRef.score > 0 ? '~ 恭喜獲得 ~' : "再接再厲!!",
                style: TextStyle(
                    fontSize: Globals.isTablet ? 100 : 30,
                    color: const Color.fromARGB(255, 255, 203, 59)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 50),
              child: Text(
                ' ${gameRef.getStar()}',
                style: TextStyle(
                  fontSize: Globals.isTablet ? 100 : 50,
                ),
              ),
            ),
            SizedBox(
              width: Globals.isTablet ? 400 : 200,
              height: Globals.isTablet ? 100 : 50,
              child: ElevatedButton(
                onPressed: () {
                  gameRef.removeMenu(menu: Screens.gameOver);
                  gameRef.reset();
                  gameRef.resumeEngine();
                },
                child: Text(
                  '再玩一次',
                  style: TextStyle(
                    fontSize: Globals.isTablet ? 50 : 25,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: Globals.isTablet ? 400 : 200,
              height: Globals.isTablet ? 100 : 50,
              child: ElevatedButton(
                onPressed: () {
                  gameRef.removeMenu(menu: Screens.gameOver);
                  gameRef.reset();
                  gameRef.addMenu(menu: Screens.main);
                },
                child: Text(
                  '回主畫面',
                  style: TextStyle(
                    fontSize: Globals.isTablet ? 50 : 25,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
