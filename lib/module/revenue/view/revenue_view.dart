import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:inventory/module/revenue/controller/revenue_controller.dart';

import '../../../common_widget/colors.dart';
import '../../../common_widget/common_appbar.dart';
import '../../../common_widget/common_nodatafound.dart';
import '../../../common_widget/common_progressbar.dart';
import '../widget/revenue_list_text.dart';

class RevenueView extends GetView<RevenueController> {
  const RevenueView({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      appBarLabel: 'Revenue',

      body: Obx(
        () =>
            controller.isRevenueListLoading.value
                ? CommonProgressbar(size: 50, color: AppColors.blackColor)
                : controller.sellsList.isNotEmpty
                ? ListView.builder(
                  itemCount: controller.sellsList.length,
                  itemBuilder: (context, index) {
                    return RevenueListText(
                      revenueModel: controller.sellsList[index],
                    );
                  },
                )
                : CommonNodatafound(message: 'No revenue found'),
      ),
    );
  }
}
