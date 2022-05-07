import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame/particles.dart' as flame;
import 'package:flutter/material.dart';

class ObstacleComponent extends BodyComponent {
  final Vector2 position;
  final Vector2 size;

  ObstacleComponent({required this.position, required this.size});

  @override
  Body createBody() {
    final shape = PolygonShape();
    shape.setAsBoxXY(size.x, size.y);
    final fixtureDef = FixtureDef(shape)
      ..restitution = 0.8
      ..density = 1.0
      ..friction = 0.2;

    final bodyDef = BodyDef()
      ..position = position
      ..type = BodyType.static
      ..userData = this;
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  void impact(Vector2 direction, Vector2 impactPoint, Vector2 normal) {
    final target = direction.normalized().reflected(normal).normalized();

    final rnd = Random();

    gameRef.add(
      ParticleSystemComponent(
        position: impactPoint,
        particle: flame.Particle.generate(
            count: 10,
            generator: (i) {
              final acceleration = Vector2.random(rnd);
              return AcceleratedParticle(
                acceleration: (target.clone()..multiply(acceleration)) * 10,
                child: flame.CircleParticle(
                  radius: 0.1,
                  paint: Paint()..color = Colors.red,
                ),
              );
            }),
      ),
    );
  }
}
