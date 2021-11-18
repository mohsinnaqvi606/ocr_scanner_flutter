import 'dart:developer';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:ocr_scanner_to_browser/main.dart';
import 'package:ocr_scanner_to_browser/ocr_scanner/global_variables.dart';
import 'package:ocr_scanner_to_browser/ocr_scanner/painter_view.dart';
import 'package:ocr_scanner_to_browser/ocr_scanner/second_screen_view.dart';

class OcrScannerViewModel extends GetxController with WidgetsBindingObserver {
  RxBool isCameraInitialized = false.obs;
  CameraController? cameraController;
  TextDetector textDetector = GoogleMlKit.vision.textDetector();
  bool isBusy = false;
  CustomPaint? customPaint;

  @override
  void onReady() {
    super.onReady();

    cameraController = CameraController(
      cameras[0],
      ResolutionPreset.ultraHigh,
      enableAudio: false,
    );

    cameraController?.initialize().then((_) {
      isCameraInitialized.value = true;
    });
  }

  @override
  void onClose() {
    super.onClose();
    cameraController?.dispose();
    //   textDetector.close();
  }

  Future<void> processImage(InputImage inputImage, BuildContext context) async {
    if (isBusy) return;
    isBusy = true;
    final recognisedText = await textDetector.processImage(inputImage);
    print('Found ${recognisedText.blocks.length} textBlocks');
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      print(recognisedText.text);
      print('Total length : ${recognisedText.blocks.length}');

      if (recognisedText.blocks.isNotEmpty && recognisedText.text.length > 1) {
        for (final block in recognisedText.blocks) {
          if (checkCornerPoints(block.rect)) {
            Var.txt = block.text;
            Get.off(() => SecondView(), arguments: {'txt': block.text});
            isBusy = true;
          }
        }

        // Var.txt = recognisedText.text;
        // Navigator.pushAndRemoveUntil(
        //     context,
        //     MaterialPageRoute(builder: (BuildContext context) => SecondView()),
        //     (Route<dynamic> route) => false);
      }

      // for (final block in recognisedText.blocks) {
      //   print(
      //       '**********************************************************************************************************************');
      //   print(
      //       'Top : ${block.rect.top}\nBottom : ${block.rect.bottom}\nleft : ${block.rect.left}\nRight : ${block.rect.right}');
      //
      //   print('Corners : ${block.cornerPoints}');
      //   print(
      //       '#######################################################################################################################');
      // }

      //Check Text and Open browser
      // if (recognisedText.blocks.isNotEmpty) {
      //   if (recognisedText.blocks.first.text.length > 15) {
      //     if (recognisedText.blocks.first.text.startsWith('https://') ||
      //         recognisedText.blocks.first.text.startsWith('http://')) {
      //       await canLaunch(recognisedText.blocks.first.text)
      //           ? await launch(recognisedText.blocks.first.text)
      //           : throw 'Could not launch ${recognisedText.blocks.first.text}';
      //     } else {
      //       String url = 'https://www.google.com/search?q=' +
      //           recognisedText.blocks.first.text.trim();
      //       await canLaunch(url)
      //           ? await launch(url)
      //           : throw 'Could not launch $url';
      //     }
      //   }
      // } else {
      //   log('Noting Found');
      // }

      print('*******************************************************');
    } else {
      customPaint = null;
    }
    isBusy = false;
  }

  bool checkCornerPoints(Rect rect) {
    double x1 = Get.width * .077;
    double y1 = (Get.height * .411) - 70;
    double x2 = Get.width - (Get.width * .077);
    double y2 = (Get.height - (Get.height * .287)) - 28;

    bool result = false;

    //1st point  => top left
    //2nd point  => top right
    //3rd point  => bottom left
    //4th point  => bottom right

    print('(x1: $x1, y1: $y1)  (x2: $x2, y2: $y2)');
    //  print(points);

    final left = translateX(rect.left, GlobalVariables.rotation,
        GlobalVariables.size, GlobalVariables.absoluteImageSize);
    final top = translateY(rect.top, GlobalVariables.rotation,
        GlobalVariables.size, GlobalVariables.absoluteImageSize);
    final right = translateX(rect.right, GlobalVariables.rotation,
        GlobalVariables.size, GlobalVariables.absoluteImageSize);
    final bottom = translateY(rect.bottom, GlobalVariables.rotation,
        GlobalVariables.size, GlobalVariables.absoluteImageSize);

    print('(left: $left, right: $right)  (top: $top, bottom: $bottom)');

    if ((left >= x1 && left <= x2) &&
        (right >= x1 && right <= x2) &&
        (top >= y1 && top <= y2) &&
        (bottom >= y1 && bottom <= y2)) {
      result = true;
    }

    // //First point
    // if (points[0].dx >= x1 &&
    //     points[0].dy >= y1 &&
    //     points[0].dx <= x2 &&
    //     points[0].dy <= y2) {
    //   result = true;
    // } else {
    //   result = false;
    // }
    //
    // //2nd point
    // if (points[1].dx >= x1 &&
    //     points[1].dy >= y1 &&
    //     points[1].dx <= x2 &&
    //     points[1].dy <= y2) {
    //   result = true;
    // } else {
    //   result = false;
    // }
    //
    // //3rd point
    // if (points[2].dx >= x1 &&
    //     points[2].dy >= y1 &&
    //     points[2].dx <= x2 &&
    //     points[2].dy <= y2) {
    //   result = true;
    // } else {
    //   result = false;
    // }
    //
    // //4th point
    // if (points[3].dx >= x1 &&
    //     points[3].dy >= y1 &&
    //     points[3].dx <= x2 &&
    //     points[3].dy <= y2) {
    //   result = true;
    // } else {
    //   result = false;
    // }

    return result;
  }
}

double translateX(
    double x, InputImageRotation rotation, Size size, Size absoluteImageSize) {
  switch (rotation) {
    case InputImageRotation.Rotation_90deg:
      return x *
          size.width /
          (Platform.isIOS ? absoluteImageSize.width : absoluteImageSize.height);
    case InputImageRotation.Rotation_270deg:
      return size.width -
          x *
              size.width /
              (Platform.isIOS
                  ? absoluteImageSize.width
                  : absoluteImageSize.height);
    default:
      return x * size.width / absoluteImageSize.width;
  }
}

double translateY(
    double y, InputImageRotation rotation, Size size, Size absoluteImageSize) {
  switch (rotation) {
    case InputImageRotation.Rotation_90deg:
    case InputImageRotation.Rotation_270deg:
      return y *
          size.height /
          (Platform.isIOS ? absoluteImageSize.height : absoluteImageSize.width);
    default:
      return y * size.height / absoluteImageSize.height;
  }
}
