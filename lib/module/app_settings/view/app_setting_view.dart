import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/module/app_settings/controller/app_setting_controller.dart';
import 'package:inventory/module/app_settings/widget/app_setting_text.dart';

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
        ],
      ),
    );
  }
}
