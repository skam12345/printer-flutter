import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:charset_converter/charset_converter.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pos_printer_platform/flutter_pos_printer_platform.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class PayController extends GetxController {
  var url = '';
  final TextEditingController price = TextEditingController();
  var type = ['결제', '취소'].obs;
  var selected = '결제'.obs;
  late var selectedValue;

  var defaultPrinterType = PrinterType.usb;
  var _isBle = false;
  var _reconnect = false;
  var _isConnected = false;
  BTStatus _currentStatus = BTStatus.none;
  var printerManager = PrinterManager.instance;
  var devices = <BluetoothPrinter>[];
  late var datas;

  StreamSubscription<PrinterDevice>? _subscription;
  StreamSubscription<USBStatus>? _subscriptionUsbStatus;
  USBStatus _currentUsbStatus = USBStatus.none;
  List<int>? pendingTask;
  BluetoothPrinter? selectedPrinter;

  @override
  void onInit() async {
    super.onInit();
    String jsonString =
        await rootBundle.loadString('assets/json/credit_info.json');
    final jsonResponse = jsonDecode(jsonString);
    url = jsonResponse['credit'];
  }

  _connectStatus() {
    _subscriptionUsbStatus = PrinterManager.instance.stateUSB.listen((status) {
      print(' ----------------- status usb $status ------------------ ');
      _currentUsbStatus = status;
      if (Platform.isAndroid) {
        if (status == USBStatus.connected && pendingTask != null) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            PrinterManager.instance
                .send(type: PrinterType.usb, bytes: pendingTask!);
            pendingTask = null;
          });
        }
      }
    });
  }

  _connectDevice() async {
    _isConnected = false;
    switch (selectedPrinter!.typePrinter) {
      case PrinterType.usb:
        await printerManager.connect(
            type: selectedPrinter!.typePrinter,
            model: UsbPrinterInput(
                name: selectedPrinter!.deviceName,
                productId: selectedPrinter!.productId,
                vendorId: selectedPrinter!.vendorId));
        printReceiveTest();
        _isConnected = true;
        break;
      case PrinterType.bluetooth:
        await printerManager.connect(
            type: selectedPrinter!.typePrinter,
            model: BluetoothPrinterInput(
                name: selectedPrinter!.deviceName,
                address: selectedPrinter!.address!,
                isBle: selectedPrinter!.isBle ?? false,
                autoConnect: _reconnect));
        break;
      case PrinterType.network:
        await printerManager.connect(
            type: selectedPrinter!.typePrinter,
            model: TcpPrinterInput(ipAddress: selectedPrinter!.address!));
        _isConnected = true;
        break;
      default:
    }
  }

  Future printReceiveTest() async {
    List<int> bytes = [];

    // Xprinter XP-N160I
    final profile = await CapabilityProfile.load(name: 'default');
    // PaperSize.mm80 or PaperSize.mm58
    final generator = Generator(PaperSize.mm80, profile);
    bytes += generator.textEncoded(
        await CharsetConverter.encode(
            'EUC-KR', '업체명                               ㈜엔티아이'),
        styles: PosStyles(align: PosAlign.left));
    bytes += generator.textEncoded(
        await CharsetConverter.encode(
            'EUC-KR', '사업자등록번호                     504-81-15358'),
        styles: PosStyles(align: PosAlign.left));
    bytes += generator.textEncoded(
        await CharsetConverter.encode(
            'EUC-KR', '사업장 전화번호                     053-573-8008'),
        styles: PosStyles(align: PosAlign.left));
    bytes += generator.textEncoded(
        await CharsetConverter.encode(
            'EUC-KR', '대표이사                                  김도연'),
        styles: PosStyles(align: PosAlign.left));
    bytes += generator.textEncoded(
        await CharsetConverter.encode(
            'EUC-KR', '주소                      대구광역시 서구 와룡로'),
        styles: PosStyles(align: PosAlign.left));
    bytes += generator.textEncoded(
        await CharsetConverter.encode(
            'EUC-KR', '                           335 1층 스파크 플러스'),
        styles: PosStyles(align: PosAlign.left));
    bytes += generator.textEncoded(
        await CharsetConverter.encode(
            'EUC-KR', '                                     멤버쉽 구매'),
        styles: PosStyles(align: PosAlign.left));
    bytes += generator.textEncoded(
        await CharsetConverter.encode(
            'EUC-KR', '================================================'),
        styles: PosStyles(align: PosAlign.left));
    bytes += generator.textEncoded(
        await CharsetConverter.encode(
            'EUC-KR', '                                            가격'),
        styles: PosStyles(align: PosAlign.left));
    bytes += generator.textEncoded(
        await CharsetConverter.encode(
            'EUC-KR', '프리미엄                                  55,000'),
        styles: PosStyles(align: PosAlign.left));
    bytes += generator.textEncoded(
        await CharsetConverter.encode(
            'EUC-KR', '================================================'),
        styles: PosStyles(align: PosAlign.left));
    bytes += generator.textEncoded(
        await CharsetConverter.encode(
            'EUC-KR', '메인 금액                                 55,000'),
        styles: PosStyles(align: PosAlign.left));
    bytes += generator.textEncoded(
        await CharsetConverter.encode(
            'EUC-KR', '부가세                                     1,800'),
        styles: PosStyles(align: PosAlign.left));
    bytes += generator.textEncoded(
        await CharsetConverter.encode(
            'EUC-KR', '총금액                                    55,000'),
        styles: PosStyles(align: PosAlign.left));
    bytes += generator.textEncoded(
        await CharsetConverter.encode(
            'EUC-KR', '================================================'),
        styles: PosStyles(align: PosAlign.left));
    bytes += generator.textEncoded(
        await CharsetConverter.encode(
            'EUC-KR', '신용카드                                  55,000'),
        styles: PosStyles(align: PosAlign.left));
    bytes += generator.textEncoded(
        await CharsetConverter.encode(
            'EUC-KR', '================================================'),
        styles: PosStyles(align: PosAlign.left));
    bytes += generator.text('                                                ',
        styles: PosStyles(align: PosAlign.left));
    bytes += generator.text('                                                ',
        styles: PosStyles(align: PosAlign.left));
    bytes += generator.text('                                                ',
        styles: PosStyles(align: PosAlign.left));
    bytes += generator.textEncoded(
        await CharsetConverter.encode('EUC-KR', '이용해 주셔서 감사합니다.'),
        styles: PosStyles(align: PosAlign.center));
    bytes += generator.text('                                                ',
        styles: PosStyles(align: PosAlign.left));
    bytes += generator.text('                                                ',
        styles: PosStyles(align: PosAlign.left));
    bytes += generator.text('                                                ',
        styles: PosStyles(align: PosAlign.left));
    _printEscPos(bytes, generator);
  }

  void _printEscPos(List<int> bytes, Generator generator) async {
    if (selectedPrinter == null) return;
    var bluetoothPrinter = selectedPrinter!;

    switch (bluetoothPrinter.typePrinter) {
      case PrinterType.usb:
        bytes += generator.feed(2);
        bytes += generator.cut();
        await printerManager.connect(
            type: bluetoothPrinter.typePrinter,
            model: UsbPrinterInput(
                name: bluetoothPrinter.deviceName,
                productId: bluetoothPrinter.productId,
                vendorId: bluetoothPrinter.vendorId));
        pendingTask = null;
        break;
      case PrinterType.bluetooth:
        bytes += generator.cut();
        await printerManager.connect(
            type: bluetoothPrinter.typePrinter,
            model: BluetoothPrinterInput(
                name: bluetoothPrinter.deviceName,
                address: bluetoothPrinter.address!,
                isBle: bluetoothPrinter.isBle ?? false,
                autoConnect: _reconnect));
        pendingTask = null;
        if (Platform.isAndroid) pendingTask = bytes;
        break;
      case PrinterType.network:
        bytes += generator.feed(2);
        bytes += generator.cut();
        await printerManager.connect(
            type: bluetoothPrinter.typePrinter,
            model: TcpPrinterInput(ipAddress: bluetoothPrinter.address!));
        break;
      default:
    }
    if (bluetoothPrinter.typePrinter == PrinterType.bluetooth &&
        Platform.isAndroid) {
      if (_currentStatus == BTStatus.connected) {
        printerManager.send(type: bluetoothPrinter.typePrinter, bytes: bytes);
        pendingTask = null;
      }
    } else {
      printerManager.send(
        type: bluetoothPrinter.typePrinter,
        bytes: bytes,
      );
    }
  }

  void scan() {
    var index = 0;
    devices.clear();
    _subscription = printerManager
        .discovery(type: defaultPrinterType, isBle: _isBle)
        .listen((device) {
      devices.add(BluetoothPrinter(
        deviceName: device.name,
        address: device.address,
        isBle: _isBle,
        vendorId: device.vendorId,
        productId: device.productId,
        typePrinter: defaultPrinterType,
      ));
      if (device.name == 'SAM4S GCUBE-102') {
        print(index);
        selectedPrinter = devices[index];
        _connectDevice();
      }
      index += 1;
    });
  }

  void payRequestCredit() async {
    String urls = (url.toString() +
            selectedValue +
            '^^${price.text}^^^^^^^^^60^A^^^^^^^^^^^^^^^^^^^^^^^^')
        .toString();
    var response = await http.get(Uri.parse(urls));
    var result = jsonDecode(utf8
        .decode(response.bodyBytes)
        .replaceAll('jsonp12345678983543344(', '')
        .replaceAll(')', '')
        .replaceAll("'", "\""));
    datas = result;
  }

  static PayController get to => Get.find<PayController>();
}

class BluetoothPrinter {
  int? id;
  String? deviceName;
  String? address;
  String? port;
  String? vendorId;
  String? productId;
  bool? isBle;

  PrinterType typePrinter;
  bool? state;

  BluetoothPrinter(
      {this.deviceName,
      this.address,
      this.port,
      this.state,
      this.vendorId,
      this.productId,
      this.typePrinter = PrinterType.bluetooth,
      this.isBle = false});
}
