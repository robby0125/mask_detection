import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mask_detection/core/di/injection.dart';
import 'package:mask_detection/ui/pages/detection_page.dart';

void main() {
  init();
  runApp(const MaskDetection());
}

void init() {
  WidgetsFlutterBinding.ensureInitialized();
  Injection.provideInjection();
}

class MaskDetection extends StatelessWidget {
  const MaskDetection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: DetectionPage(),
    );
  }
}
