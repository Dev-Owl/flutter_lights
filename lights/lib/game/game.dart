import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:lights/game/components/enemy.dart';
import 'package:lights/game/components/obstacle.dart';
import 'package:lights/game/components/player.dart';

class LightsGame extends Forge2DGame with HasKeyboardHandlerComponents {
  late final PlayerComponent player;
  LightsGame()
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
    await add(EnemyComponent.spawn(
        spawnPoint: Vector2(-10, 0), playerComponent: player));

    return super.onLoad();
  }
}
