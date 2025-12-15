import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/module/expense/model/expens_model.dart';
import '../../../helper/textstyle.dart';

class ExpensText extends StatelessWidget {
  final ExpenseModel expensModel;
  const ExpensText({super.key, required this.expensModel});

  @override
  Widget build(BuildContext context) {
    return CustomPadding(
      paddingOption: SymmetricPadding(horizontal: 8, vertical: 5),
      child: Card(
        color: AppColors.whiteColor,
        elevation: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomPadding(
              paddingOption: OnlyPadding(left: 10, top: 10, right: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expensModel.expenseName,
                    style: CustomTextStyle.customPoppin(),
                  ),
                  setHeight(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${expensModel.date}',
                        style: CustomTextStyle.customPoppin(),
                      ),
                      setWidth(width: 30),
                      Text(
                        '${expensModel.time}',
                        style: CustomTextStyle.customPoppin(),
                      ),
                    ],
                  ),
                  setHeight(height: 10),
                  Text(
                    expensModel.notes ?? '',
                    style: CustomTextStyle.customPoppin(),
                  ),
                ],
              ),
            ),
            Container(
              height: 50.h,
              width: 70.w,
              padding: AllPadding(all: 5).getPadding(),
              margin: AllPadding(all: 5).getPadding(),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: AppColors.greyColorShade100,
              ),
              child: Center(
                child: Text(
                  expensModel.amount.toString(),
                  style: CustomTextStyle.customPoppin(
                    color: AppColors.blackColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
