import 'package:inventory/helper/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer_library.dart';
import 'package:get/get.dart';
import 'package:inventory/module/invoice/widget/invoice_printer.dart';
import '../../../common_widget/common_appbar.dart';
import '../../../common_widget/common_bottom_sheet.dart';
import '../../../common_widget/common_button.dart';
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
              try {
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
                  AppLogger.info((qyt).toString());
                  await controller.printBarcodeLabelsFromSavedPrinter(
                    barcode: controller.data['productData']['product'].barcode,
                    quantity: qyt,
                  );
                  showMessage(
                    message:
                        'Barcode printed successfully. Labels: ${qyt < 1 ? 1 : qyt}.',
                  );
                } else {
                  commonBottomSheet(
                    label: 'Bluetooth Info',
                    onPressed: () {
                      Get.back();
                    },
                    child: BluetoothInfoWidget(),
                  );
                }
              } catch (e) {
                AppLogger.error('Barcode print failed', e, 'BarcodeView');
                showSnackBar(error: e.toString());
              } finally {
                controller.isPrintingLoading.value = false;
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
    try {
      String? device = controller.retrievePrinterAddress();

      if (device != null && device.isNotEmpty) {
        var res = await rController.print(address: device, delayTime: 0);
        if (res == true) {
          showSnackBar(error: 'Barcode printed successfully.');
          Get.back();
        } else {
          showMessage(
            message: 'Print failed. Please reconnect printer and try again.',
          );
        }
      } else {
        showMessage(
          message: 'No saved printer found. Please select a printer first.',
        );
        commonBottomSheet(
          label: 'Bluetooth Info',
          onPressed: () {
            Get.back();
          },
          child: BluetoothInfoWidget(),
        );
      }
    } catch (e) {
      AppLogger.error('Barcode printReceipt failed', e, 'BarcodeView');
      showSnackBar(error: e.toString());
    } finally {
      controller.isPrintingLoading.value = false;
    }
  }
}
