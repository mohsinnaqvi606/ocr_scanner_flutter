import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:ocr_scanner_to_browser/main.dart';
import 'package:get/get.dart';

class GlobalVariables {
  static InputImageRotation rotation =
      InputImageRotationMethods.fromRawValue(cameras[0].sensorOrientation) ??
          InputImageRotation.Rotation_0deg;

  static Size size = Size(Get.width, Get.height);

  static Size absoluteImageSize = Size(0, 0);
}
