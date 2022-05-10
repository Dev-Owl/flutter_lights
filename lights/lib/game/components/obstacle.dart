import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame/particles.dart' as flame;
import 'package:flutter/material.dart';
import 'package:lights/game/decoupledBody.dart';
import 'package:lights/game/game.dart';
import 'package:lights/game/lightState.dart';

class ObstacleComponent extends DecoupledBodyComponent<LightsGame> {
  final Vector2 position;
  final Vector2 size;
  late int obscurerId;

  ObstacleComponent({required this.position, required this.size});

  @override
  Future<void> onLoad() async {
    obscurerId = gameRef.lightState.addBox(LightObscurerBox(
        gameRef.physicsToWorld(position), gameRef.physicsToWorld(size)));
    super.onLoad();
  }

  @override
  void onRemove() {
    gameRef.lightState.removeBox(obscurerId);
    super.onRemove();
  }

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

    paint = Paint()
      ..color = Colors.pink
      ..blendMode = BlendMode.multiply;

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  void impact(Vector2 direction, Vector2 impactPoint, Vector2 normal) {
    final target = gameRef
        .physicsToWorld(direction.normalized().reflected(normal).normalized());
    final rnd = Random();

    gameRef.add(
      ParticleSystemComponent(
        position: gameRef.physicsToWorld(impactPoint),
        particle: flame.Particle.generate(
          count: 10,
          generator: (i) => MovingParticle(
            curve: Curves.easeOutQuad,
            to: (target.clone()
                  ..multiply(Vector2(rnd.nextDouble(), rnd.nextDouble()))) *
                10,
            child: CircleParticle(
              radius: gameRef.physicsScale * rnd.nextDouble(),
              paint: Paint()
                ..color = Colors.pink
                ..blendMode = BlendMode.multiply,
            ),
          ),
        ),
      ),
    );
  }
}
