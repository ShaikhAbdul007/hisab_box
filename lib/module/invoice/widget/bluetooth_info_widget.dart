import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common_widget/common_button.dart';
import '../../../common_widget/common_popup_appbar.dart';
import '../../../common_widget/size.dart';
import '../../../helper/textstyle.dart';
import '../../../routes/routes.dart';

class BluetoothInfoWidget extends StatelessWidget {
  const BluetoothInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CommonPopupAppbar(
          label: 'Bluetooth Info',
          onPressed: () {
            Get.back();
          },
        ),
        const Divider(),
        RichText(
          text: TextSpan(
            style: CustomTextStyle.customMontserrat(),
            children: [
              TextSpan(
                text:
                    'Please connect your printer before printing the invoice.\nSteps to set up the printer:\n',
              ),
              TextSpan(
                text: '1. ',
                style: CustomTextStyle.customUbuntu(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(text: 'Go to Settings\n'),
              TextSpan(
                text: '2. ',
                style: CustomTextStyle.customUbuntu(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(text: 'Click on App Settings\n'),
              TextSpan(
                text: '3. ',
                style: CustomTextStyle.customUbuntu(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(text: 'Select Printer Option\n'),
              TextSpan(
                text: '4. ',
                style: CustomTextStyle.customUbuntu(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(text: 'Save your preferred printer'),
            ],
          ),
        ),
        setHeight(height: 8),
        CommonButton(
          label: 'ok',
          onTap: () {
            Get.back();
            AppRoutes.navigateRoutes(routeName: AppRouteName.appsetting);
          },
        ),
        setHeight(height: 15),
      ],
    );
  }
}
