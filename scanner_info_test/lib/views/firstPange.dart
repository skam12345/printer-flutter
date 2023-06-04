import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scanner_info_test/controller/firstController.dart';
import 'package:scanner_info_test/views/mainPage.dart';

class FirstPage extends StatelessWidget {
  final FirstController controller = Get.put(FirstController());
  FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Container(
      width: width,
      height: height,
      child: Column(
        children: [
          SizedBox(
            width: width * 0.12,
            height: height * 0.08,
            child: ElevatedButton(
              onPressed: () {
                Get.to(MainPage());
              },
              child: Text('다음 화면'),
            ),
          )
        ],
      ),
    ));
  }
}
