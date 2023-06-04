import 'dart:convert';
import 'dart:typed_data';

import 'package:cp949_codec/cp949_codec.dart';
import 'package:flutter/material.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:get/get.dart';
import 'package:pay_printing_info/controller/payController.dart';

class MainPage extends StatelessWidget {
  final PayController controller = Get.put(PayController());
  MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        width: width,
        height: height,
        child: Column(
          children: <Widget>[
            SizedBox(height: height * 0.04),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  '가격',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Line-Seed-KR',
                  ),
                ),
                SizedBox(width: width * 0.04),
                SizedBox(
                  width: width * 0.2,
                  height: height * 0.06,
                  child: TextField(
                    controller: controller.price,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 0.5,
                          color: Colors.black,
                        ),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.normal,
                      fontFamily: 'Line-Seed-KR',
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(width: width * 0.06),
                Text(
                  '결제 유형',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Line-Seed-KR',
                  ),
                ),
                SizedBox(width: width * 0.06),
                Obx(
                  () => SizedBox(
                    width: width * 0.1,
                    height: height * 0.05,
                    child: DropdownButton(
                      value: controller.selected.value,
                      items: controller.type.map(
                        (value) {
                          return DropdownMenuItem(
                            value: value,
                            child: Text(
                              value,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.normal,
                                fontFamily: 'Line-Seed-KR',
                              ),
                            ),
                          );
                        },
                      ).toList(),
                      onChanged: (value) {
                        controller.selected.value = value.toString();
                        controller.selectedValue =
                            value.toString() == '결제' ? 'D1' : 'D4';
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: height * 0.08),
            SizedBox(
              width: width * 0.15,
              height: height * 0.08,
              child: ElevatedButton(
                onPressed: () => controller.payRequestCredit(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  '결제 요청',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Line-Seed-KR',
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: height * 0.05),
            SizedBox(
              width: width * 0.2,
              height: height * 0.08,
              child: ElevatedButton(
                onPressed: () {
                  controller.scan();
                },
                child: Text(
                  '프린터 출력',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Line-Seed-KR',
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: height * 0.04),
            SizedBox(
              width: width * 0.2,
              height: height * 0.08,
              child: ElevatedButton(
                onPressed: () async {
                  final profile = await CapabilityProfile.load(name: 'default');
                  // PaperSize.mm80 or PaperSize.mm58
                  final generator = Generator(PaperSize.mm80, profile);
                  List<int> bytes = [];

                  bytes += generator
                      .textEncoded(Uint8List.fromList(utf8.encode('안녕하세요')));
                },
                child: Text(
                  '테스트',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Line-Seed-KR',
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
