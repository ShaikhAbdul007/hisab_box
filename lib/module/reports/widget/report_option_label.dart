import 'package:flutter/material.dart';
import 'package:inventory/module/reports/controller/report_controller.dart';
import '../../../common_widget/size.dart';
import '../../../helper/textstyle.dart';

class ReportOptionContainerLabel extends StatelessWidget {
  final ReportController controller;
  const ReportOptionContainerLabel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.daysOtionLabel.length,
        itemBuilder: (context, index) {
          var label = controller.daysOtionLabel[index];
          return InkWell(
            onTap: () {
              print(index);
            },
            child: Container(
              height: 30,
              width: 100,
              padding: EdgeInsets.symmetric(horizontal: 5),
              margin: EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_month),
                  setWidth(width: 8),
                  Text(
                    label,
                    style: CustomTextStyle.customMontserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
