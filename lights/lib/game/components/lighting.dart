import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/image_composition.dart';
import 'package:flutter/material.dart';
import 'package:lights/game/game.dart';

class LightingComponent extends PositionComponent with HasGameRef<LightsGame> {
  late ui.Image dataImage;

  LightingComponent();

  @override
  Future<void>? onLoad() {
    anchor = Anchor.topLeft;
    generateDataImage((image) {
      dataImage = image;
    });
    return super.onLoad();
  }

  @override
  void update(double dt) {
    generateDataImage((image) {
      dataImage = image;
    });
    position = gameRef.camera.position;
    super.update(dt);
  }

  bool circleIntersectsPoint(Vector2 position, double radius, Vector2 point) {
    final distance = (position - point).length;
    return distance < radius;
  }

  List<int> encodeNumber(double value) {
    // each number is a float that uses three bytes
    // x - increment between 0 and 255
    // y - increment between 0 and 255
    // z - the remainder between 0 and 255
    // so the resulting number is (x * 256) + (y * 256 * 256) + z
    final valueInt = (value * 10.0).toInt();
    final increment = valueInt ~/ 256;
    final remainder = valueInt - (increment * 256);

    final y = increment ~/ 256;
    final x = increment - (y * 256);

    if (y > 255) {
      throw Exception('y is too large');
    }
    if ((x * 256.0) + (y * 256.0 * 256.0) + remainder != valueInt) {
      throw Exception('calculation is wrong');
    }
    return [x, y, remainder];
  }

  // cell is 4 bytes
  void writeNumber(ByteData data, int cellIndex, double value) {
    var encoded = encodeNumber(value);
    var byteOffset = cellIndex * 4;
    data.setUint8(byteOffset, encoded[0]);
    data.setUint8(byteOffset + 1, encoded[1]);
    data.setUint8(byteOffset + 2, encoded[2]);
  }

  void generateDataImage(void Function(ui.Image) callback) {
    var width = 1024;
    var height = 1024;
    ByteData bytes = ByteData(width * height * 4);

    // write data to the texture
    var currentCell = 0;
    var lightState = gameRef.lightState;
    var obscurerCount = lightState.boxes.length;
    // write count to the texture
    writeNumber(bytes, currentCell, obscurerCount.toDouble());
    currentCell++;
    // write obscurer data to the texture
    for (int i = 0; i < obscurerCount; i++) {
      var box = lightState.boxes.values.toList()[i];
      writeNumber(bytes, currentCell, box.position.x);
      writeNumber(bytes, currentCell + 1, box.position.y);
      writeNumber(bytes, currentCell + 2, box.size.x);
      writeNumber(bytes, currentCell + 3, box.size.y);
      currentCell += 4;
    }
    // write the light data to the texture
    var lightCount = lightState.lights.length;
    writeNumber(bytes, currentCell, lightCount.toDouble());
    currentCell++;
    for (int i = 0; i < lightCount; i++) {
      var light = lightState.lights.values.toList()[i];
      writeNumber(bytes, currentCell, light.position.x);
      writeNumber(bytes, currentCell + 1, light.position.y);
      writeNumber(bytes, currentCell + 2, light.color.red.toDouble() / 256.0);
      writeNumber(bytes, currentCell + 3, light.color.green.toDouble() / 256.0);
      writeNumber(bytes, currentCell + 4, light.color.blue.toDouble() / 256.0);
      writeNumber(bytes, currentCell + 5, light.color.alpha.toDouble());
      writeNumber(bytes, currentCell + 6, light.range.toDouble());
      writeNumber(bytes, currentCell + 7, light.radius.toDouble());
      currentCell += 8;
    }

    return ui.decodeImageFromPixels(
      bytes.buffer.asUint8List(),
      width,
      height,
      ui.PixelFormat.rgba8888,
      callback,
    );
  }

  @override
  void render(Canvas canvas) {
    final resolution = Vector2(gameRef.size.x, gameRef.size.y);

    // ambient lighting
    var ambientPaint = Paint()
      ..color = ui.Color.fromARGB(3, 255, 255, 255)
      ..blendMode = ui.BlendMode.src;
    canvas.drawRect(
        Rect.fromLTWH(0, 0, gameRef.size.x, gameRef.size.y), ambientPaint);

    double currentLightIndex = 0;
    for (var lightKeyValue in gameRef.lightState.lights.entries) {
      var uniformFloats = <double>[];
      uniformFloats.add(resolution.x);
      uniformFloats.add(resolution.y);
      // data texture size
      uniformFloats.add(1024.0);
      uniformFloats.add(1024.0);
      // light index to draw
      uniformFloats.add(currentLightIndex);
      // find boxes which intersect the light's circle (position and range)
      final light = lightKeyValue.value;
      final lightRange =
          light.range * 1.5; // seems the engine overshoots a little
      final lightPosition = light.position;

      double currentBoxIndex = 0;
      List<double> intersectingBoxes = [];
      for (var boxKeyValue in gameRef.lightState.boxes.entries) {
        // check all four couners for intersections
        var box = boxKeyValue.value;
        var boxPosition = box.position;
        var boxSize = box.size;
        var boxTopLeft = boxPosition - boxSize / 2;
        var boxTopRight = boxPosition + Vector2(boxSize.x, 0) - boxSize / 2;
        var boxBottomLeft = boxPosition + Vector2(0, boxSize.y) - boxSize / 2;
        var boxBottomRight = boxPosition + boxSize - boxSize / 2;

        if (circleIntersectsPoint(lightPosition, lightRange, boxTopLeft) ||
            circleIntersectsPoint(lightPosition, lightRange, boxTopRight) ||
            circleIntersectsPoint(lightPosition, lightRange, boxBottomLeft) ||
            circleIntersectsPoint(lightPosition, lightRange, boxBottomRight)) {
          intersectingBoxes.add(currentBoxIndex);
        }

        currentBoxIndex++;
      }

      // take first three and add to uniform floats
      // place -1 if not enough to fill all 3 slots
      intersectingBoxes.sort((a, b) => gameRef.lightState.boxes[a]!
          .center()
          .distanceTo(lightPosition)
          .compareTo(
              gameRef.lightState.boxes[b]!.center().distanceTo(lightPosition)));
      for (var i = 0; i < 3; i++) {
        if (i < intersectingBoxes.length) {
          uniformFloats.add(intersectingBoxes[i]);
        } else {
          uniformFloats.add(-1.0);
        }
      }

      // put camera position in uniform floats
      uniformFloats.add(gameRef.camera.position.x);
      uniformFloats.add(gameRef.camera.position.y);

      final shader = gameRef.shaderProgram.shader(
        floatUniforms: Float32List.fromList(uniformFloats),
        samplerUniforms: <ImageShader>[
          ImageShader(dataImage, TileMode.repeated, TileMode.repeated,
              Matrix4.identity().storage),
        ],
      );
      final paint = Paint()..shader = shader;
      paint.blendMode = BlendMode.plus;
      canvas.drawRect(
          Rect.fromLTWH(0, 0, gameRef.size.x, gameRef.size.y), paint);
      currentLightIndex++;
    }
  }
}
