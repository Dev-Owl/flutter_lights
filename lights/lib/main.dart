import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:lights/game/game.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  final game = LightsGame();
  runApp(MaterialApp(
    home: GameWidget(
      game: game,
      loadingBuilder: (context) => const Material(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      //Work in progress error handling
      errorBuilder: (context, ex) {
        //Print the error in th dev console
        debugPrint(ex.toString());
        return const Material(
          child: Center(
            child: Text('Sorry, something went wrong. Reload me'),
          ),
        );
      },
    ),
  ));
}
