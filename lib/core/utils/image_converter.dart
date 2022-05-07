import 'dart:developer';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:image/image.dart';

abstract class ImageConverter {
  static Image convertToImage(CameraImage image) {
    try {
      if (image.format.group == ImageFormatGroup.yuv420) {
        return _convertYUV420(image);
      } else if (image.format.group == ImageFormatGroup.bgra8888) {
        return _convertBGRA8888(image);
      }
    } catch (e) {
      log('error: $e');
    }

    throw Exception('Image format not supported');
  }

  static Image _convertBGRA8888(CameraImage image) {
    return Image.fromBytes(
      image.width,
      image.height,
      image.planes[0].bytes,
      format: Format.bgra,
    );
  }

  static Image _convertYUV420(CameraImage image) {
    const hexFF = 0xFF000000;

    final _width = image.width;
    final _height = image.height;
    final _img = Image(_width, _height);
    final _uvRowStride = image.planes[1].bytesPerRow;
    final _uvPixelStride = image.planes[1].bytesPerPixel;

    for (int _x = 0; _x < _width; _x++) {
      for (int _y = 0; _y < _height; _y++) {
        final _uvIndex = _uvPixelStride! * (_x / 2).floor() +
            _uvRowStride * (_y / 2).floor();
        final _index = _y * _width + _x;
        final _yp = image.planes[0].bytes[_index];
        final _up = image.planes[1].bytes[_uvIndex];
        final _vp = image.planes[2].bytes[_uvIndex];
        final _r = (_yp + _vp * 1436 / 1024 - 179).round().clamp(0, 255);
        final _g = (_yp - _up * 46549 / 131072 + 44 - _vp * 93604 / 131072 + 91)
            .round()
            .clamp(0, 255);
        final _b = (_yp + _up * 1814 / 1024 - 227).round().clamp(0, 255);

        _img.data[_index] = hexFF | (_b << 16) | (_g << 8) | _r;
      }
    }

    return _img;
  }

  static Future<ui.Image> bytesToImage(Uint8List imgBytes) async {
    final _codec = await ui.instantiateImageCodec(imgBytes);
    final _frame = await _codec.getNextFrame();

    return _frame.image;
  }
}
