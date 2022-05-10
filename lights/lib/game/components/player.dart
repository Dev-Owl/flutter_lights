import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lights/game/components/bullet.dart';
import 'package:lights/game/decoupledBody.dart';
import 'package:lights/game/game.dart';

import '../lightState.dart';

class PlayerComponent extends DecoupledBodyComponent<LightsGame>
    with KeyboardHandler {
  int playerLight = -1;

  /// Create body for our player
  @override
  Body createBody() {
    final shape = CircleShape();
    shape.radius = 2.5;
    final fixtureDef = FixtureDef(shape)
      ..restitution = 0.8
      ..density = 1.0
      ..friction = 0.2;

    final bodyDef = BodyDef()
      ..position = Vector2.all(50)
      ..type = BodyType.dynamic
      ..userData = this;

    paint = Paint()
      ..color = Colors.orange
      ..blendMode = BlendMode.overlay;

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  Vector2 impulse = Vector2.zero();

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    var desiredValueX = .0;
    var desiredValueY = .0;
    const speed = 50;
    final vel = body.linearVelocity;
    var handled = false;
    if (keysPressed.isNotEmpty) {
      if (keysPressed.contains(LogicalKeyboardKey.keyD)) {
        desiredValueX += speed;
        handled = true;
      }
      if (keysPressed.contains(LogicalKeyboardKey.keyA)) {
        desiredValueX -= speed;
        handled = true;
      }
      if (keysPressed.contains(LogicalKeyboardKey.keyW)) {
        desiredValueY -= speed;
        handled = true;
      }
      if (keysPressed.contains(LogicalKeyboardKey.keyS)) {
        desiredValueY += speed;
        handled = true;
      }
    }
    final movement = Vector2(desiredValueX, desiredValueY)
        .normalized()
        .scaled(speed.toDouble());
    impulse = (movement - vel).scaled(body.mass);
    body.applyLinearImpulse(impulse);
    return !handled;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // update light position
    if (playerLight != -1) {
      final time = gameRef.currentTime();
      final wave = (sin(time) + 3) / 4 +
          (sin(time * 10) * 0.03) +
          (sin(time * 30) * 0.025) +
          (sin(time * 100) * 0.01);
      gameRef.lightState.updateLight(
          playerLight,
          Light(scaledPosition, Color.fromARGB(255, 187, 145, 29), wave * 300,
              15));
    }
  }

  @override
  void onMount() {
    playerLight = gameRef.lightState.addLight(
        Light(scaledPosition, Color.fromARGB(255, 187, 145, 29), 300, 15));
    super.onMount();
  }

  @override
  void onRemove() {
    gameRef.lightState.removeLight(playerLight);
    super.onRemove();
  }

  void fire() {
    final spawnPoint = body.position.clone();
    final heading = (gameRef.mousePosition - spawnPoint);
    heading.normalize();
    final bullet = BulletComponent.spawn(
      startPosition: spawnPoint,
      heading: heading,
    );
    gameRef.add(bullet);
  }
}
