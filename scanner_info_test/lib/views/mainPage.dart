import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scanner_info_test/controller/scanner_controller.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ScannerController controller = Get.put(ScannerController());
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        width: width,
        height: height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Visibility(
              visible: controller.visible.value,
              child: SizedBox(
                width: width * 0.5,
                height: height * 0.08,
                child: TextField(
                  controller: controller.controller,
                  cursorColor: Color.fromRGBO(255, 255, 255, 1.0),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                  ),
                  autofocus: true,
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: width * 0.12,
              height: height * 0.08,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                },
                child: Text('확인하기'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
