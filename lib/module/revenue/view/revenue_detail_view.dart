import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/module/revenue/model/revenue_model.dart';
import 'package:inventory/module/sell/model/print_model.dart';
import 'package:inventory/routes/route_name.dart';
import 'package:inventory/routes/routes.dart';
import '../widget/revenue_detail_text.dart';

class RevenueDetailView extends StatelessWidget {
  const RevenueDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    var data = Get.arguments;
    return CommonAppbar(
      appBarLabel: 'Sell Details',
      firstActionChild: InkWell(
        onTap: () {
          SellsModel sellModels = data;
          var printModel = PrintInvoiceModel.fromJson(sellModels.toJson());
          AppRoutes.navigateRoutes(
            routeName: AppRouteName.invoicePrintView,
            data: printModel,
          );
        },
        child: Icon(CupertinoIcons.printer_fill),
      ),
      body: ListView.builder(
        itemCount: data.items.length,
        itemBuilder: (context, index) {
          return RevenueDetailList(revenueModel: data.items[index]);
        },
      ),
    );
  }
}
