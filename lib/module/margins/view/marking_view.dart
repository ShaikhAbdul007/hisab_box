import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_button.dart';
import 'package:inventory/common_widget/textfiled.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/module/margins/controller/marking_controller.dart';

class MarkingView extends GetView<MarkingController> {
  const MarkingView({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      appBarLabel: 'Margin',
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CommonTextField(
              hintText: 'Enter margin details',
              controller: controller.markingController,
              keyboardType: TextInputType.number,
              label: 'Margin',
              inputLength: 3,
            ),
            setHeight(height: 20),
            Obx(
              () => CommonButton(
                label: 'Save',
                isLoading: controller.isSaving.value,
                onTap: controller.saveMarking,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
