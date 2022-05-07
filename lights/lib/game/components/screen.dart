import 'dart:typed_data';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/rendering.dart';
import 'package:lights/game/components/player.dart';
import 'package:lights/game/game.dart';

class ScreenComponent extends PositionComponent with HasGameRef<LightsGame> {
  Paint shaderPaint = Paint();

  ScreenComponent();

  @override
  Future<void>? onLoad() {
    anchor = Anchor.topLeft;
    return super.onLoad();
  }

  @override
  void update(double dt) {
    shaderPaint = generatePaint();
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
        Rect.fromLTWH(0, 0, gameRef.size.x / 2.0, gameRef.size.y / 2.0),
        shaderPaint);
  }

  Paint generatePaint() {
    // Turn it into a shader with given inputs (floatUniforms).
    final resolution = Vector2(gameRef.size.x / 2, gameRef.size.y / 2);
    final shader = gameRef.shaderProgram.shader(
      floatUniforms: Float32List.fromList(<double>[resolution.x, resolution.y]),
      samplerUniforms: <ImageShader>[
        ImageShader(gameRef.lightImage, TileMode.repeated, TileMode.repeated,
            Matrix4.identity().storage)
      ],
    );
    final paint = Paint()..shader = shader;
    return paint;
  }
}
