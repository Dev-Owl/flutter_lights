import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:lights/game/components/player.dart';
import 'package:lights/game/game.dart';

class GunComponent extends PositionComponent with HasGameRef<LightsGame> {
  final PlayerComponent playerComponent;

  GunComponent(this.playerComponent);

  @override
  Future<void>? onLoad() {
    anchor = Anchor.topLeft;
    return super.onLoad();
  }

  @override
  void update(double dt) {
    final nextPosition = _gunPosition();
    // Rotates towards the mouse
    final mousePosition = gameRef.mousePosition;
    final heading = -(mousePosition - nextPosition);
    final angleToMouse = heading.screenAngle();
    angle = angleToMouse;
    position = nextPosition;
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
        const Rect.fromLTWH(-0.2 * 5, 0, 0.4 * 5, 1.6 * 5),
        Paint()
          ..color = Colors.pink
          ..blendMode = BlendMode.multiply);
  }

  Vector2 _gunPosition() {
    final playerPosition = playerComponent.body.position.clone();
    return playerPosition;
  }
}
