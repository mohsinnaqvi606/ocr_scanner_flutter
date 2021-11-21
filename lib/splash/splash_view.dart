import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ocr_scanner_to_browser/splash/splash_viewmodel.dart';

class SplashView extends StatelessWidget {
  SplashViewModel splashViewModel = Get.put(SplashViewModel());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              color: Color(0xff622f74),
              gradient: LinearGradient(
                colors: [Color(0xffc471ed), Color(0xff12c2e9)],
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:  <Widget>[
              CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.7),
                radius: 75.0,
                child: const Icon(
                  Icons.aspect_ratio,
                  color: Color(0xff12c2e9),
                  size: 100.0,
                ),
              ),
              const   Padding(
                padding: EdgeInsets.only(top: 15.0),
              ),
              const  Text(
                "OCR Scanner",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 24.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
