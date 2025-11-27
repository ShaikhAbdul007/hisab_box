import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer_library.dart';
import 'package:get/get.dart';
import 'package:inventory/bluetooth/bluetooth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../../../cache_manager/cache_manager.dart';

class InvoiceController extends GetxController
    with CacheManager, CommonBluetooth {
  RxBool isPrintingLoading = false.obs;
  RxBool isShareReceiptLoading = false.obs;
  Rx<ReceiptController?> receiptController = Rx<ReceiptController?>(null);
  var data = Get.arguments;

  @override
  void onInit() {
    checkBluetoothConnectivitys();
    super.onInit();
  }

  Future<bool> checkBluetoothConnectivitys() async {
    var res = await checkBluetoothConnectivity();
    return res;
  }

  void setReceiptController(ReceiptController controller) {
    receiptController.value = controller;
  }

  Future<bool> shareReceiptAsPDF() async {
    bool receiptShared = false;
    isShareReceiptLoading.value = true;
    try {
      final exported = receiptController.call();
      if (exported == null) {
        receiptShared = false;
      } else {
        final Uint8List imageBytes = await exported.getImageBytes();
        final pdf = pw.Document();
        final image = pw.MemoryImage(imageBytes);
        pdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.Center(child: pw.Image(image));
            },
          ),
        );
        final dir = await getTemporaryDirectory();
        final path =
            '${dir.path}/invoice_${DateTime.now().millisecondsSinceEpoch}.pdf';

        final file = File(path);
        await file.writeAsBytes(await pdf.save());

        var res = await SharePlus.instance.share(
          ShareParams(text: 'Invoice from Hisab Box', files: [XFile(path)]),
        );
        if (res.status == ShareResultStatus.success) {
          receiptShared = true;
        } else {
          receiptShared = false;
        }
      }
      return receiptShared;
    } catch (e) {
      print("PDF ERROR: $e");
      return false;
    } finally {
      isShareReceiptLoading.value = false;
    }
  }
}
