import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:mask_detection/core/utils/image_converter.dart';
import 'package:tflite/tflite.dart';

class FaceDetectionController extends GetxController {
  late final FaceDetectorOptions _detectorOptions;
  late final FaceDetector _detector;
  final Rx<ui.Image?> _faceImage = Rx(null);

  List<Rect> rectFaces = [];
  List<img.Image> facesData = [];
  List<int> detectionResult = [];

  bool isBackCamera = true;
  bool _onDetection = false;

  ui.Image? get faceImage => _faceImage.value;

  @override
  void onInit() async {
    super.onInit();

    _detectorOptions = const FaceDetectorOptions();
    _detector = FaceDetector(options: _detectorOptions);

    await Tflite.loadModel(
      model: 'assets/model.tflite',
      labels: 'assets/labels.txt',
    );
  }

  @override
  void onClose() async {
    super.onClose();
    await Tflite.close();
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

    _performDetection(
      inputImage: _inputImage,
      cameraImage: cameraImage,
    );
  }

  Future<void> _performDetection({
    required InputImage inputImage,
    required CameraImage cameraImage,
  }) async {
    if (_onDetection || inputImage.bytes == null) return;

    _onDetection = true;

    final _faces = await _detector.processImage(inputImage);

    rectFaces.clear();
    facesData.clear();

    for (Face face in _faces) {
      final _boundingBox = face.boundingBox;
      final _bLeft = _boundingBox.left / 2;
      final _bTop = _boundingBox.top / 2;
      final _bRight = _boundingBox.right / 2;
      final _bBottom = _boundingBox.bottom / 2;

      final _rect = Rect.fromLTRB(_bLeft, _bTop, _bRight, _bBottom);
      rectFaces.add(_rect);

      facesData.add(
        _cropFaceRect(
          cameraImage: cameraImage,
          faceRect: _boundingBox,
        ),
      );
    }

    if (facesData.isNotEmpty) {
      await _classify();
    } else {
      _faceImage.value = null;
    }

    _onDetection = false;

    update();
  }

  img.Image _cropFaceRect({
    required CameraImage cameraImage,
    required Rect faceRect,
  }) {
    final _image = img.copyRotate(
      ImageConverter.convertToImage(cameraImage),
      isBackCamera ? 90 : -90,
    );
    final _faceCropped = img.copyCrop(
      _image,
      faceRect.left.round(),
      faceRect.top.round(),
      faceRect.width.round(),
      faceRect.height.round(),
    );
    final _resized = img.copyResize(
      _faceCropped,
      width: 150,
      height: 150,
    );

    return _resized;
  }

  Uint8List _imageToByteListFloat32({
    required img.Image image,
    required int inputSize,
    required double mean,
    required double std,
  }) {
    var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (var i = 0; i < inputSize; i++) {
      for (var j = 0; j < inputSize; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = (img.getRed(pixel) - mean) / std;
        buffer[pixelIndex++] = (img.getGreen(pixel) - mean) / std;
        buffer[pixelIndex++] = (img.getBlue(pixel) - mean) / std;
      }
    }
    return convertedBytes.buffer.asUint8List();
  }

  Future<void> _classify() async {
    detectionResult.clear();

    for (var face in facesData) {
      final result = await Tflite.runModelOnBinary(
        binary: _imageToByteListFloat32(
          image: face,
          inputSize: 150,
          mean: 0,
          std: 255,
        ),
        numResults: 2,
        threshold: 0,
        asynch: false,
      );
      detectionResult.add(result![0]['index']);
    }
  }
}
