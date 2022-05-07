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

  List<int> encodeNumber(double value) {
    // each number is a float that uses three bytes
    // x - increment between 0 and 255
    // y - increment between 0 and 255
    // z - the remainder between 0 and 255
    // so the resulting number is (x * 256) + (y * 256) + z
    final valueInt = (value * 256.0).toInt();
    final increment = valueInt ~/ 256;
    final remainder = valueInt - (increment * 256);
    final x = increment > 255 ? 255 : increment;
    final y = increment - x;
    if (y > 255) {
      throw Exception('y is too large');
    }
    final z = remainder;
    return [x, y, z];
  }

  // cell is 4 bytes
  void writeNumber(ByteData data, int cellIndex, double value) {
    var encoded = encodeNumber(value);
    var byteOffset = cellIndex * 4;
    data.setUint8(byteOffset, encoded[0]);
    data.setUint8(byteOffset + 1, encoded[1]);
    data.setUint8(byteOffset + 2, encoded[2]);
  }

  void generateDataImage(void Function(Image) callback) {
    var width = 1024;
    var height = 1024;
    ByteData bytes = ByteData(width * height * 4);

    // write data to the texture
    var lightState = gameRef.lightState;
    var obscurerCount = lightState.boxes.length;
    // write count to the texture
    writeNumber(bytes, 0, obscurerCount.toDouble());
    // write obscurer data to the texture
    for (int i = 0; i < obscurerCount; i++) {
      var box = lightState.boxes[i];
      var offsetIndex = i * 4 + 1;
      writeNumber(bytes, offsetIndex, box!.position.x);
      writeNumber(bytes, offsetIndex + 1, box.position.y);
      writeNumber(bytes, offsetIndex + 2, box.size.x);
      writeNumber(bytes, offsetIndex + 3, box.size.y);
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
