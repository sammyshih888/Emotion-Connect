import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:em_touch/data/constants/globals.dart';
import 'package:em_touch/data/constants/screens.dart';
import 'package:em_touch/presentation/games/rec_emotion_game.dart';
import 'package:em_touch/presentation/widgets/screen_background_widget.dart';

class LeaderboardScreen extends ConsumerWidget {
  final RecEmotionGame gameRef;
  const LeaderboardScreen({
    Key? key,
    required this.gameRef,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenBackgroundWidget(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(30, 0, 30, 50),
              child: Image(image: AssetImage(Globals.logo)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                '這個應用程式通過識別情緒遊戲，來幫助用戶改善社交互動。',
                style: TextStyle(
                  fontSize: Globals.isTablet ? 30 : 20,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Text(
                'This app helps the user improve social interaction throungh practice of recognition of facial emotioins.',
                style: TextStyle(
                  fontSize: Globals.isTablet ? 30 : 20,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: SizedBox(
                width: Globals.isTablet ? 400 : 200,
                height: Globals.isTablet ? 100 : 50,
                child: ElevatedButton(
                  onPressed: () {
                    gameRef.addMenu(menu: Screens.main);
                    gameRef.removeMenu(menu: Screens.leaderboard);
                  },
                  child: Text(
                    '回主畫面',
                    style: TextStyle(
                      fontSize: Globals.isTablet ? 50 : 25,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
