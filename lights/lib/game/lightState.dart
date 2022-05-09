import 'dart:collection';

import 'package:flame/extensions.dart';

class LightState {
  int nextId = 0;
  HashMap<int, LightObscurerBox> boxes = HashMap<int, LightObscurerBox>();
  HashMap<int, Light> lights = HashMap<int, Light>();

  // Boxes
  int addBox(LightObscurerBox box) {
    final id = nextId;
    nextId++;
    boxes[id] = box;
    return id;
  }

  void removeBox(int id) {
    boxes.remove(id);
  }

  void updateBox(int id, LightObscurerBox box) {
    boxes[id] = box;
  }

  // Lights
  int addLight(Light light) {
    final id = nextId;
    nextId++;
    lights[id] = light;
    return id;
  }

  void removeLight(int id) {
    lights.remove(id);
  }

  void updateLight(int id, Light light) {
    lights[id] = light;
  }
}

class LightObscurerBox {
  final Vector2 position;
  final Vector2 size;

  LightObscurerBox(this.position, this.size);
}

class Light {
  final Vector2 position;
  final Color color;
  final double range;
  final double radius;

  Light(this.position, this.color, this.range, this.radius);
}
