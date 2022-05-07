import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/image_composition.dart';
import 'package:flutter/rendering.dart';
import 'package:lights/game/components/player.dart';
import 'package:lights/game/game.dart';

class ScreenComponent extends PositionComponent with HasGameRef<LightsGame> {
  Paint shaderPaint = Paint();
  late Image dataImage;

  ScreenComponent();

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
    shaderPaint = generatePaint();
    generateDataImage((image) {
      dataImage = image;
    });
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
        Rect.fromLTWH(0, 0, gameRef.size.x / 2.0, gameRef.size.y / 2.0),
        shaderPaint);
  }

  Vector2 encodeNumber(int value) {
    // each number is a float that uses two bytes
    // x - increment of 256
    // y - the remainder between 0 and 255
    // so the resulting number is (x * 256) + y
    int x = (value / 256).floor();
    int y = (value - x * 256).floor();
    return Vector2(x.toDouble(), y.toDouble());
  }

  // cell is 4 bytes
  void writeNumber(ByteData data, int cellIndex, int value) {
    Vector2 encoded = encodeNumber(value);
    var byteOffset = cellIndex * 4;
    data.setUint8(byteOffset, encoded.x.toInt());
    data.setUint8(byteOffset + 1, encoded.y.toInt());
  }

  void generateDataImage(void Function(Image) callback) {
    var width = 1024;
    var height = 1024;
    ByteData bytes = ByteData(width * height * 4);

    // write data to the texture
    var lightState = gameRef.lightState;
    var obscurerCount = lightState.boxes.length;
    // write count to the texture
    writeNumber(bytes, 0, obscurerCount);
    // write obscurer data to the texture
    for (int i = 0; i < obscurerCount; i++) {
      var box = lightState.boxes[i];
      var offsetIndex = i * 4 + 1;
      writeNumber(bytes, offsetIndex, box!.position.x.toInt());
      writeNumber(bytes, offsetIndex + 1, box.position.y.toInt());
      writeNumber(bytes, offsetIndex + 2, box.size.x.toInt());
      writeNumber(bytes, offsetIndex + 3, box.size.y.toInt());
    }

    return ui.decodeImageFromPixels(
      bytes.buffer.asUint8List(),
      width,
      height,
      ui.PixelFormat.rgba8888,
      callback,
    );
  }

  Paint generatePaint() {
    var uniformFloats = <double>[];
    final resolution = Vector2(gameRef.size.x / 2, gameRef.size.y / 2);
    uniformFloats.add(resolution.x);
    uniformFloats.add(resolution.y);
    // light texture size
    uniformFloats.add(1024.0);
    uniformFloats.add(1024.0);
    // data texture size
    uniformFloats.add(1024.0);
    uniformFloats.add(1024.0);

    final shader = gameRef.shaderProgram.shader(
      floatUniforms: Float32List.fromList(uniformFloats),
      samplerUniforms: <ImageShader>[
        ImageShader(gameRef.lightImage, TileMode.repeated, TileMode.repeated,
            Matrix4.identity().storage),
        ImageShader(dataImage, TileMode.repeated, TileMode.repeated,
            Matrix4.identity().storage),
      ],
    );
    final paint = Paint()..shader = shader;
    return paint;
  }
}
