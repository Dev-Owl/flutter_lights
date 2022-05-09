import 'dart:ui';

import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:lights/game/callbacks/bullet_contact_callback.dart';
import 'package:lights/game/components/enemy.dart';
import 'package:lights/game/components/gun.dart';
import 'package:lights/game/components/obstacle.dart';
import 'package:lights/game/components/player.dart';
import 'package:lights/game/components/screen.dart';
import 'package:lights/game/lightState.dart';

class LightsGame extends Forge2DGame
    with HasKeyboardHandlerComponents, MouseMovementDetector, TapDetector {
  final FragmentProgram shaderProgram;
  late final PlayerComponent player;
  Vector2 mousePosition = Vector2.zero();
  LightState lightState = LightState();
  int? mouseLight;

  double enemySapwnIntervall = 2;
  double enemySapwnTime = 0;
  LightsGame(this.shaderProgram)
      : super(
          gravity: Vector2.zero(),
          zoom: 2.0,
        );

  @override
  Future<void>? onLoad() async {
    player = PlayerComponent();
    await add(
        ObstacleComponent(position: Vector2(50, 100), size: Vector2.all(20)));
    await add(
        ObstacleComponent(position: Vector2(100, 100), size: Vector2.all(20)));
    await add(
        ObstacleComponent(position: Vector2(150, 100), size: Vector2.all(20)));
    await add(player);

    await add(GunComponent(player));
    await add(ScreenComponent());
    await add(EnemyComponent.spawn(
        spawnPoint: Vector2(-10, 0), playerComponent: player));
    addContactCallback(BulletObstacleContctCallback());
    addContactCallback(BulletEnemyContctCallback());
    addContactCallback(BulletPlayerContctCallback());

    return super.onLoad();
  }

  @override
  void onMouseMove(PointerHoverInfo info) {
    mousePosition = info.eventPosition.game;
    mouseLight ??=
        lightState.addLight(Light(mousePosition, Colors.blue.shade900, 150, 5));
    lightState.updateLight(
        mouseLight!, Light(mousePosition, Colors.blue.shade900, 150, 5));
    super.onMouseMove(info);
  }

  @override
  void onTapDown(TapDownInfo info) {
    player.fire();
  }

  @override
  void update(double dt) {
    enemySapwnTime += dt;
    if (enemySapwnIntervall <= enemySapwnTime) {
      add(EnemyComponent.spawn(
          spawnPoint: Vector2(-10, 0), playerComponent: player));

      enemySapwnTime = 0;
    }
    super.update(dt);
  }
}
