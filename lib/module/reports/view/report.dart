import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/helper/textstyle.dart';
import '../controller/report_controller.dart';

class ReportView extends GetView<ReportController> {
  const ReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      isleadingButtonRequired: false,
      appBarLabel: 'Reports',
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          children: [
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TabBar(
                controller: controller.tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                unselectedLabelStyle: CustomTextStyle.customPoppin(),
                labelStyle: CustomTextStyle.customPoppin(
                  color: AppColors.whiteColor,
                ),
                indicatorPadding: EdgeInsetsGeometry.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                dividerHeight: 0.0,
                indicator: BoxDecoration(
                  color: AppColors.blackColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                tabs: [Tab(child: Text('OverView')), Tab(child: Text('Sale'))],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: controller.tabController,
                children: [Text('OverView'), Text('Sale')],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
