import 'dart:math';
import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:lights/game/callbacks/bullet_contact_callback.dart';
import 'package:lights/game/components/enemy.dart';
import 'package:lights/game/components/obstacle.dart';
import 'package:lights/game/components/player.dart';
import 'package:lights/game/components/lighting.dart';
import 'package:lights/game/lightState.dart';

class LightsGame extends Forge2DGame
    with HasKeyboardHandlerComponents, MouseMovementDetector, TapDetector {
  final FragmentProgram shaderProgram;
  final double physicsScale = 10.0;
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

    camera.worldBounds =
        Rect.fromLTWH(0, 0, 1920 * physicsScale, 1080 * physicsScale);

    var obstacles = 400;
    // spawn random obstacles around the map
    var rnd = Random();
    for (var i = 0; i < obstacles; i++) {
      var x = rnd.nextDouble() * camera.worldBounds!.size.width;
      var y = rnd.nextDouble() * camera.worldBounds!.size.height;
      var position = worldToPhysics(Vector2(x, y));

      var boxSize = Vector2(rnd.nextDouble() * 20, rnd.nextDouble() * 20);
      await add(ObstacleComponent(position: position, size: boxSize));
    }

    await add(player);
    await add(EnemyComponent.spawn(
        spawnPoint: Vector2(-10, 0), playerComponent: player));
    addContactCallback(BulletObstacleContctCallback());
    addContactCallback(BulletEnemyContctCallback());
    addContactCallback(BulletPlayerContctCallback());

    return super.onLoad();
  }

  @override
  void onMouseMove(PointerHoverInfo info) {
    mousePosition = worldToPhysics(info.eventPosition.game);
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
    final rnd = Random();
    if (enemySpawnInterval <= enemySpawnTime) {
      // spawn an enemy somewhere outside of screen
      final spawnOffset = Vector2(
            rnd.nextDouble() * 2 - 1,
            rnd.nextDouble() * 2 - 1,
          ) *
          max(size.x, size.y);
      add(EnemyComponent.spawn(
          spawnPoint: player.body.position + worldToPhysics(spawnOffset),
          playerComponent: player));

      enemySpawnTime = 0;
    }

    camera.followVector2(player.scaledPosition);
    super.update(dt);
  }

  Vector2 worldToPhysics(Vector2 world) {
    return world / physicsScale;
  }

  Vector2 physicsToWorld(Vector2 physics) {
    return physics * physicsScale;
  }
}
