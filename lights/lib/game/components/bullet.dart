import 'package:flame/palette.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class BulletComponent extends BodyComponent {
  Vector2 position;
  Vector2 heading;

  BulletComponent.spawn({
    required this.position,
    required this.heading,
  });

  @override
  Body createBody() {
    position = position + heading.scaled(1.0);
    paint = BasicPalette.blue.paint();
    final shape = PolygonShape();
    shape.setAsBoxXY(0.1, 0.1);
    final fixtureDef = FixtureDef(shape)
      ..restitution = 0.8
      ..density = .1
      ..friction = 0.2;

    final bodyDef = BodyDef()
      ..position = position
      ..type = BodyType.dynamic
      ..bullet = true
      ..userData = this;
    final body = world.createBody(bodyDef)..createFixture(fixtureDef);

    return body;
  }

  @override
  void onMount() {
    final impulse = heading * 35 * body.mass;
    body.applyLinearImpulse(impulse);
    super.onMount();
  }
}
