import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/module/revenue/controller/details_revenue_controller.dart';
import 'package:inventory/module/sell/model/print_model.dart';
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
        onTap: () {
          var printModel = PrintInvoiceModel.fromJson(
            controller.sellModels.toJson(),
          );
          AppRoutes.navigateRoutes(
            routeName: AppRouteName.invoicePrintView,
            data: printModel,
          );
        },
        child: Icon(CupertinoIcons.printer_fill),
      ),
      body: ListView.builder(
        itemCount: controller.sellDataList.length,
        itemBuilder: (context, index) {
          return RevenueDetailList(
            revenueModel: controller.sellDataList[index],
          );
        },
      ),
    );
  }
}
