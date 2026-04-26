import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/app_message.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/helper/logger.dart';
import 'package:inventory/local_db/local_db_service.dart';
import 'package:inventory/module/inventory/model/product_model.dart';
import 'package:inventory/module/inventorylist/model/inventory_model.dart';
import 'package:inventory/module/inventorylist/repo/inventory_repo.dart';
import 'package:inventory/supabase_db/supabase_error_handler.dart';

class InventoryListController extends GetxController
    with GetSingleTickerProviderStateMixin, CacheManager, LocalService {
  InventoryRepo inventoryRepo = InventoryRepo();

  // var productList = <InventoryItem>[].obs;
  var goDownProductList = <InventoryItem>[].obs;
  var shopProductList = <InventoryItem>[].obs;

  RxBool isDataLoading = false.obs;
  RxBool isSaveLoading = false.obs;
  RxBool isInventoryScanSelected = false.obs;
  RxBool isSea = false.obs;
  RxBool isLoose = false.obs;
  RxBool isFlavorAndWeightNotRequired = false.obs;

  RxString searchText = ''.obs;

  TextEditingController updateQuantity = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController sellingPrice = TextEditingController();
  TextEditingController flavor = TextEditingController();
  TextEditingController weight = TextEditingController();
  TextEditingController purchasePrice = TextEditingController();
  TextEditingController searchController = TextEditingController();
  TextEditingController addSubtractQty = TextEditingController();

  TabController? tabController;

  @override
  void onInit() {
    isInventoryScanSelectedValue();
    super.onInit();

    tabController = TabController(length: 2, vsync: this);

    /// default first tab = shop
  }

  @override
  void onReady() {
    fetchInventoryByTab('shop');

    tabController!.addListener(() {
      if (tabController!.indexIsChanging) return;

      if (tabController!.index == 0) {
        fetchInventoryByTab('shop');
      } else if (tabController!.index == 1) {
        fetchInventoryByTab('godown');
      }
    });
    super.onReady();
  }

  Future<void> isInventoryScanSelectedValue() async {
    try {
      bool isInventoryScanSelecteds = await retrieveInventoryScan();
      isInventoryScanSelected.value = isInventoryScanSelecteds;
    } catch (e) {
      AppLogger.error(
        'Failed to load inventory scan setting',
        e,
        'InventoryListController',
      );
      isInventoryScanSelected.value = false;
    }
  }

  Future<void> fetchInventoryByTab(String type) async {
    isDataLoading.value = true;

    try {
      var response = await inventoryRepo.getProductData(search: type);

      if (response.success == success) {
        if (type == 'shop') {
          shopProductList.value = response.data?.data ?? [];
        } else if (type == 'godown') {
          goDownProductList.value = response.data?.data ?? [];
        }

        // /// optional combined list
        // productList.value = [
        //   ...shopProductList,
        //   ...goDownProductList,
        // ];
      } else if (response.success == failed) {
        showSnackBar(error: response.msg ?? somethingWentMessage);
      } else {
        showSnackBar(error: somethingWentMessage);
      }
    } catch (e) {
      showSnackBar(error: e.toString());
    } finally {
      isDataLoading.value = false;
    }
  }

  /// agar kabhi all data chahiye future me
  // Future<void> fetchAllInventory() async {
  //   isDataLoading.value = true;

  //   try {
  //     var response = await inventoryRepo.getProductData(search: 'all');

  //     if (response.success == success) {
  //       productList.value = response.data?.data ?? [];

  //       goDownProductList.value =
  //           productList.where((p) => p.location == 'godown').toList();

  //       shopProductList.value =
  //           productList.where((p) => p.location == 'shop').toList();
  //     } else if (response.success == failed) {
  //       showSnackBar(error: response.msg ?? somethingWentMessage);
  //     } else {
  //       showSnackBar(error: somethingWentMessage);
  //     }
  //   } catch (e) {
  //     showSnackBar(error: e.toString());
  //   } finally {
  //     isDataLoading.value = false;
  //   }
  // }

  void clear() {
    searchController.clear();
    searchText.value = '';
  }

  void searchProduct(String value) {
    searchText.value = value;
  }

  @override
  void onClose() {
    tabController?.dispose();

    updateQuantity.dispose();
    name.dispose();
    sellingPrice.dispose();
    flavor.dispose();
    weight.dispose();
    purchasePrice.dispose();
    searchController.dispose();
    addSubtractQty.dispose();

    super.onClose();
  }
}
