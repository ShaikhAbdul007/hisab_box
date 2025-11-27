import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer_library.dart';
import 'package:get/get.dart';
import 'package:inventory/bluetooth/bluetooth.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:smart_printer_flutter/smart_printer_flutter.dart';

class BardcodeController extends GetxController
    with CacheManager, CommonBluetooth {
  Rx<ReceiptController?> receiptController = Rx<ReceiptController?>(null);
  RxBool isPrintingLoading = false.obs;
  RxBool isShareReceiptLoading = false.obs;
  var data = Get.arguments;

  @override
  void onInit() {
    checkBluetoothConnectivitys();
    super.onInit();
  }

  void setReceiptController(ReceiptController controller) {
    receiptController.value = controller;
  }

  Future<bool> checkBluetoothConnectivitys() async {
    var res = await checkBluetoothConnectivity();
    return res;
  }

  Future<void> printBarcodeLabel({
    required SmartPrinterFlutter plugin,
    int qty = 1,
  }) async {
    for (int i = 0; i < qty; i++) {
      plugin.posPrintText("===== BARCODE PRINT TEST =====");

      plugin.posPrintBarcode('123456789', type: PBarcodeType.code128);

      plugin.posPrintText("123456789", align: PTextAlign.center);

      plugin.posPrintText("----------------------------------");

      plugin.posPrintText("Centered", align: PTextAlign.center);
      plugin.posPrintText("Right", align: PTextAlign.right);

      plugin.posPrintText("----------------------------------");

      plugin.posPrintText("Bold", attribute: PTextAttribute.bold);

      plugin.posPrintText("\n\n");
    }

    plugin.cutPaper();
  }
}
