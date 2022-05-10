import 'dart:math';
import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
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

  double enemySpawnInterval = 2;
  double enemySpawnTime = 0;
  LightsGame(this.shaderProgram)
      : super(
          gravity: Vector2.zero(),
          zoom: 1.0,
        );

  @override
  Future<void>? onLoad() async {
    player = PlayerComponent();
    await add(LightingComponent());

    camera.viewport = FixedResolutionViewport(Vector2(400, 300));
    camera.worldBounds = Rect.fromLTWH(
        0,
        0,
        camera.viewport.effectiveSize.x * 2,
        camera.viewport.effectiveSize.y * 2);

    var obstacles = 15;
    // spawn random obstacles around the map
    var rnd = Random();
    for (var i = 0; i < obstacles; i++) {
      var x = rnd.nextDouble() *
          (camera.viewport as FixedResolutionViewport).effectiveSize.x;
      var y = rnd.nextDouble() *
          (camera.viewport as FixedResolutionViewport).effectiveSize.y;

      var boxSize = Vector2(rnd.nextDouble() * 20, rnd.nextDouble() * 20);
      await add(ObstacleComponent(position: Vector2(x, y), size: boxSize));
    }

    await add(player);
    camera.followBodyComponent(player);

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
    if (enemySpawnInterval <= enemySpawnTime) {
      add(EnemyComponent.spawn(
          spawnPoint: Vector2(-10, 0), playerComponent: player));

      enemySpawnTime = 0;
    }
    super.update(dt);
  }
}
