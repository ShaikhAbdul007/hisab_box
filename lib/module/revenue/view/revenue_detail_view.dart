import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import '../widget/revenue_detail_text.dart';

class RevenueDetailView extends StatelessWidget {
  const RevenueDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    var data = Get.arguments;
    return CommonAppbar(
      appBarLabel: 'Sell Details',
      firstActionChild: Icon(CupertinoIcons.printer_fill),
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          return RevenueDetailList(revenueModel: data[index]);
        },
      ),
    );
  }
}
