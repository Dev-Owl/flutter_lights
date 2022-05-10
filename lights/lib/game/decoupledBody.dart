import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:lights/game/game.dart';

abstract class DecoupledBodyComponent<G extends Forge2DGame>
    extends BodyComponent<G> {
  Vector2 get scaledPosition =>
      body.position * (gameRef as LightsGame).physicsScale;

  @override
  void render(Canvas canvas) {
    // prevent BodyComponent's own rendering
    final scale = (gameRef as LightsGame).physicsScale;

    if (body.fixtures.first.shape is CircleShape) {
      final circle = body.fixtures.first.shape as CircleShape;
      final position = body.position * scale;
      final radius = circle.radius * scale;

      final matrix = Matrix4.identity();
      matrix.translate(body.position.x, body.position.y);
      matrix.rotateZ(angle);

      canvas.save();
      canvas.transform((matrix.clone()..invert()).storage);
      canvas.drawCircle(position.toOffset(), radius, paint);
      canvas.restore();
    }
    if (body.fixtures.first.shape is PolygonShape) {
      // assume it's an axis-aligned rectangle
      final polygon = body.fixtures.first.shape as PolygonShape;
      final position = body.position * scale;
      final width = (polygon.vertices[0].x * scale) * 2;
      final height = (polygon.vertices[0].y * scale) * 2;
      final positionWithOffset = position - Vector2(width / 2, height / 2);

      final matrix = Matrix4.identity();
      matrix.translate(body.position.x, body.position.y);
      matrix.rotateZ(angle);

      canvas.save();
      canvas.transform((matrix.clone()..invert()).storage);
      canvas.drawRect(
          Rect.fromLTWH(
              positionWithOffset.x, positionWithOffset.y, width, height),
          paint);
      canvas.restore();
    }
  }
}
