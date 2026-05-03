import 'package:flutter/widgets.dart';
import 'package:get/state_manager.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/helper/shop_type.dart';
import '../controller/generate_barcode_controller.dart';
import '../widget/generate_barcode.dart';

class GenerateBarcode extends GetView<GenerateBarcodeController> {
  const GenerateBarcode({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      backgroundColor: AppColors.whiteColor,
      appBarLabel:
          controller.shopTypeEnum == ShopType.clothingShop
              ? 'Add Clothing Product'
              : 'Add Product',
      body: GenerateBarcodeComponent(controller: controller),
    );
  }
}
