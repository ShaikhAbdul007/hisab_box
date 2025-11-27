import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/module/reports/widget/report_option_label.dart';
import '../controller/report_controller.dart';
import '../widget/report_overview_widget.dart';
import '../widget/report_sale_widget.dart';

class ReportView extends GetView<ReportController> {
  const ReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      isleadingButtonRequired: false,
      appBarLabel: 'Reports',
      firstActionChild: InkWell(
        onTap: () {
          print('object export');
        },
        child: Container(
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            border: Border.all(width: 0.5),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            children: [
              Icon(Icons.download_sharp, size: 18),
              setWidth(width: 5),
              Text('Export', style: CustomTextStyle.customPoppin()),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          children: [
            ReportOptionContainerLabel(controller: controller),
            setHeight(height: 10),
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
                children: [
                  ReportOverviewWidget(controller: controller),
                  ReportSaleWidget(controller: controller),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
