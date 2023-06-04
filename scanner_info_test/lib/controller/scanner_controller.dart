import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:serial_port_win32/serial_port_win32.dart';

class ScannerController extends GetxController {
  late var devicesList;
  TextEditingController controller = TextEditingController();
  var visible = true.obs;

  @override
  void onReady() {
    // TODO: implement onReady
    controller.text = "";
    Timer.periodic(Duration(milliseconds: 500), (timer) {
      if (controller.text != '') {
        print(controller.text);
        timer.cancel();
      }
    });
    super.onReady();
  }

  @override
  void onInit() async {
    super.onInit();
  }
}
