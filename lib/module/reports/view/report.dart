import 'package:inventory/responsive_layout/dimension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_bottom_sheet.dart';
import 'package:inventory/common_widget/common_calender.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/textstyle.dart';
import '../controller/report_controller.dart';
import '../widget/download_report_widget.dart';
import '../widget/report_overview_widget.dart';
import '../widget/report_sale_widget.dart';

class ReportView extends GetView<ReportController> {
  const ReportView({super.key});

  @override
  Widget build(BuildContext context) {
    if (isDesktop(context)) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: Text(
            'Business Reports',
            style: CustomTextStyle.customNato(fontSize: 16),
          ),
          actionsPadding: const EdgeInsets.only(right: 20),
          actions: [
            // Calendar filter in app bar
            Obx(
              () => InkWell(
                onTap: () {
                  customDatePicker(
                    context: context,
                    selectedDate: DateTime.now(),
                    controller: controller.salesDate,
                    onDatePicked: () {
                      controller.fetchModeOfPaymentStats();
                      controller.fetchTopSellingProductsChart();
                      controller.fetchTopSellingProducts();
                      controller.fetchSales();
                    },
                  );
                },
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.calendar),
                    const SizedBox(width: 8),
                    Text(
                      controller.salesDate.value,
                      style: CustomTextStyle.customPoppin(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),
            // Download option
            Obx(
              () => controller.reportLabels.isNotEmpty
                  ? InkWell(
                      onTap: () async {
                        commonBottomSheet(
                          label: 'Download Report',
                          onPressed: () {
                            controller.reportDownloadGroupValue.value = (-1);
                            controller.reportDownloadButtonEnable.value = false;
                            Get.back();
                          },
                          child: Obx(
                            () => DownloadReportWidget(
                              isLoading: controller.isExporting.value,
                              reportDownloadOnTap: () async {},
                              reportLabel: controller.reportLabel,
                              groupValue: controller.reportDownloadGroupValue.value,
                              reportDownloadButtonEnable: controller.reportDownloadButtonEnable.value,
                              onChanged: (dv) {
                                controller.reportDownloadButtonEnable.value = false;
                                controller.reportDownloadGroupValue.value = dv ?? 0;
                                controller.reportDownloadButtonEnable.value = true;
                              },
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.download_sharp, size: 18),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
          surfaceTintColor: AppColors.greyColorShade100,
          backgroundColor: AppColors.greyColorShade100,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column 1: Overview
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Performance Overview',
                        style: CustomTextStyle.customPoppin(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.blackColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ReportOverviewWidget(controller: controller),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              
              // Column 2: Sales Charts & Logs
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sales & Payment Analytics',
                        style: CustomTextStyle.customPoppin(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.blackColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ReportSaleWidget(controller: controller),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return CommonAppbar(
      isleadingButtonRequired: false,
      appBarLabel: 'Reports',
      secondActionChild: Obx(
        () => InkWell(
          onTap: () {
            customDatePicker(
              context: context,
              selectedDate: DateTime.now(),
              controller: controller.salesDate,
              onDatePicked: () {
                controller.fetchModeOfPaymentStats();
                controller.fetchTopSellingProductsChart();
                controller.fetchTopSellingProducts();
                controller.fetchSales();
              },
            );
          },
          child: Row(
            children: [
              Icon(CupertinoIcons.calendar),
              setWidth(width: 5),
              Text(
                controller.salesDate.value,
                style: CustomTextStyle.customPoppin(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
      firstActionChild: Obx(
        () =>
            controller.reportLabels.isNotEmpty
                ? InkWell(
                  onTap: () async {
                    commonBottomSheet(
                      label: 'Download Report',
                      onPressed: () {
                        controller.reportDownloadGroupValue.value = (-1);
                        controller.reportDownloadButtonEnable.value = false;
                        Get.back();
                      },
                      child: Obx(
                        () => DownloadReportWidget(
                          isLoading: controller.isExporting.value,
                          reportDownloadOnTap: () async {
                            controller.isExporting.value = true;
                            var resList = [];
                            var date = '';
                          },
                          reportLabel: controller.reportLabel,
                          groupValue: controller.reportDownloadGroupValue.value,
                          reportDownloadButtonEnable:
                              controller.reportDownloadButtonEnable.value,
                          onChanged: (dv) {
                            controller.reportDownloadButtonEnable.value = false;
                            controller.reportDownloadGroupValue.value = dv ?? 0;
                            controller.reportDownloadButtonEnable.value = true;
                          },
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: AllPadding(all: 5).getPadding(),
                    decoration: BoxDecoration(
                      border: Border.all(width: 0.5.w),
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    child: Icon(Icons.download_sharp, size: 18.sp),
                  ),
                )
                : Container(),
      ),
      body: CustomPadding(
        paddingOption: SymmetricPadding(horizontal: 15.0),
        child: Column(
          children: [
            setHeight(height: 10),
            Container(
              height: 40.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: TabBar(
                controller: controller.tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                unselectedLabelStyle: CustomTextStyle.customPoppin(),
                labelStyle: CustomTextStyle.customPoppin(
                  color: AppColors.whiteColor,
                ),
                indicatorPadding:
                    SymmetricPadding(horizontal: 10, vertical: 5).getPadding(),
                dividerHeight: 0.0,
                indicator: BoxDecoration(
                  color: AppColors.blackColor,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                tabs: [Tab(child: Text('Overview')), Tab(child: Text('Sale'))],
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
// Row(
          //   children: [
          //     ,
          //     setWidth(width: 5),
          //     Text('Export', style: CustomTextStyle.customPoppin()),
          //   ],
          // ),