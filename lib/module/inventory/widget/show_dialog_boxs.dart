import 'package:flutter/material.dart';
import 'package:inventory/common_widget/common_bottom_sheet.dart';
import 'package:inventory/module/inventory/model/product_model.dart';
import '../../../common_widget/colors.dart';
import '../../../common_widget/common_button.dart';
import '../../../common_widget/size.dart';
import '../../../helper/textstyle.dart';

void exisitngProductDialog({
  required String message,
  required VoidCallback onPressed,
}) {
  commonBottomSheet(
    size: 18,
    label: 'Alert',
    onPressed: onPressed,
    child: Text(message, style: CustomTextStyle.customNato()),
  );
}

void productNotAvailableDialog({
  required String label,
  required VoidCallback onTap,
  required VoidCallback? scannedDoneOnTap,
  required List<ProductModel> productModel,
}) {
  commonBottomSheet(
    size: 18,
    label: 'Error Info',
    onPressed: () {},
    isCancelButtonRequire: false,
    child: PopScope(
      canPop: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          setHeight(height: 10),
          Text(label, style: CustomTextStyle.customRaleway()),
          setHeight(height: 10),
          CommonButton(label: 'ok', onTap: onTap),
          if (productModel.isNotEmpty) ...{
            setHeight(height: 10),
            CommonButton(
              bgColor: AppColors.redColor,
              label: 'Scanned Done',
              onTap: scannedDoneOnTap ?? () {},
            ),
          },
          setHeight(height: 30),
        ],
      ),
    ),
  );
}

void productNotWithScannedAvailableDialog(
  String label, {
  required void Function() scanAgainOnTap,
  required void Function() scanningDoneOnTap2,
  required void Function() manualSellOnTap,
}) {
  commonBottomSheet(
    label: 'Error Info',
    onPressed: () {},
    isCancelButtonRequire: false,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
        setHeight(height: 30),
        // CommonButton(
        //   bgColor: AppColors.buttonGreenColor,
        //   label: 'Manual Sell',
        //   onTap: manualSellOnTap,
        // ),
        // setHeight(height: 10),
      ],
    ),
  );
}

void productSavingDialog({
  required String label,
  required void Function() scanAgainOnTap,
  required void Function() scanccingDoneOnTap,
  // required void Function() manualSellOnTap,
}) {
  commonBottomSheet(
    label: 'Scan Info',
    isCancelButtonRequire: false,
    onPressed: () {},
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        setHeight(height: 20),
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
              bgColor: AppColors.buttonRedColor,
              width: 140,
              label: 'Scanning Done',
              onTap: scanccingDoneOnTap,
            ),
          ],
        ),
        setHeight(height: 80),
      ],
    ),
  );
}

void checkProductStatusDialog({
  required String label,
  required VoidCallback packetOnTap,
  required VoidCallback looseDoneOnTap,
}) {
  commonBottomSheet(
    label: 'Product Info',
    isCancelButtonRequire: false,
    onPressed: () {},
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        setHeight(height: 20),
        Text(label, style: CustomTextStyle.customRaleway(fontSize: 15)),
        setHeight(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            CommonButton(width: 120, label: 'Packet', onTap: packetOnTap),
            CommonButton(
              bgColor: AppColors.buttonRedColor,
              width: 140,
              label: 'Loose',
              onTap: looseDoneOnTap,
            ),
          ],
        ),
        setHeight(height: 80),
      ],
    ),
  );
}
