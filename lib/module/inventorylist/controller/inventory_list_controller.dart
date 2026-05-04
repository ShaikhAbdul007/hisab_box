import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/app_message.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/helper/logger.dart';
import 'package:inventory/helper/shop_type.dart';
import 'package:inventory/module/inventorylist/model/inventory_model.dart';
import 'package:inventory/module/inventorylist/repo/inventory_repo.dart';

class InventoryListController extends GetxController
    with GetTickerProviderStateMixin, CacheManager {
  InventoryRepo inventoryRepo = InventoryRepo();

  var goDownProductList = <InventoryItem>[].obs;
  var shopProductList = <InventoryItem>[].obs;

  RxBool isDataLoading = false.obs;
  RxBool isSaveLoading = false.obs;
  RxBool isInventoryScanSelected = false.obs;
  RxBool isLoose = false.obs;
  RxBool isFlavorAndWeightNotRequired = false.obs;
  RxString shopType = ''.obs;
  RxBool isGodownEnabled = false.obs;

  ShopType get shopTypeEnum => ShopType.fromString(shopType.value);

  // ── Pagination state ──────────────────────────────────────────────────────
  int _shopPage = 1;
  int _godownPage = 1;
  int _shopTotalPages = 1;
  int _godownTotalPages = 1;
  RxBool isLoadingMore = false.obs;

  RxString searchText = ''.obs;

  TextEditingController updateQuantity = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController sellingPrice = TextEditingController();
  TextEditingController flavor = TextEditingController();
  TextEditingController weight = TextEditingController();
  TextEditingController purchasePrice = TextEditingController();
  TextEditingController searchController = TextEditingController();
  TextEditingController addSubtractQty = TextEditingController();

  // Scroll controllers for infinite scroll
  final ScrollController shopScrollController = ScrollController();
  final ScrollController godownScrollController = ScrollController();

  TabController? tabController;

  @override
  void onInit() {
    isInventoryScanSelectedValue();
    retrieveGodownValue();
    _attachScrollListeners();
    final user = retrieveUserDetail();
    shopType.value = user.data?.shopType ?? '';
    super.onInit();
  }

  @override
  void onReady() {
    // fetchInventoryByTab is called inside _initTabController after godown value loads
    super.onReady();
  }

  void _initTabController({required int length}) {
    tabController?.dispose();
    tabController = TabController(length: length, vsync: this);
    tabController!.addListener(() {
      if (tabController!.indexIsChanging) return;
      if (tabController!.index == 0) {
        fetchInventoryByTab('shop');
      } else if (isGodownEnabled.value && tabController!.index == 1) {
        fetchInventoryByTab('godown');
      }
    });
    update();
    // Initial load after tab controller is ready
    fetchInventoryByTab('shop');
  }

  void _attachScrollListeners() {
    shopScrollController.addListener(() {
      if (_isNearBottom(shopScrollController) &&
          !isLoadingMore.value &&
          _shopPage < _shopTotalPages) {
        _loadMoreByTab('shop');
      }
    });

    godownScrollController.addListener(() {
      if (_isNearBottom(godownScrollController) &&
          !isLoadingMore.value &&
          _godownPage < _godownTotalPages) {
        _loadMoreByTab('godown');
      }
    });
  }

  bool _isNearBottom(ScrollController sc) {
    if (!sc.hasClients) return false;
    return sc.position.pixels >= sc.position.maxScrollExtent - 200;
  }

  Future<void> isInventoryScanSelectedValue() async {
    try {
      bool val = await retrieveInventoryScan();
      isInventoryScanSelected.value = val;
    } catch (e) {
      AppLogger.error(
        'Failed to load inventory scan setting',
        e,
        'InventoryListController',
      );
      isInventoryScanSelected.value = false;
    }
  }

  Future<void> retrieveGodownValue() async {
    try {
      final value = await retrieveGodown();
      isGodownEnabled.value = value;
      _initTabController(length: value ? 2 : 1);
    } catch (e) {
      AppLogger.error(
        'Failed to load godown setting',
        e,
        'InventoryListController',
      );
      isGodownEnabled.value = false;
      _initTabController(length: 1);
    }
  }

  /// Fresh load — resets page to 1 and clears list
  Future<void> fetchInventoryByTab(String type) async {
    isDataLoading.value = true;

    if (type == 'shop') {
      _shopPage = 1;
      shopProductList.clear();
    } else {
      _godownPage = 1;
      goDownProductList.clear();
    }

    try {
      final page = type == 'shop' ? _shopPage : _godownPage;
      final response = await inventoryRepo.getProductData(
        search: type,
        page: page,
      );

      if (response.success == success) {
        final items = response.data?.data ?? [];
        final pagination = response.data?.pagination;

        if (type == 'shop') {
          shopProductList.assignAll(items);
          _shopTotalPages = pagination?.totalPages ?? 1;
        } else {
          goDownProductList.assignAll(items);
          _godownTotalPages = pagination?.totalPages ?? 1;
        }
      } else {
        showSnackBar(error: response.msg ?? somethingWentMessage);
      }
    } catch (e) {
      showSnackBar(error: e.toString());
    } finally {
      isDataLoading.value = false;
    }
  }

  /// Load next page — appends to existing list
  Future<void> _loadMoreByTab(String type) async {
    isLoadingMore.value = true;

    if (type == 'shop') {
      _shopPage++;
    } else {
      _godownPage++;
    }

    try {
      final page = type == 'shop' ? _shopPage : _godownPage;
      final response = await inventoryRepo.getProductData(
        search: type,
        page: page,
      );

      if (response.success == success) {
        final items = response.data?.data ?? [];
        final pagination = response.data?.pagination;

        if (type == 'shop') {
          shopProductList.addAll(items);
          _shopTotalPages = pagination?.totalPages ?? _shopTotalPages;
        } else {
          goDownProductList.addAll(items);
          _godownTotalPages = pagination?.totalPages ?? _godownTotalPages;
        }
      } else {
        // revert page increment on failure
        if (type == 'shop') {
          _shopPage--;
        } else {
          _godownPage--;
        }
        showSnackBar(error: response.msg ?? somethingWentMessage);
      }
    } catch (e) {
      if (type == 'shop') {
        _shopPage--;
      } else {
        _godownPage--;
      }
      showSnackBar(error: e.toString());
    } finally {
      isLoadingMore.value = false;
    }
  }

  bool get shopHasMore => _shopPage < _shopTotalPages;
  bool get godownHasMore => _godownPage < _godownTotalPages;

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
    shopScrollController.dispose();
    godownScrollController.dispose();
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
