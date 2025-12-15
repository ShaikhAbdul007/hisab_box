import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_bottom_sheet.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/module/reports/widget/report_option_label.dart';
import '../controller/report_controller.dart';
import '../widget/download_report_widget.dart';
import '../widget/report_overview_widget.dart';
import '../widget/report_sale_widget.dart';

class ReportView extends GetView<ReportController> {
  const ReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      isleadingButtonRequired: false,
      appBarLabel: 'Reports',
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
                            (String, List<String>, Function(dynamic) mapper)
                            getReportlabel = controller.getLabelValue(
                              reportLabelIndex:
                                  controller.reportDownloadGroupValue.value,
                            );
                            var resList = await controller.fetchProductReport(
                              label: controller.reportLabels.value,
                              reportType: getReportlabel.$1,
                            );
                            var date = controller.getDateRange(
                              label: controller.reportLabels.value,
                              customStartDate: '',
                              customEndDate: '',
                            );

                            await controller.exportProductInReport(
                              headers: getReportlabel.$2,
                              mapper: (dynamic) => getReportlabel.$3(dynamic),
                              date: date.$1,
                              date2: date.$2,
                              productReportModel: resList,
                              fileName: getReportlabel.$1,
                            );
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
            ReportOptionContainerLabel(controller: controller),
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