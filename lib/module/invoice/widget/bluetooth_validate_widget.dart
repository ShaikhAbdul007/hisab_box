import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common_widget/common_button.dart';
import '../../../common_widget/common_popup_appbar.dart';
import '../../../common_widget/size.dart';
import '../../../helper/textstyle.dart';

class BluetoothValidateWidget extends StatelessWidget {
  const BluetoothValidateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Bluetooth is off, please on it.',
          style: CustomTextStyle.customMontserrat(),
        ),
        setHeight(height: 20),
        CommonButton(
          label: 'Open Setting',
          onTap: () {
            Get.back();
            AppSettings.openAppSettings(type: AppSettingsType.bluetooth);
          },
        ),
        setHeight(height: 20),
      ],
    );
  }
}
