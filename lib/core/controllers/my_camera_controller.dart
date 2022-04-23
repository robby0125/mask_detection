import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:mask_detection/core/states/camera_state.dart';

class MyCameraController extends GetxController {
  late final List<CameraDescription> _cameras;
  late final CameraController _controller;

  final _cameraState = CameraState.loading.obs;

  CameraController get controller => _controller;

  CameraState get cameraState => _cameraState.value;

  @override
  void onInit() {
    super.onInit();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(_cameras[0], ResolutionPreset.max);

    log(_cameras.toString());

    try {
      await _controller.initialize();
      await _controller.setFocusMode(FocusMode.auto);
      _cameraState.value = CameraState.ready;
    } catch(e) {
      log('Exception: $e');
      _cameraState.value = CameraState.error;
    }
  }

  double get aspectRatio {
    if (_cameraState.value != CameraState.ready) return 0;

    return _controller.value.aspectRatio;
  }
}