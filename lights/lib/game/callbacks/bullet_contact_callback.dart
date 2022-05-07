import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:lights/game/components/bullet.dart';
import 'package:lights/game/components/enemy.dart';
import 'package:lights/game/components/obstacle.dart';
import 'package:lights/game/components/player.dart';

class BulletEnemyContctCallback
    extends ContactCallback<BulletComponent, EnemyComponent> {
  @override
  void preSolve(
    BulletComponent a,
    EnemyComponent b,
    Contact contact,
    Manifold oldManifold,
  ) {
    contact.setEnabled(false);
    a.removeFromParent();
    b.removeFromParent();
  }
}

class BulletPlayerContctCallback
    extends ContactCallback<BulletComponent, PlayerComponent> {
  @override
  void preSolve(
    BulletComponent a,
    PlayerComponent b,
    Contact contact,
    Manifold oldManifold,
  ) {
    contact.setEnabled(false);
  }
}

class BulletObstacleContctCallback
    extends ContactCallback<BulletComponent, ObstacleComponent> {
  @override
  void preSolve(
    BulletComponent a,
    ObstacleComponent b,
    Contact contact,
    Manifold oldManifold,
  ) {
    contact.setEnabled(false);
    a.removeFromParent();
    final worldContact = WorldManifold();
    contact.getWorldManifold(worldContact);

    b.impact(
        a.body.linearVelocity, worldContact.points.first, worldContact.normal);
  }
}
