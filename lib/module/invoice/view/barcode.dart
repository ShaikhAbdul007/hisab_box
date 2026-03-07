import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer_library.dart';
import 'package:get/get.dart';
import 'package:inventory/module/invoice/widget/invoice_printer.dart';
import '../../../common_widget/common_appbar.dart';
import '../../../common_widget/common_bottom_sheet.dart';
import '../../../common_widget/common_button.dart';
import '../../../common_widget/size.dart';
import '../../../helper/helper.dart';
import '../controller/bardcode_controller.dart';
import '../widget/bluetooth_info_widget.dart';

class BarcodeView extends GetView<BardcodeController> {
  const BarcodeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Print single label

    return CommonAppbar(
      appBarLabel: 'Barcode',
      persistentFooterButtons: [
        Obx(
          () => CommonButton(
            isLoading: controller.isPrintingLoading.value,
            label: "Print Barcode",
            onTap: () async {
              controller.isPrintingLoading.value = true;
              String bluetoothAddress =
                  controller.retrievePrinterAddress() ?? '';
              bool checkBluetooth =
                  await controller.checkBluetoothConnectivity();
              if (checkBluetooth == true && bluetoothAddress.isNotEmpty) {
                final dynamic rawQty = controller.data['qyt'];
                final int qyt =
                    rawQty is num
                        ? rawQty.toInt()
                        : double.tryParse('$rawQty')?.toInt() ??
                            int.tryParse('$rawQty') ??
                            1;
                print(qyt);
                await controller.printBarcodeLabelsFromSavedPrinter(
                  barcode: controller.data['productData']['product'].barcode,
                  quantity: qyt,
                );
                controller.isPrintingLoading.value = false;
              } else {
                controller.isPrintingLoading.value = false;
                commonBottomSheet(
                  label: 'Bluetooth Info',
                  onPressed: () {
                    Get.back();
                  },
                  child: BluetoothInfoWidget(),
                );
              }
            },
          ),
        ),
        Container(width: 50),
      ],
      body: BarcodePrinterView(
        data: controller.data,
        onInitialized: (p0) {
          customMessageOrErrorPrint(message: "📏 PAPER SIZE: ${p0.paperSize}");
          controller.setReceiptController(p0);
        },
      ),
    );
  }

  Future<void> printReceipt({
    required ReceiptController rController,
    required String paymentMethod,
  }) async {
    controller.isPrintingLoading.value = true;
    String? device = controller.retrievePrinterAddress();

    if (device != null) {
      var res = await rController.print(address: device, delayTime: 0);
      if (res == true) {
        controller.isPrintingLoading.value = false;
        Get.back();
        // AppRoutes.navigateRoutes(routeName: AppRouteName.bottomNavigation);
      }
    } else {
      controller.isPrintingLoading.value = false;
      commonBottomSheet(
        label: 'Bluetooth Info',
        onPressed: () {
          Get.back();
        },
        child: BluetoothInfoWidget(),
      );
    }
  }
}
