import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ocr_scanner_to_browser/main.dart';
import 'package:ocr_scanner_to_browser/ocr_scanner/ocr_scanner_view.dart';

class SecondView extends StatelessWidget {
  ViewModel viewModel = Get.put(ViewModel());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanned Text'),
        centerTitle: true,
        actions: [
          InkWell(
            onTap: () {
              Get.off(() => OcrScannerView());
            },
            child: const Icon(
              Icons.ad_units_outlined,
              size: 30,
            ),
          ),
          const SizedBox(
            width: 5,
          )
        ],
      ),
      body: Center(
          child: Obx(
        () => Text(
          viewModel.txt.value,
          style: const TextStyle(color: Colors.red, fontSize: 17),
        ),
      )),
    );
  }
}

class ViewModel extends GetxController {
  RxString txt = ''.obs;

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();

    txt.value = Var.txt;
    print('Second Screen => ${txt.value}');
    Var.txt = '';
  }
}
