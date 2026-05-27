import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_progressbar.dart';
import 'package:inventory/module/near_expire_product/widgets/near_expiry_text.dart';
import '../../../common_widget/common_nodatafound.dart';
import '../controller/near_expire_product_controller.dart';

class NearExpireProductView extends GetView<NearExpireProductController> {
  const NearExpireProductView({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      appBarLabel: 'Near Expire Product',
      body: Obx(
        () =>
            controller.isDataloading.value
                ? CommonProgressBar(color: AppColors.blackColor)
                : controller.nearExpProductList.isNotEmpty
                ? ListView.builder(
                  itemCount: controller.nearExpProductList.length,
                  itemBuilder: (context, index) {
                    return NearExpiryText(
                      inventoryModel: controller.nearExpProductList[index],
                    );
                  },
                )
                : CommonNoDataFound(message: 'No near expiry product found'),
      ),
    );
  }
}
