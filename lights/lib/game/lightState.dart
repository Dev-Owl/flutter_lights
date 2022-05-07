import 'dart:collection';

import 'package:flame/extensions.dart';

class LightState {
  int nextId = 0;
  HashMap<int, LightObscurerBox> boxes = HashMap<int, LightObscurerBox>();
  HashMap<int, Light> lights = HashMap<int, Light>();

  int add(LightObscurerBox box) {
    final id = nextId;
    nextId++;
    boxes[id] = box;
    return id;
  }

  void remove(int id) {
    boxes.remove(id);
  }

  void update(int id, LightObscurerBox box) {
    boxes[id] = box;
  }

  List<double> encodeFloats() {
    final list = <double>[];
    list.add(boxes.values.length.toDouble());
    for (final box in boxes.values) {
      list.addAll(box.encodeFloats());
    }
    return list;
  }
}

class LightObscurerBox {
  final Vector2 position;
  final Vector2 size;

  LightObscurerBox(this.position, this.size);

  List<double> encodeFloats() {
    return [position.x, position.y, size.x, size.y];
  }
}

class Light {
  final Vector2 position;

  Light(this.position);
}
