import 'package:inventory/helper/logger.dart';
import 'package:flutter/cupertino.dart';
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
import '../../../routes/route_name.dart';
import '../../../routes/routes.dart';

class BarcodeView extends GetView<BardcodeController> {
  const BarcodeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Print single label

    return CommonAppbar(
      appBarLabel: 'Barcode',
      // ── Design button — opens Barcode Label Designer ──────────────────────
      firstActionChild: IconButton(
        tooltip: 'Customize Label',
        icon: const Icon(CupertinoIcons.slider_horizontal_3),
        onPressed: () async {
          await AppRoutes.futureNavigationToRoute(
            routeName: AppRouteName.barcodeLabelDesigner,
          );
          // Force BarcodePrinterView to rebuild with new layout
          controller.layoutRefreshKey.value++;
        },
      ),
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
                  final int qty =
                      rawQty is num
                          ? rawQty.toInt()
                          : double.tryParse('$rawQty')?.toInt() ??
                              int.tryParse('$rawQty') ??
                              1;
                  await controller.printBarcodeLabelsFromSavedPrinter(
                    barcode: controller.data['productData']['product'].barcode,
                    quantity: qty < 1 ? 1 : qty,
                  );
                  showMessage(
                    message:
                        'Barcode printed successfully. Labels: ${qty < 1 ? 1 : qty}.',
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
      body: Obx(() {
        // layoutRefreshKey.value read karne se Obx rebuild trigger hota hai
        final _ = controller.layoutRefreshKey.value;
        return Container(
          color: Colors.grey.shade100,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(40), // Give room for scale
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Transform.scale(
                  scale: 1.8,
                  alignment: Alignment.center,
                  child: BarcodePrinterView(
                    data: controller.data,
                    onInitialized: (p0) {
                      customMessageOrErrorPrint(
                        message: "📏 PAPER SIZE: ${p0.paperSize}",
                      );
                      controller.setReceiptController(p0);
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Future<void> printReceipt({
    required ReceiptController rController,
    required String paymentMethod,
    int quantity = 1,
  }) async {
    controller.isPrintingLoading.value = true;
    try {
      String? device = controller.retrievePrinterAddress();

      if (device != null && device.isNotEmpty) {
        bool allPrinted = true;
        for (int i = 0; i < quantity; i++) {
          bool printed = false;
          for (int attempt = 0; attempt < 2; attempt++) {
            final res = await rController.print(address: device, delayTime: 120);
            if (res == true) {
              printed = true;
              break;
            }
            await Future.delayed(const Duration(milliseconds: 350));
          }
          if (!printed) {
            allPrinted = false;
            break;
          }
          if (i < quantity - 1) {
            await Future.delayed(const Duration(milliseconds: 550));
          }
        }

        if (allPrinted) {
          showSnackBar(error: 'Barcode printed successfully. Labels: $quantity');
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
