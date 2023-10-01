import 'package:flutter/material.dart';
import 'package:em_touch/data/constants/globals.dart';
import 'package:em_touch/data/constants/screens.dart';
import 'package:em_touch/presentation/games/rec_emotion_game.dart';
import 'package:em_touch/presentation/widgets/screen_background_widget.dart';

class MainMenuScreen extends StatelessWidget {
  final RecEmotionGame gameRef;
  const MainMenuScreen({
    Key? key,
    required this.gameRef,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenBackgroundWidget(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(30, 0, 30, 100),
              child: Image(image: AssetImage(Globals.logo)),
            ),
            SizedBox(
              width: Globals.isTablet ? 400 : 200,
              height: Globals.isTablet ? 100 : 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  gameRef.removeMenu(menu: Screens.main);
                  gameRef.resumeEngine();
                },
                icon: const Icon(
                  Icons.games,
                  size: 20,
                ),
                label: Text(
                  '開 始 遊 戲',
                  style: TextStyle(
                    fontSize: Globals.isTablet ? 50 : 20,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            SizedBox(
              width: Globals.isTablet ? 400 : 200,
              height: Globals.isTablet ? 100 : 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  gameRef.addMenu(menu: Screens.leaderboard);
                  gameRef.removeMenu(menu: Screens.main);
                },
                icon: const Icon(
                  Icons.info,
                  size: 20.0,
                ),
                label: Text(
                  'EM TOUCH.',
                  style: TextStyle(
                    fontSize: Globals.isTablet ? 50 : 20,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 60, 0, 10),
              child: Text(
                'created by sammshih888',
                style: TextStyle(
                    fontSize: Globals.isTablet ? 50 : 18,
                    color: const Color.fromARGB(255, 62, 62, 62)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 50),
              child: Text(
                'https://github.com/sammyshih888/',
                style: TextStyle(
                    fontSize: Globals.isTablet ? 50 : 18,
                    color: const Color.fromARGB(255, 30, 101, 182)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
