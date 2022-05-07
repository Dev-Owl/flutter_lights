import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lights/game/components/bullet.dart';
import 'package:lights/game/game.dart';

class PlayerComponent extends BodyComponent<LightsGame> with KeyboardHandler {
  /// Create body for our player
  @override
  Body createBody() {
    final shape = CircleShape();
    shape.radius = 0.5;
    final fixtureDef = FixtureDef(shape)
      ..restitution = 0.8
      ..density = 1.0
      ..friction = 0.2;

    final bodyDef = BodyDef()
      ..position = Vector2.all(50)
      ..type = BodyType.dynamic
      ..userData = this;
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  Vector2 impulse = Vector2.zero();

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    var desiredValueX = .0;
    var desiredValueY = .0;
    const speed = 10;
    final vel = body.linearVelocity;
    if (keysPressed.isNotEmpty) {
      if (keysPressed.contains(LogicalKeyboardKey.keyD)) {
        desiredValueX += speed;
      }
      if (keysPressed.contains(LogicalKeyboardKey.keyA)) {
        desiredValueX -= speed;
      }
      if (keysPressed.contains(LogicalKeyboardKey.keyW)) {
        desiredValueY -= speed;
      }
      if (keysPressed.contains(LogicalKeyboardKey.keyS)) {
        desiredValueY += speed;
      }
    }
    final movement = Vector2(desiredValueX, desiredValueY);
    impulse = (movement - vel).scaled(body.mass);
    body.applyLinearImpulse(impulse);
    return true;
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  void fire() {
    final spawnPoint = body.position.clone();
    final heading = (gameRef.mousPosition - spawnPoint);
    heading.normalize();
    debugPrint(heading.toString());
    final bullet = BulletComponent.spaw(
      position: spawnPoint,
      heading: heading,
    );
    gameRef.add(bullet);
  }
}
