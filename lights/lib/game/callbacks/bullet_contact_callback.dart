import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:lights/game/components/bullet.dart';
import 'package:lights/game/components/enemy.dart';
import 'package:lights/game/components/obstacle.dart';

class BulletEnemyContctCallback
    extends ContactCallback<BulletComponent, EnemyComponent> {}

class BulletObstacleContctCallback
    extends ContactCallback<BulletComponent, ObstacleComponent> {
  @override
  void preSolve(BulletComponent bullet, ObstacleComponent obstacleComponent,
      Contact contact, Manifold oldManifold) {
    contact.setEnabled(false);
    bullet.removeFromParent();
  }
}
