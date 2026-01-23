import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart'
    as printer;
import 'package:get/get.dart';
import 'package:inventory/bluetooth/bluetooth.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/helper.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';

class BardcodeController extends GetxController
    with CacheManager, CommonBluetooth {
  Rx<printer.ReceiptController?> receiptController =
      Rx<printer.ReceiptController?>(null);
  RxBool isPrintingLoading = false.obs;
  RxBool isShareReceiptLoading = false.obs;
  BluetoothCharacteristic? _writeChar;
  BluetoothDevice? _printer;
  var data = Get.arguments;

  @override
  void onInit() {
    checkBluetoothConnectivitys();
    super.onInit();
  }

  void setReceiptController(printer.ReceiptController controller) {
    receiptController.value = controller;
    customMessageOrErrorPrint(
      message: "📏 PAPER SIZE: ${controller.paperSize.paperWidthMM}",
    );
  }

  Future<bool> checkBluetoothConnectivitys() async {
    var res = await checkBluetoothConnectivity();
    return res;
  }

  Future<List<int>> buildLabelBytes({
    required String barcodeNo,
    required int quantity,
  }) async {
    var user = retrieveUserDetail();
    final profile = await CapabilityProfile.load();
    final gen = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    // 1. Data Cleaning
    final barcodeData = barcodeNo.toUpperCase().trim();

    for (int i = 0; i < quantity; i++) {
      bytes += gen.reset();

      // 2. Barcode Optimization

      bytes += gen.barcode(
        Barcode.code128(barcodeData.split('')),
        height: 55,
        width: 3,
        align: PosAlign.center,
      );

      // 3. Text Formatting
      bytes += gen.text(
        user.name ?? 'Hisab Box',
        styles: PosStyles(
          align: PosAlign.center,
          // bold: true
        ),
      );
      bytes += gen.text(
        data['product'].name,
        styles: PosStyles(
          align: PosAlign.center,
          // bold: true
        ),
      );
      bytes += gen.text(
        '${data['product'].flavor} | ${data['product'].weight} | ₹${data['product'].sellingPrice}',
        styles: PosStyles(align: PosAlign.center),
      );

      // 4. Critical: Label Gap Detection
      // Sirf feed(3) ke bajaye ye commands try karein:
      bytes += gen.feed(2);
      // Kuch printers ko GS FF (0x1D 0x0C) command chahiye hoti hai next label pe jane ke liye
      bytes += [0x1D, 0x0C];
    }

    return bytes;
  }

  Future<void> printEscPosBytes(List<int> bytes) async {
    if (_writeChar == null) {
      throw Exception('Printer not connected');
    }

    const int chunkSize = 180;

    for (int i = 0; i < bytes.length; i += chunkSize) {
      final chunk = bytes.sublist(
        i,
        (i + chunkSize > bytes.length) ? bytes.length : i + chunkSize,
      );

      await _writeChar!.write(
        Uint8List.fromList(chunk),
        withoutResponse: _writeChar!.properties.writeWithoutResponse,
      );

      await Future.delayed(const Duration(milliseconds: 40));
    }
  }

  Future<void> connectPrinterWithSavedAddress(String mac) async {
    // 🔥 Direct device from MAC
    _printer = BluetoothDevice.fromId(mac);

    // Connect (will use existing system connection if present)
    await _printer!.connect(license: License.free, autoConnect: false);

    // Discover services
    final services = await _printer!.discoverServices();

    for (final service in services) {
      for (final c in service.characteristics) {
        if (c.properties.write || c.properties.writeWithoutResponse) {
          _writeChar = c;
          return;
        }
      }
    }

    throw Exception('Writable characteristic not found');
  }

  Future<void> printBarcodeLabelsFromSavedPrinter({
    required String barcode,
    required int quantity,
  }) async {
    final String bluetoothAddress = retrievePrinterAddress() ?? '';

    if (bluetoothAddress.isEmpty) {
      throw Exception('No saved printer address');
    }

    // 1️⃣ Connect using saved MAC
    await connectPrinterWithSavedAddress(bluetoothAddress);

    // 2️⃣ Build ESC/POS bytes
    final List<int> bytes = await buildLabelBytes(
      barcodeNo: barcode,
      quantity: quantity,
    );

    // 3️⃣ Print
    await printEscPosBytes(bytes);
  }
}
