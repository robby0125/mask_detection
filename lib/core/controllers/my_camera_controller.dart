import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:mask_detection/core/controllers/face_detection_controller.dart';
import 'package:mask_detection/core/states/camera_state.dart';

class MyCameraController extends GetxController {
  late final List<CameraDescription> _cameras;
  late CameraController _controller;

  final _faceDetectionController = Get.find<FaceDetectionController>();
  final _cameraState = CameraState.loading.obs;
  var _isBackCamera = true;

  CameraController get controller => _controller;

  CameraState get cameraState => _cameraState.value;

  bool get isBackCamera => _isBackCamera;

  @override
  void onInit() async {
    super.onInit();

    _cameras = await availableCameras();
    _controller = CameraController(_cameras[0], ResolutionPreset.max);

    await _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      await _controller.initialize();
      await _controller.setFocusMode(FocusMode.auto);
      await _controller.startImageStream((image) {
        _faceDetectionController.processInputImage(
          camera: _cameras[_isBackCamera ? 0 : 1],
          cameraImage: image,
        );
      });

      _cameraState.value = CameraState.ready;
    } catch (e) {
      _cameraState.value = CameraState.error;
    }
  }

  Future<void> switchCamera() async {
    _cameraState.value = CameraState.loading;

    await _controller.stopImageStream();
    await _controller.dispose();

    _isBackCamera = !_isBackCamera;
    _controller = CameraController(
      _cameras[_isBackCamera ? 0 : 1],
      ResolutionPreset.max,
    );
    _faceDetectionController.isBackCamera = _isBackCamera;

    await _initCamera();
  }

  double get aspectRatio {
    if (_cameraState.value != CameraState.ready) return 0;

    return _controller.value.aspectRatio;
  }
}
