import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mask_detection/core/controllers/face_detection_controller.dart';
import 'package:mask_detection/core/controllers/my_camera_controller.dart';
import 'package:mask_detection/core/states/camera_state.dart';
import 'package:mask_detection/ui/widgets/face_painter.dart';

class DetectionPage extends StatelessWidget {
  DetectionPage({Key? key}) : super(key: key);

  final _myCameraController = Get.find<MyCameraController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        final _cameraState = _myCameraController.cameraState;

        if (_cameraState != CameraState.ready) return Container();

        final _deviceRatio = MediaQuery.of(context).size.aspectRatio;
        final _previewRatio = _myCameraController.aspectRatio;

        var _scale = _previewRatio * _deviceRatio;

        if (_scale < 1) _scale = 1 / _scale;

        return Transform.scale(
          scale: _scale,
          child: Center(
            child: CameraPreview(
              _myCameraController.controller,
              child: GetBuilder<FaceDetectionController>(
                builder: (newController) => Transform.scale(
                  scaleX: _myCameraController.isBackCamera ? 1 : -1,
                  child: CustomPaint(
                    painter: FacePainter(
                      rectFaces: newController.rectFaces,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _myCameraController.switchCamera(),
        child: const Icon(
          Icons.cameraswitch,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
