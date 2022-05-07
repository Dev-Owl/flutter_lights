import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lights/game/game.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the shaders
  final program = await FragmentProgram.compile(
    spirv: (await rootBundle.load('assets/shaders/lighting.frag.spv')).buffer,
  );

  // Turn it into a shader with given inputs (floatUniforms).
  final shader = program.shader(
    floatUniforms: Float32List.fromList(<double>[1]),
  );
  final paint = Paint()..shader = shader;

  await Flame.device.fullScreen();
  final game = LightsGame(paint);
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
