import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flame/particles.dart' as flame;
import 'package:flame/particles.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:lights/game/components/player.dart';
import 'package:lights/game/decoupledBody.dart';

import '../game.dart';
import '../lightState.dart';

class EnemyComponent extends DecoupledBodyComponent<LightsGame> {
  final PlayerComponent playerComponent;
  final Vector2 spawnPoint;
  double speed = 20;
  int light = -1;
  int health = 100;

  EnemyComponent.spawn({
    required this.spawnPoint,
    required this.playerComponent,
  });

  @override
  Body createBody() {
    paint = BasicPalette.red.paint();

    // Physics
    final shape = CircleShape();
    shape.radius = 2.5;
    final fixtureDef = FixtureDef(shape)
      ..restitution = 0.8
      ..density = 1.0
      ..friction = 0.2;

    final bodyDef = BodyDef()
      ..position = spawnPoint
      ..type = BodyType.dynamic
      ..userData = this;

    paint = Paint()
      ..color = Colors.red
      ..blendMode = BlendMode.multiply;

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void onMount() {
    light = gameRef.lightState.addLight(
        Light(scaledPosition, Color.fromARGB(255, 133, 36, 29), 300, 20));
    super.onMount();
  }

  @override
  void update(double dt) {
    final playerDirection = (playerComponent.body.position - body.position);
    playerDirection.normalize();
    final vel = body.linearVelocity;
    final velChange = (playerDirection * speed) - vel;
    velChange.scale(body.mass);
    body.applyLinearImpulse(velChange);

    gameRef.lightState.updateLight(light,
        Light(scaledPosition, Color.fromARGB(255, 133, 36, 29), 300, 20));

    super.update(dt);
  }

  @override
  void onRemove() {
    gameRef.lightState.removeLight(light);
    super.onRemove();
  }

  void splatter(Vector2 from, {int count = 25, double spread = 7.0}) {
    final target =
        -gameRef.physicsToWorld((from - body.position).normalized() * 2.0);
    final rnd = Random();

    gameRef.add(
      ParticleSystemComponent(
        position: gameRef.physicsToWorld(body.position),
        particle: flame.Particle.generate(
          count: count,
          generator: (i) => MovingParticle(
            curve: Curves.easeOutQuad,
            to: (target.clone() * 10) +
                gameRef.physicsToWorld(Vector2(
                    rnd.nextDouble() * spread, rnd.nextDouble() * spread)),
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
