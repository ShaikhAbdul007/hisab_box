import 'package:flutter/widgets.dart';
import 'package:get/state_manager.dart';
import 'package:inventory/common_widget/common_appbar.dart';

import '../controller/generate_barcode_controller.dart';
import '../widget/generate_barcode.dart';

class GenerateBarcode extends GetView<GenerateBarcodeController> {
  const GenerateBarcode({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      appBarLabel: 'Generate Barcode',
      body: GenerateBarcodeComponent(controller: controller),
    );
  }
}
