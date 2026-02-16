import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/module/reports/widget/report_common_continer.dart';

import '../../../common_widget/colors.dart';
import '../../../common_widget/common_nodatafound.dart';
import '../../../common_widget/size.dart';
import '../../../helper/textstyle.dart';
import '../controller/report_controller.dart';

class ReportOverviewWidget extends StatelessWidget {
  final ReportController controller;
  const ReportOverviewWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ReportOverViewContainer(
                  label: 'Cash',
                  labelValue: controller.totalCash.value.toStringAsFixed(2),
                ),
              ),
              Expanded(
                child: ReportOverViewContainer(
                  label: 'Upi',
                  labelValue: controller.totalUpi.value.toStringAsFixed(2),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: ReportOverViewContainer(
                  label: 'Credit',
                  labelValue: controller.totalCredit.value.toStringAsFixed(2),
                ),
              ),
              Expanded(
                child: ReportOverViewContainer(
                  label: 'Card Machine',
                  labelValue: controller.totalCard.value.toStringAsFixed(2),
                ),
              ),
            ],
          ),
          ReportCommonContiner(
            padding: SymmetricPadding(horizontal: 10, vertical: 5).getPadding(),
            height: 200,
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Sale Trends',
                    style: CustomTextStyle.customMontserrat(
                      fontSize: 17,
                      letterSpacing: 0.5,
                    ),
                  ),
                  controller.reportTopChart.isEmpty
                      ? CommonNodatafound(message: 'No trend found')
                      : AspectRatio(
                        aspectRatio: 14 / 7,
                        child: CustomPadding(
                          paddingOption: AllPadding(all: 12),
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              barTouchData: BarTouchData(
                                enabled: true,
                                touchTooltipData: BarTouchTooltipData(
                                  tooltipBorderRadius: BorderRadius.circular(
                                    8.r,
                                  ),
                                  tooltipPadding:
                                      AllPadding(all: 10).getPadding(),
                                  getTooltipItem: (
                                    group,
                                    groupIndex,
                                    rod,
                                    rodIndex,
                                  ) {
                                    final data =
                                        controller.reportTopChart[groupIndex];
                                    return BarTooltipItem(
                                      "${data.name}\n",
                                      CustomTextStyle.customMontserrat(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),

                                      children: [
                                        TextSpan(
                                          text: "Qty: ${data.totalQty}",
                                          style:
                                              CustomTextStyle.customMontserrat(
                                                color: Colors.white,
                                              ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              gridData: FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                              titlesData: FlTitlesData(
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    // reservedSize: 18,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        value.toInt().toString(),
                                        style: CustomTextStyle.customMontserrat(
                                          fontSize: 10,
                                          color: AppColors.blackColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: false,
                                    reservedSize: 50.sp,
                                    getTitlesWidget: (value, meta) {
                                      var data = controller.reportTopChart;
                                      if (value.toInt() < data.length) {
                                        return CustomPadding(
                                          paddingOption: OnlyPadding(top: 8),
                                          child: Text(
                                            data[value.toInt()].name ?? '',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),
                                ),
                              ),

                              barGroups: List.generate(
                                controller.reportTopChart.length,
                                (index) {
                                  final item = controller.reportTopChart[index];
                                  final qty =
                                      double.tryParse(
                                        item.totalQty.toString(),
                                      ) ??
                                      0;

                                  return BarChartGroupData(
                                    x: index,
                                    barRods: [
                                      BarChartRodData(
                                        toY: qty,
                                        width: 24,

                                        // 🔥 MINGUANG STYLE GRADIENT BAR
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFF6A85B6),
                                            Color(0xFFBFD5E2),
                                          ],
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                        ),

                                        borderRadius: BorderRadius.circular(12),

                                        // 🔥 Drop shadow
                                        backDrawRodData:
                                            BackgroundBarChartRodData(
                                              show: true,
                                              toY: qty + 10,
                                              color: Colors.grey.shade200,
                                            ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),
          ReportCommonContiner(
            height: 200,
            width: 500,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Top Product',
                  style: CustomTextStyle.customMontserrat(
                    fontSize: 17,
                    letterSpacing: 0.5,
                  ),
                ),

                Expanded(
                  child:
                      controller.reportTopModel.isEmpty
                          ? CommonNodatafound(message: 'No product found')
                          : ListView.builder(
                            itemCount: controller.reportTopModel.length,
                            itemBuilder: (context, index) {
                              var product = controller.reportTopModel[index];
                              return ListTile(
                                leading: Container(
                                  height: 40.h,
                                  width: 30.w,
                                  decoration: BoxDecoration(
                                    color: AppColors.greyColor,
                                    borderRadius: BorderRadius.circular(5.r),
                                  ),
                                  child: Center(
                                    child: Text(
                                      (index + 1).toString(),
                                      style: CustomTextStyle.customPoppin(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  product.name ?? '',
                                  style: CustomTextStyle.customPoppin(),
                                ),
                                subtitle: RichText(
                                  text: TextSpan(
                                    text: product.totalQty ?? '23',
                                    style: CustomTextStyle.customPoppin(),
                                    children: [
                                      TextSpan(
                                        text: ' sold',
                                        style: CustomTextStyle.customMontserrat(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                trailing: Text(
                                  '₹ ${product.revenue}',
                                  style: CustomTextStyle.customPoppin(
                                    fontSize: 18,
                                    letterSpacing: 0.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ReportOverViewContainer extends StatelessWidget {
  final String label;
  final String labelValue;
  final double width;
  final double height;
  const ReportOverViewContainer({
    super.key,
    required this.label,
    required this.labelValue,
    this.height = 80,
    this.width = 170,
  });

  @override
  Widget build(BuildContext context) {
    return ReportCommonContiner(
      height: height,
      width: width,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: CustomTextStyle.customMontserrat(
                fontSize: 17,
                letterSpacing: 0.5,
              ),
            ),
            setHeight(height: 10),
            Text(
              '₹ $labelValue',
              style: CustomTextStyle.customPoppin(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
