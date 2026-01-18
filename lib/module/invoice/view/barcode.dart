import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer_library.dart';
import 'package:get/get.dart';
import 'package:inventory/module/invoice/widget/bluetooth_validate_widget.dart';
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
    final controller = Get.put<BardcodeController>(BardcodeController());

    // Print single label

    return CommonAppbar(
      appBarLabel: 'Barcode',
      persistentFooterButtons: [
        Obx(
          () => CommonButton(
            isLoading: controller.isPrintingLoading.value,
            label: "Print Simple",
            onTap: () async {
              bool checkBluetooth =
                  await controller.checkBluetoothConnectivity();
              if (checkBluetooth == true) {
                // await controller.printSimpleLabel(qty: 3);
                await controller.printWithBasicReset(
                  qty: 2,
                  //controller.data['product'].quantity ?? '',
                );
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
        setWidth(width: 10),
        // Obx(
        //   () => CommonButton(
        //     isLoading: controller.isPrintingLoading.value,
        //     label: "Print Basic Reset",
        //     onTap: () async {
        //       bool checkBluetooth =
        //           await controller.checkBluetoothConnectivity();
        //       if (checkBluetooth == true) {
        //         await controller.printWithBasicReset(qty: 3);
        //       } else {
        //         commonBottomSheet(
        //           label: 'Bluetooth Info',
        //           onPressed: () {
        //             Get.back();
        //           },
        //           child: BluetoothValidateWidget(),
        //         );
        //       }
        //     },
        //   ),
        // ),
        setWidth(width: 30),
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
