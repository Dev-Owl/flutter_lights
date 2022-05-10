import 'dart:ui';

import 'package:flame/extensions.dart';
import 'package:flame/palette.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:lights/game/decoupledBody.dart';
import 'package:lights/game/game.dart';

import '../lightState.dart';

class BulletComponent extends DecoupledBodyComponent<LightsGame> {
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
    final shape = CircleShape();
    shape.radius = 0.5;

    final fixtureDef = FixtureDef(shape)
      ..restitution = 0.8
      ..density = .01
      ..friction = 0;

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
    lightIndex = gameRef.lightState.addLight(Light(
        gameRef.physicsToWorld(body.position),
        Color.fromARGB(255, 158, 95, 0),
        300,
        15));

    final impulse = heading * body.mass * 1000;
    body.applyLinearImpulse(impulse);
    super.onMount();
  }

  @override
  void onRemove() {
    gameRef.lightState.removeLight(lightIndex);
    super.onRemove();
  }

  @override
  void update(double dt) {
    super.update(dt);
    gameRef.lightState.updateLight(
        lightIndex,
        Light(gameRef.physicsToWorld(body.position),
            Color.fromARGB(255, 158, 95, 0), 300, 15));

    final rect = gameRef.camera.worldBounds!;
    if (rect.containsPoint(body.position) == false) {
      removeFromParent();
    }
  }
}
