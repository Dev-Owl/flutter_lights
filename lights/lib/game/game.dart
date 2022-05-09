import 'dart:math';
import 'dart:ui';

import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:lights/game/callbacks/bullet_contact_callback.dart';
import 'package:lights/game/components/enemy.dart';
import 'package:lights/game/components/gun.dart';
import 'package:lights/game/components/obstacle.dart';
import 'package:lights/game/components/player.dart';
import 'package:lights/game/components/lighting.dart';
import 'package:lights/game/lightState.dart';

class LightsGame extends Forge2DGame
    with HasKeyboardHandlerComponents, MouseMovementDetector, TapDetector {
  final FragmentProgram shaderProgram;
  late final PlayerComponent player;
  Vector2 mousePosition = Vector2.zero();
  LightState lightState = LightState();
  int? mouseLight;

  double enemySapwnIntervall = 2;
  double enemySpawnTime = 0;
  LightsGame(this.shaderProgram)
      : super(
          gravity: Vector2.zero(),
          zoom: 2.0,
        );

  @override
  Future<void>? onLoad() async {
    player = PlayerComponent();
    await add(LightingComponent());
    // await add(
    //     ObstacleComponent(position: Vector2(50, 100), size: Vector2.all(20)));

    var obstacles = 40;
    // spawn random obstacles around the map
    var rnd = Random();
    for (var i = 0; i < obstacles; i++) {
      var x = rnd.nextDouble() * size.x;
      var y = rnd.nextDouble() * size.y;

      var boxSize = Vector2(rnd.nextDouble() * 20, rnd.nextDouble() * 20);
      await add(ObstacleComponent(position: Vector2(x, y), size: boxSize));
    }

    await add(player);

    await add(GunComponent(player));
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
    // mouseLight ??=
    //     lightState.addLight(Light(mousePosition, Colors.white, 150, 5));
    // lightState.updateLight(
    //     mouseLight!, Light(mousePosition, Colors.white, 150, 5));
    super.onMouseMove(info);
  }

  @override
  void onTapDown(TapDownInfo info) {
    player.fire();
  }

  @override
  void update(double dt) {
    enemySpawnTime += dt;
    if (enemySapwnIntervall <= enemySpawnTime) {
      add(EnemyComponent.spawn(
          spawnPoint: Vector2(-10, 0), playerComponent: player));

      enemySpawnTime = 0;
    }
    super.update(dt);
  }
}
