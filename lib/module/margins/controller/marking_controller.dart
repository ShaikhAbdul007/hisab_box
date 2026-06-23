import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/helper/helper.dart';

class MarkingController extends GetxController {
  final TextEditingController markingController = TextEditingController();
  final RxBool isSaving = false.obs;

  void saveMarking() async {
    if (markingController.text.trim().isEmpty) {
      showSnackBar(error: 'Please enter marking details');
      return;
    }

    isSaving.value = true;
    await Future.delayed(const Duration(milliseconds: 300));
    isSaving.value = false;

    showSnackBar(error: 'Marking saved successfully', isError: false);
    Get.back(result: true);
  }

  @override
  void onClose() {
    markingController.dispose();
    super.onClose();
  }
}
