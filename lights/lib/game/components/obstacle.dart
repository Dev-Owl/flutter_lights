import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame/particles.dart' as flame;
import 'package:flutter/material.dart';
import 'package:lights/game/game.dart';
import 'package:lights/game/lightState.dart';

class ObstacleComponent extends BodyComponent {
  final Vector2 position;
  final Vector2 size;
  late LightsGame game;
  late int obscurerId;

  ObstacleComponent({required this.position, required this.size});

  @override
  Future<void> onLoad() async {
    game = gameRef as LightsGame;
    obscurerId = game.lightState.addBox(LightObscurerBox(position, size));
    super.onLoad();
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
    final target = direction.normalized().reflected(normal).normalized();

    final rnd = Random();

    gameRef.add(
      ParticleSystemComponent(
        position: impactPoint,
        particle: flame.Particle.generate(
          count: 10,
          generator: (i) => MovingParticle(
            curve: Curves.easeOutQuad,
            to: (target.clone()
                  ..multiply(Vector2(rnd.nextDouble(), rnd.nextDouble()))) *
                10,
            child: CircleParticle(
              radius: rnd.nextDouble(),
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
