import 'dart:ui' as ui;

import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lights/game/game.dart';

Future<ui.Image> getUiImage(
    String imageAssetPath, int height, int width) async {
  final ByteData assetImageByteData = await rootBundle.load(imageAssetPath);
  final codec = await ui.instantiateImageCodec(
    assetImageByteData.buffer.asUint8List(),
    targetHeight: height,
    targetWidth: width,
  );
  final image = (await codec.getNextFrame()).image;
  return image;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the shaders
  final lightImage = await getUiImage('assets/textures/light.png', 1024, 1024);
  final program = await ui.FragmentProgram.compile(
    spirv: (await rootBundle.load('assets/shaders/lighting.frag.spv')).buffer,
    debugPrint: true,
  );

  await Flame.device.fullScreen();
  final game = LightsGame(program, lightImage);
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
