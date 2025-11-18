import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer_library.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/module/invoice/controller/invoice_controller.dart';
import '../../../common_widget/common_button.dart';
import '../../../common_widget/common_dialogue.dart';
import '../../../common_widget/size.dart';
import '../../../routes/routes.dart';
import '../widget/bluetooth_info_widget.dart';
import '../widget/bluetooth_validate_widget.dart';
import '../widget/invoice_printer.dart';

class InvoicePrint extends GetView<InvoiceController> {
  const InvoicePrint({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      appBarLabel: 'Print Invoice',
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            flex: 8,
            child: InvoicePrinterView(
              paymentMethod: controller.data['paymentMethod'],
              onInitialized: (p0) => controller.setReceiptController(p0),
              scannedProductDetails: controller.data['productList'],
            ),
          ),
          setHeight(height: 10),
          Obx(
            () => CommonButton(
              isLoading: controller.isPrintingLoading.value,
              label: "Print",
              onTap: () async {
                bool checkBluetooth =
                    await controller.checkBluetoothConnectivity();
                if (checkBluetooth == true) {
                  if (controller.receiptController.value != null) {
                    await printReceipt(
                      rController: controller.receiptController.value!,
                      context: context,
                      paymentMethod: 'paymentMethod',
                    );
                  }
                } else {
                  commonDialogBox(
                    context: context,
                    child: BluetoothValidateWidget(),
                  );
                }
              },
            ),
          ),
          setHeight(height: 30),
        ],
      ),
    );
  }

  Future<void> printReceipt({
    required ReceiptController rController,
    required BuildContext context,
    required String paymentMethod,
  }) async {
    controller.isPrintingLoading.value = true;
    String? device = controller.retrievePrinterAddress();

    if (device != null) {
      var res = await rController.print(address: device, delayTime: 0);
      if (res == true) {
        controller.isPrintingLoading.value = false;
        AppRoutes.navigateRoutes(routeName: AppRouteName.bottomNavigation);
      }
    } else {
      controller.isPrintingLoading.value = false;
      commonDialogBox(context: context, child: BluetoothInfoWidget());
    }
  }
}
