import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:ocr_scanner_to_browser/main.dart';
import 'package:ocr_scanner_to_browser/ocr_scanner/global_variables.dart';

class OcrScannerViewModel extends GetxController with WidgetsBindingObserver {
  RxBool isCameraInitialized = false.obs;
  late CameraController cameraController;
  TextDetector textDetector = GoogleMlKit.vision.textDetector();
  bool isBusy = false;
  RxString text = 'Not Scanned'.obs;
  late BuildContext context;

  setContext(BuildContext context) async {
    this.context = context;
    // await startLiveFeed();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {

    if (state == AppLifecycleState.resumed) {
      startLiveFeed();
    } else if (state == AppLifecycleState.inactive) {
      stopLiveFeed();
    }

  }

  @override
  void onInit() async {
    super.onInit();
    await startLiveFeed();

    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void onReady() {
    super.onReady();
    //  startLiveFeed();
    print('onReady');
  }

  @override
  void onClose() async {
    await stopLiveFeed();
    WidgetsBinding.instance?.removeObserver(this);
    super.onClose();
  }

  Future startLiveFeed() async {
    if (isCameraInitialized.value) return;
    print('startLiveFeed.....');
    final camera = cameras[0];
    cameraController = CameraController(
      camera,
      ResolutionPreset.ultraHigh,
      enableAudio: false,
    );
    cameraController.initialize().then((_) {
      isCameraInitialized.value = true;
      cameraController.startImageStream(processCameraImage);
    });
  }

  Future stopLiveFeed() async {
    isCameraInitialized.value = false;
    await cameraController.stopImageStream();
    await cameraController.dispose();
  }

  Future processCameraImage(CameraImage image) async {
    if (!isCameraInitialized.value) return;
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
        Size(image.width.toDouble(), image.height.toDouble());

    GlobalVariables.absoluteImageSize = imageSize;

    final camera = cameras[0];
    final imageRotation =
        InputImageRotationMethods.fromRawValue(camera.sensorOrientation) ??
            InputImageRotation.Rotation_0deg;

    final inputImageFormat =
        InputImageFormatMethods.fromRawValue(image.format.raw) ??
            InputImageFormat.NV21;

    GlobalVariables.rotation = imageRotation;

    final planeData = image.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    final inputImage =
        InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

    processImage(inputImage);
  }

  Future<void> processImage(InputImage inputImage) async {
    if (!isCameraInitialized.value) return;
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
          if (await checkCornerPoints(block.rect)) {
            isCameraInitialized.value = false;
            isBusy = true;

            String url = 'https://www.google.com/search?q=' +
                recognisedText.blocks.first.text.trim();
            await canLaunch(url)
                ? await launch(url)
                : throw 'Could not launch $url';

            break;
          }
        }
      }

      print('*******************************************************');
    } else {
      isBusy = false;
    }
    isBusy = false;
  }

  Future<bool> checkCornerPoints(Rect rect) async {
    double x1 = Get.width * .077;
    double y1 = Get.height * .31;
    double x2 = Get.width - (Get.width * .077);
    double y2 = (Get.height - (Get.height * .30));

    bool result = false;

    print('(x1: $x1, y1: $y1)  (x2: $x2, y2: $y2)');

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
