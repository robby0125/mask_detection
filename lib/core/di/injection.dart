import 'package:get/get.dart';
import 'package:mask_detection/core/controllers/my_camera_controller.dart';

class Injection {
  static void provideInjection() {
    Get.put(MyCameraController());
  }
}