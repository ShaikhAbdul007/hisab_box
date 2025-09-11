import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/module/app_settings/controller/app_setting_controller.dart';
import 'package:inventory/module/app_settings/widget/app_setting_text.dart';

import '../../../common_widget/common_switch.dart';
import '../../../helper/helper.dart';
import '../../../helper/textstyle.dart';

class AppSettingView extends GetView<AppSettingController> {
  const AppSettingView({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      appBarLabel: 'App Setting',
      body: Column(
        children: [
          Obx(
            () => AppSettingText(
              child: CommonSwitch(
                label: 'Inventory Scan',
                value: controller.isInventoryScanSelected.value,
                onChanged: (v) {
                  controller.isInventoryScanSelected.value =
                      !controller.isInventoryScanSelected.value;
                  print(controller.isInventoryScanSelected.value);
                  controller.saveInventoryScanValue(
                    controller.isInventoryScanSelected.value,
                  );
                },
              ),
            ),
          ),
          setHeight(height: 10),
          AppSettingText(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Printers',
                    style: CustomTextStyle.customNato(fontSize: 18),
                  ),
                  InkWell(
                    onTap: () => selectPrinter(context),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.blackColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      height: 35,
                      width: 40,
                      child: Icon(
                        CupertinoIcons.printer,
                        color: AppColors.whiteColor,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> selectPrinter(BuildContext context) async {
    final device = await FlutterBluetoothPrinter.selectDevice(context);
    if (device != null) {
      controller.savePrinterAddress(device.address);
      showMessage(message: "✅ Printer saved: ${device.name}");
    } else {
      showMessage(message: "Printer not found");
    }
  }
}
