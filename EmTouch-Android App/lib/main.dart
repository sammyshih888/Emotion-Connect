import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:em_touch/data/constants/screens.dart';
import 'package:em_touch/data/services/hive_service.dart';
import 'package:flame/game.dart';
import 'package:em_touch/data/constants/globals.dart';
import 'package:em_touch/presentation/games/rec_emotion_game.dart';
import 'package:em_touch/presentation/screens/game_over_screen.dart';
import 'package:em_touch/presentation/screens/leaderboard_screen.dart';
import 'package:em_touch/presentation/screens/main_menu_screen.dart';

RecEmotionGame _recEmGame = RecEmotionGame();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveService.openHiveBox(boxName: 'settings');

  runApp(ProviderScope(
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (context) {
          Globals.isTablet = MediaQuery.of(context).size.width > 600;

          return GameWidget(
            initialActiveOverlays: [Screens.main.name],
            game: _recEmGame,
            overlayBuilderMap: {
              Screens.gameOver.name:
                  (BuildContext context, RecEmotionGame gameRef) =>
                      GameOverScreen(gameRef: gameRef),
              Screens.main.name:
                  (BuildContext context, RecEmotionGame gameRef) =>
                      MainMenuScreen(gameRef: gameRef),
              Screens.leaderboard.name:
                  (BuildContext context, RecEmotionGame gameRef) =>
                      LeaderboardScreen(gameRef: gameRef),
            },
          );
        },
      ),
    ),
  ));
}
