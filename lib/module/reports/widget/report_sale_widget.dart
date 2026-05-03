import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/common_progressbar.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/textstyle.dart';
import '../../../common_widget/colors.dart';
import '../../../common_widget/common_nodatafound.dart';
import '../../revenue/widget/revenue_list_text.dart';
import '../controller/report_controller.dart';
import '../widget/report_common_continer.dart';
import '../widget/report_overview_widget.dart';

class ReportSaleWidget extends StatelessWidget {
  final ReportController controller;
  const ReportSaleWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Total Revenue — reactive
        Obx(
          () => ReportOverViewContainer(
            width: 500,
            label: 'Total Revenue',
            labelValue: controller.totalRevenue.value.toStringAsFixed(2),
          ),
        ),
        // Sales list
        Expanded(
          child: ReportCommonContainer(
            height: 500,
            width: 500,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Transactions',
                  style: CustomTextStyle.customMontserrat(
                    fontSize: 17,
                    letterSpacing: 0.5,
                  ),
                ),
                setHeight(height: 10),
                Expanded(
                  child: Obx(() {
                    if (controller.isSalesLoading.value) {
                      return const Center(
                        child: CommonProgressBar(
                          color: AppColors.blackColor,
                          size: 30,
                        ),
                      );
                    }
                    if (controller.sellsList.isEmpty) {
                      return CommonNoDataFound(message: 'No sell found');
                    }
                    return ListView.builder(
                      itemCount: controller.sellsList.length,
                      itemBuilder: (context, index) {
                        return RevenueListText(
                          sellItemData: controller.sellsList[index],
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
