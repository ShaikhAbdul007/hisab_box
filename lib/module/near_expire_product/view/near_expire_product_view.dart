import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_progressbar.dart';
import 'package:inventory/module/inventory/model/product_model.dart';
import 'package:inventory/module/inventorylist/model/inventory_model.dart';

import '../../../common_widget/common_nodatafound.dart';
import '../../inventorylist/widget/inventory_list_text.dart';
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
                ? CommonProgressbar(color: AppColors.blackColor)
                : controller.nearExpProductList.isNotEmpty
                ? ListView.builder(
                  itemCount: controller.nearExpProductList.length,
                  itemBuilder: (context, index) {
                    return InventroyListText(
                      inventoryModel: controller.nearExpProductList[index],
                      isInventoryScanSelected: true,
                    );
                  },
                )
                : CommonNodatafound(message: 'No product found'),
      ),
    );
  }
}
