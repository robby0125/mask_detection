import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mask_detection/core/controllers/my_camera_controller.dart';
import 'package:mask_detection/core/states/camera_state.dart';

class DetectionPage extends StatelessWidget {
  DetectionPage({Key? key}) : super(key: key);

  final _myCameraController = Get.find<MyCameraController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final _cameraState = _myCameraController.cameraState;

        switch (_cameraState) {
          case CameraState.ready:
            final _deviceRatio = MediaQuery.of(context).size.aspectRatio;
            final _previewRatio = _myCameraController.aspectRatio;

            var scale = _previewRatio * _deviceRatio;

            if (scale < 1) scale = 1 / scale;

            return Stack(
              children: [
                Transform.scale(
                  scale: scale,
                  child: Center(
                    child: CameraPreview(_myCameraController.controller),
                  ),
                ),

              ],
            );

          case CameraState.error:
            return const Center(
              child: Text(
                'Something Wrong!',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            );

          default:
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading Camera...'),
                ],
              ),
            );
        }
      }),
    );
  }
}
