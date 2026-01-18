import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/module/invoice/controller/reliable_barcode_controller.dart';
import 'package:inventory/module/invoice/widget/bluetooth_validate_widget.dart';
import 'package:inventory/module/invoice/widget/invoice_printer.dart';
import '../../../common_widget/common_appbar.dart';
import '../../../common_widget/common_bottom_sheet.dart';
import '../../../common_widget/common_button.dart';
import '../../../common_widget/size.dart';
import '../../../helper/helper.dart';
import '../widget/bluetooth_info_widget.dart';

class ReliableBarcodeView extends GetView<ReliableBarcodeController> {
  const ReliableBarcodeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put<ReliableBarcodeController>(
      ReliableBarcodeController(),
    );

    return CommonAppbar(
      appBarLabel: '🔥 Reliable Barcode Printer',
      persistentFooterButtons: [
        // 🔥 RELIABLE PRINT BUTTON
        // Expanded(
        //   child: Obx(
        //     () => CommonButton(
        //       isLoading: controller.isPrintingLoading.value,
        //       label: "🚀 Reliable Print",
        //       onTap: () async {
        //         bool checkBluetooth =
        //             await controller.checkBluetoothConnectivity();
        //         if (checkBluetooth == true) {
        //           await controller.printReliableLabel(qty: 3);
        //         } else {
        //           commonBottomSheet(
        //             label: 'Bluetooth Info',
        //             onPressed: () {
        //               Get.back();
        //             },
        //             child: BluetoothValidateWidget(),
        //           );
        //         }
        //       },
        //     ),
        //   ),
        // ),
        setWidth(width: 8),

        // // 🔥 ULTRA SIMPLE PRINT BUTTON
        Expanded(
          child: Obx(
            () => CommonButton(
              isLoading: controller.isPrintingLoading.value,
              label: "⚡ Ultra Simple",
              onTap: () async {
                bool checkBluetooth =
                    await controller.checkBluetoothConnectivity();
                if (checkBluetooth == true) {
                  await controller.printUltraSimple(
                    qty: controller.data['product'].quantity,
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
        ),
        // setWidth(width: 8),

        // // 🔥 DIAGNOSTIC TEST BUTTON
        // Expanded(
        //   child: Obx(
        //     () => CommonButton(
        //       isLoading: controller.isPrintingLoading.value,
        //       label: "🔍 Test",
        //       onTap: () async {
        //         bool checkBluetooth =
        //             await controller.checkBluetoothConnectivity();
        //         if (checkBluetooth == true) {
        //           await controller.printDiagnosticTest();
        //         } else {
        //           commonBottomSheet(
        //             label: 'Bluetooth Info',
        //             onPressed: () {
        //               Get.back();
        //             },
        //             child: BluetoothValidateWidget(),
        //           );
        //         }
        //       },
        //     ),
        //   ),
        // ),
      ],
      body: Column(
        children: [
          // 🔥 RELIABILITY INFO CARD
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    setWidth(width: 8),
                    Text(
                      '🔥 Reliable Printing Methods',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
                setHeight(height: 12),
                _buildInfoRow(
                  '🚀 Reliable Print',
                  'Multi-step process with retry mechanism',
                ),
                _buildInfoRow(
                  '⚡ Ultra Simple',
                  'No commands, maximum compatibility',
                ),
                _buildInfoRow('🔍 Test', 'Diagnostic test to find best method'),
              ],
            ),
          ),

          // 🔥 BARCODE PREVIEW
          Expanded(
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
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade800,
            ),
          ),
          setWidth(width: 8),
          Expanded(
            child: Text(
              description,
              style: TextStyle(fontSize: 13, color: Colors.blue.shade600),
            ),
          ),
        ],
      ),
    );
  }
}
