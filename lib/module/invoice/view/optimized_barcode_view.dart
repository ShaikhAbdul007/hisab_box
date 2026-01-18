import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/helper/label_printer_config.dart';
import 'package:inventory/module/invoice/widget/invoice_printer.dart';
import '../controller/bardcode_controller.dart';

/// 🔥 OPTIMIZED BARCODE VIEW FOR 25mm x 50mm LABELS
/// No blank space, perfect fit for label stickers
class OptimizedBarcodeView extends StatelessWidget {
  const OptimizedBarcodeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BardcodeController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('🏷️ Label Printer'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          // Print quantity selector
          Obx(
            () => Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  'Qty: ${controller.printQuantity.value}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔥 LABEL PREVIEW
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: Center(
                child: Container(
                  // 🔥 EXACT LABEL SIZE PREVIEW
                  width:
                      LabelPrinterConfig.labelWidth * 2, // 2x scale for preview
                  height: LabelPrinterConfig.labelHeight * 2,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Transform.scale(
                    scale: 2.0, // Scale up for preview
                    child: BarcodePrinterView(
                      data: controller.data,
                      onInitialized: controller.setReceiptController,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 🔥 CONTROLS
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Quantity selector
                Row(
                  children: [
                    Text(
                      'Print Quantity:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => controller.decreaseQuantity(),
                            icon: Icon(Icons.remove),
                          ),
                          Obx(
                            () => Container(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                '${controller.printQuantity.value}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => controller.increaseQuantity(),
                            icon: Icon(Icons.add),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                // Print buttons
                Row(
                  children: [
                    // Standard print
                    Expanded(
                      child: Obx(
                        () => ElevatedButton.icon(
                          onPressed:
                              controller.isPrintingLoading.value
                                  ? null
                                  : () {
                                    //    controller.printBarcodeLabel(
                                    //   qty: controller.printQuantity.value,
                                    // ),
                                  },
                          icon:
                              controller.isPrintingLoading.value
                                  ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : Icon(Icons.print, color: Colors.white),
                          label: Text(
                            controller.isPrintingLoading.value
                                ? 'Printing...'
                                : 'Print Labels',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 16),

                    // Optimized print
                    Expanded(
                      child: Obx(
                        () => ElevatedButton.icon(
                          onPressed:
                              controller.isPrintingLoading.value
                                  ? null
                                  : () {
                                    //    controller.printBarcodeLabel(
                                    //   qty: controller.printQuantity.value,
                                    // ),
                                  },
                          icon:
                              controller.isPrintingLoading.value
                                  ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : Icon(
                                    Icons.high_quality,
                                    color: Colors.white,
                                  ),
                          label: Text(
                            controller.isPrintingLoading.value
                                ? 'Printing...'
                                : 'Optimized Print',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8),

                // Info text
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue.shade700, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Optimized for 25mm × 50mm label stickers. No blank space between labels.',
                          style: TextStyle(
                            color: Colors.blue.shade800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 🔥 ENHANCED BARCODE CONTROLLER WITH QUANTITY CONTROL
extension BarcodeControllerExtension on BardcodeController {
  RxInt get printQuantity => _printQuantity;
  static final RxInt _printQuantity = 1.obs;

  void increaseQuantity() {
    if (_printQuantity.value < 99) {
      _printQuantity.value++;
    }
  }

  void decreaseQuantity() {
    if (_printQuantity.value > 1) {
      _printQuantity.value--;
    }
  }

  void setQuantity(int qty) {
    _printQuantity.value = qty.clamp(1, 99);
  }
}
