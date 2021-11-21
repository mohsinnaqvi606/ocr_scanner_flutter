import 'dart:async';

import 'package:get/get.dart';
import 'package:ocr_scanner_to_browser/ocr_scanner/ocr_scanner_view.dart';

class SplashViewModel extends GetxController {

  @override
  void onReady() {
    super.onReady();
    startTime();
  }

  startTime() async {
    Timer(const Duration(seconds: 3), loadNextScreen);
  }

  loadNextScreen() {
    Get.off(() => OcrScannerView());
  }
}
