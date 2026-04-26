import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_nodatafound.dart';
import 'package:inventory/module/sell/controller/sell_controller.dart';
import '../../../common_widget/common_calender.dart';
import '../../../common_widget/common_progressbar.dart';
import '../../../common_widget/size.dart';
import '../widget/selling_list_text.dart';

class SellView extends GetView<SellController> {
  const SellView({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      appBarLabel: 'Sell',
      firstActionChild: Obx(
        () => InkWell(
          onTap: () {
            customDatePicker(
              context: context,
              selectedDate: DateTime.now(),
              controller: controller.dayDates,
              onDatePicked: () {
                controller.fetchSales(todaysDate: controller.dayDates.value);
              },
            );
          },
          child: Row(
            children: [
              Text(controller.dayDates.value),
              setWidth(width: 5),
              Icon(CupertinoIcons.calendar),
            ],
          ),
        ),
      ),
      body: Obx(
        () =>
            controller.isSellListLoading.value
                ? CommonProgressBar(size: 50, color: AppColors.blackColor)
                : controller.sellsList.isNotEmpty
                ? ListView.builder(
                  itemCount: controller.sellsList.length,
                  itemBuilder: (context, index) {
                    return SellingListText(
                      saleModel: controller.sellsList[index],
                    );
                  },
                )
                : CommonNoDataFound(message: 'No sale found'),
      ),
    );
  }
}
