import 'package:flutter/material.dart';
import 'package:inventory/helper/app_message.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/helper/logger.dart';
import 'package:get/get.dart';
import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/module/revenue/model/revenue_list_model.dart';
import 'package:inventory/module/revenue/repo/revenue_repo.dart';
import 'package:inventory/module/sell/model/sell_model.dart';

class RevenueController extends GetxController {
  RevenueRepo revenueRepo = RevenueRepo();
  RxBool isRevenueListLoading = false.obs;
  RxBool isLoadingMore = false.obs;
  var sellsList = <RevenueListItemData>[].obs;
  RxDouble sellTotalAmount = 0.0.obs;
  RxString dayDate = ''.obs;

  // Pagination state variables
  final ScrollController scrollController = ScrollController();
  int _currentPage = 1;
  int _totalPages = 1;

  @override
  void onInit() {
    dayDate.value = setFormateDate();
    _setupScrollController();
    setSellList();
    super.onInit();
  }

  void _setupScrollController() {
    scrollController.addListener(() {
      if (_isNearBottom() && !isLoadingMore.value && _currentPage < _totalPages) {
        loadMoreSales();
      }
    });
  }

  bool _isNearBottom() {
    if (!scrollController.hasClients) return false;
    return scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200;
  }

  void setSellList() async {
    _currentPage = 1;
    _totalPages = 1;
    sellsList.clear();
    await fetchSales();
  }

  Future<void> fetchSales({String? todaysDate}) async {
    isRevenueListLoading.value = true;
    final selectedDate = getApiFormattedDate(todaysDate ?? dayDate.value);

    try {
      var response = await revenueRepo.fetchSell(
        date: selectedDate,
        page: _currentPage,
        limit: 10,
      );

      if (response.success == success) {
        sellsList.assignAll(response.data?.data ?? []);
        sellTotalAmount.value = response.data?.grandTotal?.toDouble() ?? 0.0;
        _totalPages = response.data?.pagination?.totalPages ?? 1;
        _currentPage = response.data?.pagination?.page ?? 1;
      } else if (response.success == failed) {
        showSnackBar(error: response.msg ?? somethingWentMessage);
      } else {
        showSnackBar(error: somethingWentMessage);
      }
    } catch (e) {
      AppLogger.info("🚨 Fetch Sales Error: $e");
      showSnackBar(error: e.toString());
    } finally {
      isRevenueListLoading.value = false;
    }
  }

  Future<void> loadMoreSales() async {
    isLoadingMore.value = true;
    final selectedDate = getApiFormattedDate(dayDate.value);

    try {
      final nextPage = _currentPage + 1;
      var response = await revenueRepo.fetchSell(
        date: selectedDate,
        page: nextPage,
        limit: 10,
      );

      if (response.success == success) {
        final newItems = response.data?.data ?? [];
        if (newItems.isNotEmpty) {
          sellsList.addAll(newItems);
        }
        _totalPages = response.data?.pagination?.totalPages ?? 1;
        _currentPage = response.data?.pagination?.page ?? nextPage;
      } else if (response.success == failed) {
        showSnackBar(error: response.msg ?? somethingWentMessage);
      }
    } catch (e) {
      AppLogger.info("🚨 Load More Sales Error: $e");
    } finally {
      isLoadingMore.value = false;
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
