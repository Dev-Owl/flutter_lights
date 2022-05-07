import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flame/particles.dart' as flame;
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:lights/game/components/player.dart';

class EnemyComponent extends BodyComponent {
  final PlayerComponent playerComponent;
  final Vector2 spawnPoint;
  final double speed = 8;

  EnemyComponent.spawn({
    required this.spawnPoint,
    required this.playerComponent,
  });

  @override
  Body createBody() {
    paint = BasicPalette.red.paint();
    final shape = CircleShape();
    shape.radius = .5;
    final fixtureDef = FixtureDef(shape)
      ..restitution = 0.8
      ..density = 1.0
      ..friction = 0.2;

    final bodyDef = BodyDef()
      ..position = spawnPoint
      ..type = BodyType.dynamic
      ..userData = this;
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void update(double dt) {
    final playerDirection = (playerComponent.body.position - body.position);
    playerDirection.normalize();
    final vel = body.linearVelocity;
    final velChange = (playerDirection * speed) - vel;
    velChange.scale(body.mass);
    body.applyLinearImpulse(velChange);
    super.update(dt);
  }

  final rnd = Random();

  Vector2 randomVector2() => (Vector2.random(rnd) - Vector2.random(rnd)) * 20;
  @override
  void onRemove() {
    gameRef.add(
      ParticleSystemComponent(
        position: body.position,
        particle: flame.Particle.generate(
          count: 25,
          generator: (i) => flame.AcceleratedParticle(
            acceleration: randomVector2(),
            child: flame.CircleParticle(
              radius: 0.1,
              paint: Paint()..color = Colors.red,
            ),
          ),
        ),
      ),
    );
    super.onRemove();
  }
}
