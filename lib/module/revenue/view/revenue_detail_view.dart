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
import '../../../helper/helper.dart';
import '../widget/revenue_detail_text.dart';

class RevenueDetailView extends GetView<DetailsRevenueController> {
  const RevenueDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      appBarLabel: 'Sell Details',
      firstActionChild: Obx(
        () =>
            controller.isInvoiceLoading.value
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : InkWell(
                  onTap: () async {
                    final res = await controller.fetchInvoice(
                      invoiceNo: controller.data.billNo ?? '',
                    );
                    if (res.success == true && res.data != null) {
                      AppRoutes.navigateRoutes(
                        routeName: AppRouteName.invoicePrintView,
                        data: res.data,
                      );
                    } else {
                      showSnackBar(error: res.msg ?? somethingWentMessage);
                    }
                  },
                  child: const Icon(CupertinoIcons.printer_fill),
                ),
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
