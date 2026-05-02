import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_nodatafound.dart';
import 'package:inventory/common_widget/common_progressbar.dart';
import 'package:inventory/helper/app_message.dart';
import 'package:inventory/module/revenue/controller/details_revenue_controller.dart';
import 'package:inventory/routes/route_name.dart';
import 'package:inventory/routes/routes.dart';
import '../widget/revenue_detail_text.dart';

class RevenueDetailView extends GetView<DetailsRevenueController> {
  const RevenueDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      appBarLabel: 'Sell Details',
      firstActionChild: InkWell(
        onTap: () async {
          var res = await controller.fetchInvoice(
            invoiceNo: controller.data.billNo,
          );
          if (res.success == success) {
            AppRoutes.navigateRoutes(
              routeName: AppRouteName.invoicePrintView,
              data: res.data,
            );
          }
        },
        child: Icon(CupertinoIcons.printer_fill),
      ),
      body: Obx(
        () =>
            controller.isRevenueListLoading.value
                ? CommonProgressBar(color: AppColors.blackColor)
                : controller.sellDataList.isNotEmpty
                ? ListView.builder(
                  itemCount: controller.sellDataList.length,
                  itemBuilder: (context, index) {
                    return RevenueDetailList(
                      revenueModel: controller.sellDataList[index],
                      date: controller.date.value,
                    );
                  },
                )
                : CommonNoDataFound(message: 'No revenue details found'),
      ),
    );
  }
}
