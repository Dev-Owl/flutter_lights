import 'package:flame/palette.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:lights/game/components/player.dart';

class EnemyComponent extends BodyComponent {
  final PlayerComponent playerComponent;
  final Vector2 spawnPoint;
  final double speed = 8;

  EnemyComponent.spawn({
    required this.spawnPoint,
    required this.playerComponent,
  });

  @override
  Body createBody() {
    paint = BasicPalette.red.paint();
    final shape = CircleShape();
    shape.radius = .5;
    final fixtureDef = FixtureDef(shape)
      ..restitution = 0.8
      ..density = 1.0
      ..friction = 0.2;

    final bodyDef = BodyDef()
      ..position = spawnPoint
      ..type = BodyType.dynamic
      ..userData = this;
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void update(double dt) {
    final playerDirection = (playerComponent.body.position - body.position);
    playerDirection.normalize();
    final vel = body.linearVelocity;
    final velChange = (playerDirection * speed) - vel;
    velChange.scale(body.mass);
    body.applyLinearImpulse(velChange);
    super.update(dt);
  }
}
