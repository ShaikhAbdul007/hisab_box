import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common_widget/colors.dart';
import '../../../common_widget/common_button.dart';
import '../../../common_widget/common_popup_appbar.dart';
import '../../../common_widget/size.dart';
import '../../../helper/textstyle.dart';

class InvoicConfirmationWidget extends StatelessWidget {
  final void Function() noOnTap;
  final void Function() yesOnTap;
  const InvoicConfirmationWidget({
    super.key,
    required this.noOnTap,
    required this.yesOnTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Do you want to print the invoice ?',
          style: CustomTextStyle.customPoppin(fontSize: 16),
        ),
        setHeight(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            CommonButton(
              bgColor: AppColors.greyColorShade100,
              textColor: AppColors.blackColor,
              width: 100,
              label: 'No',
              onTap: noOnTap,
            ),
            CommonButton(width: 100, label: 'Yes', onTap: yesOnTap),
          ],
        ),
        setHeight(height: 50),
      ],
    );
  }
}
