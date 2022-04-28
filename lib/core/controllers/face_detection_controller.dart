import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectionController extends GetxController {
  late final FaceDetectorOptions _detectorOptions;
  late final FaceDetector _detector;

  List<Rect> rectFaces = [];

  bool _onDetection = false;

  @override
  void onInit() {
    super.onInit();

    _detectorOptions = const FaceDetectorOptions();
    _detector = FaceDetector(options: _detectorOptions);
  }

  void processInputImage({
    required CameraDescription camera,
    required CameraImage cameraImage,
  }) {
    final _allBytes = WriteBuffer();

    for (Plane plane in cameraImage.planes) {
      _allBytes.putUint8List(plane.bytes);
    }

    final _bytes = _allBytes.done().buffer.asUint8List();
    final _imageSize = Size(
      cameraImage.width.toDouble(),
      cameraImage.height.toDouble(),
    );

    final _imageRotation =
        InputImageRotationValue.fromRawValue(camera.sensorOrientation) ??
            InputImageRotation.rotation0deg;

    final _inputImageFormat =
        InputImageFormatValue.fromRawValue(cameraImage.format.raw) ??
            InputImageFormat.nv21;

    final _planeData = cameraImage.planes.map((plane) {
      return InputImagePlaneMetadata(
        bytesPerRow: plane.bytesPerRow,
        width: plane.width,
        height: plane.height,
      );
    }).toList();

    final _inputImageData = InputImageData(
      size: _imageSize,
      imageRotation: _imageRotation,
      inputImageFormat: _inputImageFormat,
      planeData: _planeData,
    );

    final _inputImage = InputImage.fromBytes(
      bytes: _bytes,
      inputImageData: _inputImageData,
    );

    _performDetection(_inputImage);
  }

  Future<void> _performDetection(InputImage inputImage) async {
    if (_onDetection) return;

    _onDetection = true;

    final _faces = await _detector.processImage(inputImage);

    rectFaces.clear();

    for (Face face in _faces) {
      final _boundingBox = face.boundingBox;
      final _bLeft = _boundingBox.left / 2;
      final _bTop = _boundingBox.top / 2;
      final _bRight = _boundingBox.right / 2;
      final _bBottom = _boundingBox.bottom / 2;

      final _rect = Rect.fromLTRB(_bLeft, _bTop, _bRight, _bBottom);
      rectFaces.add(_rect);
    }

    _onDetection = false;

    update();
  }
}
