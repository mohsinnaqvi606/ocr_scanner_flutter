import 'dart:developer';

import 'package:ocr_scanner_to_browser/main.dart';
import 'package:ocr_scanner_to_browser/ocr_scanner/painter_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:ocr_scanner_to_browser/ocr_scanner/camera_view.dart';
import 'package:ocr_scanner_to_browser/ocr_scanner/ocr_scanner_viewmodel.dart';

class OcrScannerView extends StatelessWidget {
  OcrScannerViewModel ocrScannerViewModel = Get.put(OcrScannerViewModel());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => (ocrScannerViewModel.isCameraInitialized.value)
            ? Stack(
                children: [
                  CameraView(
                    controller: ocrScannerViewModel.cameraController!,
                    onImage: (inputImage) {
                      ocrScannerViewModel.processImage(inputImage, context);
                    },
                  ),
                  CustomPaint(
                    size: Size(Get.width, Get.height), //2
                    painter: ProfileCardPainter(color: Colors.green), //3
                  ),
                ],
              )
            : Container(),
      ),
    );
  }
}
