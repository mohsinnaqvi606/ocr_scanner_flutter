import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:ocr_scanner_to_browser/ocr_scanner/ocr_scanner_viewmodel.dart';
import 'package:ocr_scanner_to_browser/ocr_scanner/painter.dart';

class OcrScannerView extends StatelessWidget {

  OcrScannerViewModel ocrScannerViewModel = Get.put(OcrScannerViewModel());

  @override
  Widget build(BuildContext context) {
    ocrScannerViewModel.setContext(context);
    return Scaffold(
      backgroundColor: Colors.primaries[3],
      appBar: AppBar(
        title: const Text('OCR Scanner'),
        centerTitle: true,
      ),
      body: Obx(
        () => (ocrScannerViewModel.isCameraInitialized.value)
            ? Stack(
                children: [
                  Center(
                    child: CameraPreview(
                      ocrScannerViewModel.cameraController,
                      child: Center(
                        child: Container(
                          height: Get.height / 3.3,
                          width: Get.width * 0.85,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 2.5),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : const Center(
                child: CircularProgressIndicator(
                  color: Colors.red,
                ),
              ),
      ),
    );
  }
}
