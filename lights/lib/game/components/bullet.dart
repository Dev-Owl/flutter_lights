import 'dart:ui';

import 'package:flame/extensions.dart';
import 'package:flame/palette.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:lights/game/game.dart';

import '../lightState.dart';

class BulletComponent extends BodyComponent {
  int lightIndex = -1;
  Vector2 startPosition;
  Vector2 heading;

  BulletComponent.spawn({
    required this.startPosition,
    required this.heading,
  });

  @override
  Body createBody() {
    startPosition = startPosition + heading.scaled(3.0);
    final shape = PolygonShape();
    shape.setAsBoxXY(0.5, 0.5);

    final fixtureDef = FixtureDef(shape)
      ..restitution = 0.8
      ..density = .1
      ..friction = 0.2;

    final bodyDef = BodyDef()
      ..position = startPosition
      ..type = BodyType.dynamic
      ..bullet = true
      ..userData = this;

    paint = Paint()
      ..color = Colors.black
      ..blendMode = BlendMode.multiply;

    final body = world.createBody(bodyDef)..createFixture(fixtureDef);

    return body;
  }

  @override
  void onMount() {
    lightIndex = (gameRef as LightsGame)
        .lightState
        .addLight(Light(body.position, Colors.orange, 50, 2));

    final impulse = heading * 35 * 5 * 4 * body.mass;
    body.applyLinearImpulse(impulse);
    super.onMount();
  }

  @override
  void onRemove() {
    (gameRef as LightsGame).lightState.removeLight(lightIndex);
    super.onRemove();
  }

  @override
  void update(double dt) {
    super.update(dt);
    (gameRef as LightsGame)
        .lightState
        .updateLight(lightIndex, Light(body.position, Colors.orange, 50, 2));
    final rect = Rect.fromLTWH(0, 0, gameRef.size.x, gameRef.size.y);

    if (rect.containsPoint(body.position) == false) {
      removeFromParent();
    }
  }
}
