import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer_library.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_bottom_sheet.dart';
import 'package:inventory/module/invoice/controller/invoice_controller.dart';
import '../../../common_widget/common_button.dart';
import '../../../common_widget/size.dart';
import '../../../helper/helper.dart';
import '../../../helper/logger.dart';
import '../../../routes/route_name.dart';
import '../../../routes/routes.dart';
import '../widget/bluetooth_info_widget.dart';
import '../widget/bluetooth_validate_widget.dart';
import '../widget/invoice_printer.dart';

class InvoicePrint extends GetView<InvoiceController> {
  const InvoicePrint({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      appBarLabel: 'Invoice',
      persistentFooterButtons: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Obx(
              () => CommonButton(
                bgColor: AppColors.deepPurple,
                width: 150,
                isLoading: controller.isShareReceiptLoading.value,
                label: "Share",
                onTap: () async {
                  await controller.shareReceiptAsPDF();
                },
              ),
            ),
            setWidth(width: 10),
            Obx(
              () => CommonButton(
                width: 150,
                isLoading: controller.isPrintingLoading.value,
                label: "Print",
                onTap: () async {
                  try {
                    bool checkBluetooth =
                        await controller.checkBluetoothConnectivitys();
                    if (checkBluetooth == true) {
                      if (controller.receiptController.value != null) {
                        await printReceipt(
                          rController: controller.receiptController.value!,
                          paymentMethod: 'paymentMethod',
                        );
                      } else {
                        showSnackBar(error: 'Printer is not initialized yet');
                      }
                    } else {
                      commonBottomSheet(
                        label: 'Bluetooth Info',
                        onPressed: () {
                          Get.back();
                        },
                        child: BluetoothValidateWidget(),
                      );
                    }
                  } catch (e) {
                    AppLogger.error('Print button flow failed', e, 'Invoice');
                    showSnackBar(error: e.toString());
                  }
                },
              ),
            ),
          ],
        ),
      ],
      body: InvoicePrinterView(
        printInvoiceModel: controller.data,
        paymentMethod: controller.data.payment.type ?? '',
        onInitialized: (p0) => controller.setReceiptController(p0),
      ),
    );
  }

  Future<void> printReceipt({
    required ReceiptController rController,
    required String paymentMethod,
  }) async {
    controller.isPrintingLoading.value = true;
    try {
      final String? device = controller.retrievePrinterAddress();
      if (device == null || device.isEmpty) {
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
        return;
      }
      await Future.delayed(const Duration(milliseconds: 500));
      final res = await rController.print(address: device, delayTime: 0);
      if (res == true) {
        showSnackBar(error: 'Invoice printed successfully.');
        AppRoutes.navigateRoutes(routeName: AppRouteName.bottomNavigation);
      } else {
        showMessage(
          message: 'Print failed. Please reconnect printer and try again.',
        );
      }
    } catch (e) {
      AppLogger.error('Receipt print failed', e, 'Invoice');
      showSnackBar(error: e.toString());
    } finally {
      controller.isPrintingLoading.value = false;
    }
  }
}
