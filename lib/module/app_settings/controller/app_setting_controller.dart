import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/logger.dart';

class AppSettingController extends GetxController with CacheManager {
  RxBool isInventoryScanSelected = false.obs;
  RxBool isGodownSelected = false.obs;
  final profitMarginController = TextEditingController().obs;

  @override
  void onInit() {
    isInventoryScanSelectedValue();
    isGodownSelectedValue();

    super.onInit();
  }

  Future<void> isInventoryScanSelectedValue() async {
    try {
      bool isInventoryScanSelecteds = await retrieveInventoryScan();
      isInventoryScanSelected.value = isInventoryScanSelecteds;
    } catch (e) {
      AppLogger.error(
        'Failed to read inventory scan setting',
        e,
        'AppSettingController',
      );
      isInventoryScanSelected.value = false;
    }
  }

  Future<void> isGodownSelectedValue() async {
    try {
      bool isGodownSelecteds = await retrieveGodown();
      isGodownSelected.value = isGodownSelecteds;
    } catch (e) {
      AppLogger.error(
        'Failed to read godown setting',
        e,
        'AppSettingController',
      );
      isGodownSelected.value = false;
    }
  }
}
