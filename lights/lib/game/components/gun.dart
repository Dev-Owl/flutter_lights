import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:lights/game/components/player.dart';
import 'package:lights/game/game.dart';

class GunComponent extends PositionComponent with HasGameRef<LightsGame> {
  final PlayerComponent playerComponent;

  GunComponent(this.playerComponent);

  @override
  Future<void>? onLoad() {
    anchor = Anchor.topLeft;
    return super.onLoad();
  }

  @override
  void update(double dt) {
    final nextPosition = _gunPosition();
    final angleToMouse = nextPosition.angleTo(gameRef.mousePosition);

    position = nextPosition;
    angle = angleToMouse;
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(const Rect.fromLTWH(0, 0, 0.2, 0.4), debugPaint);
  }

  Vector2 _gunPosition() {
    final playerPosition = playerComponent.body.position.clone();
    playerPosition.add(Vector2(0, 0.5));
    return playerPosition;
  }
}
