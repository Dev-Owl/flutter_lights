import 'package:flame_forge2d/flame_forge2d.dart';

class ObstacleComponent extends BodyComponent {
  final Vector2 position;
  final Vector2 size;

  ObstacleComponent({required this.position, required this.size});

  @override
  Body createBody() {
    final shape = PolygonShape();
    shape.setAsBoxXY(size.x, size.y);
    final fixtureDef = FixtureDef(shape)
      ..restitution = 0.8
      ..density = 1.0
      ..friction = 0.2;

    final bodyDef = BodyDef()
      ..position = position
      ..type = BodyType.static
      ..userData = this;
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
