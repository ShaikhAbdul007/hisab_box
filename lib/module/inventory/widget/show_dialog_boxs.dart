import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:inventory/common_widget/common_dialogue.dart';
import '../../../common_widget/colors.dart';
import '../../../common_widget/common_button.dart';
import '../../../common_widget/common_popup_appbar.dart';
import '../../../common_widget/size.dart';
import '../../../helper/textstyle.dart';

void exisitngProductDialog({
  required String message,
  required void Function() onPressed,
}) {
  Get.defaultDialog(
    title: '',
    titleStyle: CustomTextStyle.customNato(fontSize: 0),
    titlePadding: EdgeInsets.zero,
    barrierDismissible: false,
    content: Column(
      children: [
        CommonPopupAppbar(label: '⚠️ Alert', onPressed: onPressed),
        Divider(),
        Text(message, style: CustomTextStyle.customNato()),
      ],
    ),
  );
}

productNotAvailableDialog(
  BuildContext context,
  String label, {
  required void Function() onTap,
}) {
  commonDialogBox(
    context: context,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Text(
            '⚠️ Error',
            style: CustomTextStyle.customRaleway(fontWeight: FontWeight.bold),
          ),
        ),
        setHeight(height: 10),
        Text(label, style: CustomTextStyle.customRaleway()),
        setHeight(height: 10),
        CommonButton(label: 'ok', onTap: onTap),
        setHeight(height: 30),
      ],
    ),
  );
}

productNotWithScannedAvailableDialog(
  BuildContext context,
  String label, {
  required void Function() scanAgainOnTap,
  required void Function() scanningDoneOnTap2,
  required void Function() manualSellOnTap,
}) {
  commonDialogBox(
    context: context,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Text(
            '⚠️ Error',
            style: CustomTextStyle.customRaleway(fontWeight: FontWeight.bold),
          ),
        ),
        setHeight(height: 10),
        Text(label, style: CustomTextStyle.customRaleway()),
        setHeight(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            CommonButton(
              width: 120,
              label: 'Scan Again',
              onTap: scanAgainOnTap,
            ),
            CommonButton(
              bgColor: AppColors.buttonRedColor,
              width: 150,
              label: 'Scanning Done',
              onTap: scanningDoneOnTap2,
            ),
          ],
        ),
        setHeight(height: 10),
        CommonButton(
          bgColor: AppColors.buttonGreenColor,
          label: 'Manual Sell',
          onTap: manualSellOnTap,
        ),
        setHeight(height: 10),
      ],
    ),
  );
}

productSavingDialog({
  required BuildContext context,
  required String label,
  required void Function() scanAgainOnTap,
  required void Function() scanccingDoneOnTap,
  required void Function() manualSellOnTap,
}) {
  commonDialogBox(
    context: context,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Text('', style: CustomTextStyle.customRaleway(fontSize: 0)),
        ),
        setHeight(height: 10),
        Text(label, style: CustomTextStyle.customRaleway(fontSize: 15)),
        setHeight(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            CommonButton(
              width: 120,
              label: 'Scan Again',
              onTap: scanAgainOnTap,
            ),
            CommonButton(
              bgColor: AppColors.buttonRedColor   ,
              width: 140,
              label: 'Scanning Done',
              onTap: scanccingDoneOnTap,
            ),
          ],
        ),
        setHeight(height: 10),
        CommonButton(
          bgColor: AppColors.buttonGreenColor,
          label: 'Manual Sell',
          onTap: manualSellOnTap,
        ),
        setHeight(height: 10),
      ],
    ),
  );
}
