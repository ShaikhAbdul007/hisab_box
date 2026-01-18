import 'package:flutter/material.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/textstyle.dart';
import '../../../common_widget/common_nodatafound.dart';
import '../../revenue/widget/revenue_list_text.dart';
import '../controller/report_controller.dart';
import '../widget/report_common_continer.dart';
import '../widget/report_overview_widget.dart';

class ReportSaleWidget extends StatelessWidget {
  final ReportController controller;
  const ReportSaleWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ReportOverViewContainer(
            width: 500,
            label: 'Total Revenue',
            labelValue: controller.totalRevenue.value.toStringAsFixed(2),
          ),
          // Row(
          //   children: [

          //     ReportOverViewContainer(
          //       width: 180,
          //       label: 'Total Profit',
          //       labelValue: controller.totalProfit.value.toStringAsFixed(2),
          //     ),
          //   ],
          // ),
          ReportCommonContiner(
            height: 500,
            width: 500,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Transactions',
                  style: CustomTextStyle.customMontserrat(
                    fontSize: 17,
                    letterSpacing: 0.5,
                  ),
                ),
                setHeight(height: 20),
                Expanded(
                  child:
                      controller.sellsList.isNotEmpty
                          ? ListView.builder(
                            itemCount: controller.sellsList.length,
                            itemBuilder: (context, index) {
                              var product = controller.sellsList[index];
                              return RevenueListText(
                                billModel: product,
                                // index: index,
                              );
                            },
                          )
                          : CommonNodatafound(message: 'No sell found'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
