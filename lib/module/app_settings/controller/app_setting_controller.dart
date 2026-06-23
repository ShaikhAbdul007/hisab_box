import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/logger.dart';
import 'package:inventory/helper/shop_type.dart';

class AppSettingController extends GetxController with CacheManager {
  RxBool isInventoryScanSelected = false.obs;
  RxBool isGodownSelected = false.obs;
  RxBool isClothingShop = false.obs;
  RxBool isClothingScanSelected = false.obs;
  final profitMarginController = TextEditingController().obs;

  @override
  void onInit() {
    final user = retrieveUserDetail();
    isClothingShop.value =
        ShopType.fromString(user.data?.shopType ?? '') == ShopType.clothingShop;

    isInventoryScanSelectedValue();
    isGodownSelectedValue();
    if (isClothingShop.value) {
      isClothingScanSelectedValue();
    }

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

  Future<void> isClothingScanSelectedValue() async {
    try {
      bool isClothingScanSelecteds = await retrieveClothingScan();
      isClothingScanSelected.value = isClothingScanSelecteds;
    } catch (e) {
      AppLogger.error(
        'Failed to read clothing scan setting',
        e,
        'AppSettingController',
      );
      isClothingScanSelected.value = false;
    }
  }
}
