import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer_library.dart';
import 'package:get/get.dart';
import 'package:inventory/module/invoice/widget/invoice_printer.dart';
import 'package:smart_printer_flutter/smart_printer_flutter.dart';
import '../../../common_widget/common_appbar.dart';
import '../../../common_widget/common_bottom_sheet.dart';
import '../../../common_widget/common_button.dart';
import '../../../common_widget/size.dart';
import '../controller/bardcode_controller.dart';
import '../widget/bluetooth_info_widget.dart';
import '../widget/bluetooth_validate_widget.dart';

class BarcodeView extends GetView<BardcodeController> {
  const BarcodeView({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      appBarLabel: 'Barcode',
      persistentFooterButtons: [
        Obx(
          () => CommonButton(
            //   width: 180,
            isLoading: controller.isPrintingLoading.value,
            label: "Print",
            onTap: () async {
              bool checkBluetooth =
                  await controller.checkBluetoothConnectivity();
              if (checkBluetooth == true) {
                // if (controller.receiptController.value != null) {
                //   await printReceipt(
                //     rController: controller.receiptController.value!,
                //     paymentMethod: 'paymentMethod',
                //   );
                // }

                try {
                  final plugin = SmartPrinterFlutter();

                  // STEP 1: Start Scan (VERY IMPORTANT – initializes printerManager)
                  await plugin.startScan();

                  // Wait 1 second for scanner to initialize
                  await Future.delayed(Duration(seconds: 1));

                  // OPTIONAL: Printer status check
                  var status = await plugin.getPrinterStatus();
                  print("Printer Status: $status");

                  // OPTIONAL: Scanning check
                  var scanning = await plugin.isScanning();
                  print("Scanning: $scanning");

                  // STEP 2: Stop scanning BEFORE connecting
                  await plugin.stopScan();

                  // STEP 5: CHECK CONNECTION
                  bool ok = await plugin.isConnected;
                  print("Connected: $ok");

                  if (!ok) {
                    print("Connection failed!");
                    return;
                  }

                  // STEP 6: PRINT
                  await controller.printBarcodeLabel(plugin: plugin, qty: 2);
                } catch (e) {
                  print("PRINT ERROR: $e");
                }

                // 3) PRINT LABELS

                // 4) DISCONNECT
                // await plugin.disconnect();
              } else {
                commonBottomSheet(
                  label: 'Bluetooth Info',
                  onPressed: () {
                    Get.back();
                  },
                  child: BluetoothValidateWidget(),
                );
              }
            },
          ),
        ),
        setWidth(width: 80),
      ],
      body: BarcodePrinterView(
        data: controller.data,
        onInitialized: (p0) {
          print("📏 PAPER SIZE: ${p0.paperSize}");

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
