import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer_library.dart';
import 'package:get/get.dart';
import '../../../cache_manager/cache_manager.dart';

class InvoiceController extends GetxController with CacheManager {
  RxBool isPrintingLoading = false.obs;
  Rx<ReceiptController?> receiptController = Rx<ReceiptController?>(null);
  var data = Get.arguments;

  @override
  void onInit() {
    checkBluetoothConnectivity();
    super.onInit();
  }

  Future<bool> checkBluetoothConnectivity() async {
    if (await FlutterBluePlus.isSupported == false) {
      return false;
    }
    BluetoothAdapterState state = await FlutterBluePlus.adapterState.first;
    if (state == BluetoothAdapterState.on) {
      return true;
    } else {
      return false;
    }
  }

  void setReceiptController(ReceiptController controller) {
    receiptController.value = controller;
  }
}
