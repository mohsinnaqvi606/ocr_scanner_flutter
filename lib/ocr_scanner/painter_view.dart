import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileCardPainter extends CustomPainter {
  //2
  ProfileCardPainter({required this.color});

  //3
  final Color color;

  //4
  @override
  void paint(Canvas canvas, Size size) {
    //  (x1: 27.72, y1: 317.292)  (x2: 332.28, y2: 550.436)
    //  (left: 99.5, right: 124.5)  (top: 329.30625, bottom: 345.590625)

    // final shapeBounds = Rect.fromLTRB(Get.width * .077, Get.height * .411,
    //     Get.width - (Get.width * .077), Get.height - (Get.height * .287));

    //  (x1: 27.72, y1: 317.292)  (x2: 332.28, y2: 550.436)
    //  (left: 99.5, right: 124.5)  (top: 329.30625, bottom: 345.590625)

    // final shapeBounds = Rect.fromLTRB(99.5, 329.30, 124.5, 345.59);
    //
    // final paint = Paint()..color = color;
    // canvas.drawRect(shapeBounds, paint);
  }

  //5
  @override
  bool shouldRepaint(ProfileCardPainter oldDelegate) {
    return color != oldDelegate.color;
  }
}
