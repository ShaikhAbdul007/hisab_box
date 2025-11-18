import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/routes/routes.dart';
import '../../../common_widget/colors.dart';
import '../../../common_widget/common_appbar.dart';
import '../../../common_widget/common_calender.dart';
import '../../../common_widget/common_nodatafound.dart';
import '../../../common_widget/common_progressbar.dart';
import '../../../common_widget/size.dart';
import '../controller/revenue_controller.dart';
import '../widget/revenue_list_text.dart';

class RevenueView extends GetView<RevenueController> {
  const RevenueView({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      appBarLabel: 'Sells',
      firstActionChild: Obx(
        () => InkWell(
          onTap: () {
            customDatePicker(
              context: context,
              selectedDate: DateTime.now(),
              controller: controller.dayDate,
              onDatePicked: () {
                controller.setSellList();
              },
            );
          },
          child: Row(
            children: [
              Icon(CupertinoIcons.calendar),
              setWidth(width: 5),
              Text(
                controller.dayDate.value,
                style: CustomTextStyle.customPoppin(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Obx(
        () =>
            controller.isRevenueListLoading.value
                ? CommonProgressbar(size: 50, color: AppColors.blackColor)
                : controller.sellsList.isNotEmpty
                ? ListView.builder(
                  itemCount: controller.sellsList.length,
                  itemBuilder: (context, index) {
                    var data = controller.sellsList[index];
                    return InkWell(
                      onTap: () {
                        AppRoutes.navigateRoutes(
                          routeName: AppRouteName.revenueDetailView,
                          data: data.items,
                        );
                      },
                      child: RevenueListText(billModel: data),
                    );
                  },
                )
                : CommonNodatafound(message: 'No revenue found'),
      ),
    );
  }
}
