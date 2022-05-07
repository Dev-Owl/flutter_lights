import 'dart:ui';

import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
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
  final Image lightImage;
  late final PlayerComponent player;
  Vector2 mousePosition = Vector2.zero();
  LightState lightState = LightState();
  int? mouseLight;

  double enemySapwnIntervall = 2;
  double enemySapwnTime = 0;
  LightsGame(this.shaderProgram, this.lightImage)
      : super(
          gravity: Vector2.zero(),
        );

  @override
  Future<void>? onLoad() async {
    player = PlayerComponent();
    await add(
        ObstacleComponent(position: Vector2(10, 10), size: Vector2.all(1)));
    await add(
        ObstacleComponent(position: Vector2(20, 10), size: Vector2.all(1)));
    await add(
        ObstacleComponent(position: Vector2(30, 10), size: Vector2.all(1)));
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
    mouseLight ??= lightState.addLight(Light(mousePosition));
    lightState.updateLight(mouseLight!, Light(mousePosition));
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
