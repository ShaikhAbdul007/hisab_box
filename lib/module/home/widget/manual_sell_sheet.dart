import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_bottom_sheet.dart';
import 'package:inventory/common_widget/common_button.dart';
import 'package:inventory/common_widget/common_progressbar.dart';
import 'package:inventory/common_widget/common_nodatafound.dart';
import 'package:inventory/common_widget/search.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/routes/route_name.dart';
import 'package:inventory/routes/routes.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/module/inventorylist/model/inventory_model.dart';
import 'package:inventory/module/inventorylist/repo/inventory_repo.dart';
import 'package:inventory/module/inventory/repo/inventory_repo.dart';
import 'package:inventory/module/sell/controller/sell_list_after_scan_controller.dart';
import 'package:inventory/module/inventory/widget/show_dialog_boxs.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 1. Sell Option Bottom Sheet (Select Scan or Manual)
// ─────────────────────────────────────────────────────────────────────────────
void showSellOptionBottomSheet(
  BuildContext context, {
  bool isFromReview = false,
}) {
  commonBottomSheet(
    size: 18,
    label: 'Choose Sell Method',
    onPressed: () => Get.back(),
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _optionCard(
            title: 'Scan Barcode',
            subtitle: 'Use camera to scan product barcodes',
            icon: CupertinoIcons.barcode_viewfinder,
            color: const Color(0xFF1565C0),
            onTap: () {
              Get.back();
              if (isFromReview) {
                Get.offNamed(
                  AppRouteName.inventoryView,
                  arguments: {'flag': false},
                );
              } else {
                AppRoutes.futureNavigationToRoute(
                  routeName: AppRouteName.inventoryView,
                  data: {'flag': false},
                );
              }
            },
          ),
          _optionCard(
            title: 'Manual Sell',
            subtitle: 'Search products by name or barcode manually',
            icon: CupertinoIcons.search,
            color: AppColors.blackColor,
            onTap: () {
              Get.back();
              _showManualSellBottomSheet(context);
            },
          ),
          setHeight(height: 20),
        ],
      ),
    ),
  );
}

Widget _optionCard({
  required String title,
  required String subtitle,
  required IconData icon,
  required Color color,
  required VoidCallback onTap,
}) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: 0.08),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      border: Border.all(color: color.withValues(alpha: 0.15), width: 1.5),
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 26.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: CustomTextStyle.customPoppin(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.blackColor,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: CustomTextStyle.customOpenSans(
                        fontSize: 12,
                        color: AppColors.greyColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                CupertinoIcons.chevron_right,
                color: AppColors.greyColor.withValues(alpha: 0.6),
                size: 18.sp,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. Manual Sell Bottom Sheet (Search & Add)
// ─────────────────────────────────────────────────────────────────────────────
void _showManualSellBottomSheet(BuildContext context) {
  commonBottomSheet(
    size: 18,
    label: 'Manual Sell',
    onPressed: () => Get.back(),
    child: const ManualSellSheet(),
  );
}

// GetX Controller for managing state of Manual Sell
class ManualSellController extends GetxController with CacheManager {
  final TextEditingController searchCtrl = TextEditingController();
  final ScrollController scrollCtrl = ScrollController();

  final RxList<InventoryItem> allProducts = <InventoryItem>[].obs;
  final RxList<InventoryItem> filteredProducts = <InventoryItem>[].obs;
  final RxList<InventoryItem> cartItems = <InventoryItem>[].obs;

  final RxBool isLoading = true.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isDbSearching = false.obs;
  final RxString searchQuery = "".obs;

  int currentPage = 1;
  int totalPages = 1;

  @override
  void onInit() {
    super.onInit();
    loadCart();
    fetchProducts();
    scrollCtrl.addListener(_scrollListener);
  }

  @override
  void onClose() {
    searchCtrl.dispose();
    scrollCtrl.dispose();
    super.onClose();
  }

  void _scrollListener() {
    if (scrollCtrl.position.pixels >=
        scrollCtrl.position.maxScrollExtent - 200) {
      fetchProducts(loadMore: true);
    }
  }

  Future<void> loadCart() async {
    final cart = await retrieveCartProductList();
    cartItems.assignAll(cart);
  }

  Future<void> fetchProducts({bool loadMore = false}) async {
    if (loadMore) {
      if (currentPage >= totalPages || isLoadingMore.value) return;
      isLoadingMore.value = true;
    } else {
      isLoading.value = true;
    }

    try {
      final repo = InventoryRepo();
      final page = loadMore ? currentPage + 1 : 1;
      final response = await repo.getProductData(
        search: 'shop',
        page: page,
        limit: 50,
      );

      if (response.success == true && response.data != null) {
        final items = response.data?.data ?? [];
        if (loadMore) {
          allProducts.addAll(items);
          currentPage++;
        } else {
          allProducts.assignAll(items);
          currentPage = 1;
        }
        totalPages = response.data?.pagination?.totalPages ?? 1;
        applyFilter();
      } else {
        showSnackBar(error: response.msg ?? "Failed to fetch products");
      }
    } catch (e) {
      showSnackBar(error: e.toString());
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  void applyFilter() {
    final query = searchQuery.value.toLowerCase().trim();
    if (query.isEmpty) {
      filteredProducts.assignAll(allProducts);
    } else {
      filteredProducts.assignAll(
        allProducts.where((item) {
          final name = (item.name ?? '').toLowerCase();
          final barcode = (item.barcode ?? '').toLowerCase();
          return name.contains(query) || barcode.contains(query);
        }).toList(),
      );
    }
  }

  Future<void> searchBarcodeInDb(String barcode) async {
    isDbSearching.value = true;
    try {
      final repo = InventoryScanRepo();
      final res = await repo.fetchProductByBarcode(
        barcode: barcode.trim(),
        stocktype: 'packet',
      );

      if (res.success == true && res.data != null) {
        final product = res.data!;
        if ((product.location ?? '').toLowerCase() != 'shop') {
          showSnackBar(error: 'Product should be in shop to sell.');
          return;
        }

        final item = InventoryItem(
          id: product.id,
          name: product.name,
          barcode: product.barcode ?? barcode,
          sellingPrice: product.sellingPrice?.toString(),
          discount: product.discount,
          quantity: product.quantity?.toString() ?? '0',
          packetQuantity: product.quantity?.toString() ?? '0',
          stockType: 'packet',
          location: product.location,
          categoryName: product.categoryName,
          animalTypeName: product.animalTypeName,
          isloosed: product.isLoosed,
        );

        if (!allProducts.any((p) => p.barcode == item.barcode)) {
          allProducts.insert(0, item);
        }
        applyFilter();
        showSnackBar(error: 'Product found: ${product.name}', isError: false);
      } else {
        showSnackBar(error: 'Product not found in Database.');
      }
    } catch (e) {
      showSnackBar(error: e.toString());
    } finally {
      isDbSearching.value = false;
    }
  }

  Future<void> addToCart(
    InventoryItem item, {
    String stockType = 'packet',
  }) async {
    if ((item.location ?? '').toLowerCase() != 'shop') {
      showSnackBar(error: 'Product should be in shop to sell.');
      return;
    }

    final double availableQty =
        double.tryParse(item.quantity?.toString() ?? '0') ?? 0;
    if (availableQty <= 0) {
      showSnackBar(error: 'Product is out of stock.');
      return;
    }

    final cartList = List<InventoryItem>.from(cartItems);
    final index = cartList.indexWhere(
      (p) => p.barcode == item.barcode && p.stockType == stockType,
    );

    if (index != -1) {
      final double currentQty =
          double.tryParse(cartList[index].quantity?.toString() ?? '0') ?? 0;
      if (currentQty >= availableQty) {
        showSnackBar(error: 'No more stock available in shop.');
        return;
      }
      cartList[index].quantity = (currentQty + 1).toString();
      cartList[index].packetQuantity = availableQty.toString();
    } else {
      cartList.add(
        InventoryItem(
          barcode: item.barcode,
          id: item.id,
          name: item.name,
          sellingPrice: item.sellingPrice ?? '0',
          discount: item.discount ?? 0,
          quantity: '1.0',
          packetQuantity: availableQty.toString(),
          stockType: stockType,
          location: item.location,
        ),
      );
    }

    saveCartProductList(cartList);
    _updateReviewController();
    cartItems.assignAll(cartList);
  }

  Future<void> removeFromCart(
    InventoryItem item, {
    String stockType = 'packet',
  }) async {
    final cartList = List<InventoryItem>.from(cartItems);
    final index = cartList.indexWhere(
      (p) => p.barcode == item.barcode && p.stockType == stockType,
    );

    if (index == -1) return;

    final double currentQty =
        double.tryParse(cartList[index].quantity?.toString() ?? '0') ?? 0;
    if (currentQty > 1) {
      cartList[index].quantity = (currentQty - 1).toString();
    } else {
      cartList.removeAt(index);
    }

    saveCartProductList(cartList);
    _updateReviewController();
    cartItems.assignAll(cartList);
  }

  double getProductCartQty(InventoryItem item, {String? stockType}) {
    if (stockType != null) {
      final index = cartItems.indexWhere(
        (p) => p.barcode == item.barcode && p.stockType == stockType,
      );
      if (index == -1) return 0;
      return double.tryParse(cartItems[index].quantity?.toString() ?? '0') ?? 0;
    } else {
      double total = 0;
      for (final p in cartItems) {
        if (p.barcode == item.barcode) {
          total += double.tryParse(p.quantity?.toString() ?? '0') ?? 0;
        }
      }
      return total;
    }
  }

  void _updateReviewController() {
    if (Get.isRegistered<SellListAfterScanController>()) {
      Get.find<SellListAfterScanController>().setProductData();
    }
  }
}

class ManualSellSheet extends StatefulWidget {
  const ManualSellSheet({super.key});

  @override
  State<ManualSellSheet> createState() => _ManualSellSheetState();
}

class _ManualSellSheetState extends State<ManualSellSheet> {
  late final ManualSellController controller;

  void _handleAddTap(InventoryItem item) {
    final user = controller.retrieveUserDetail();
    final bool isPetShop = (user.data?.shopType ?? 'Pet Shop')
        .toLowerCase()
        .contains('pet');
    if (isPetShop && item.isloosed == true) {
      checkProductStatusDialog(
        label: 'Is this product sold in Packet or Loose?',
        packetOnTap: () {
          Get.back();
          controller.addToCart(item, stockType: 'packet');
        },
        looseDoneOnTap: () {
          Get.back();
          controller.addToCart(item, stockType: 'loose');
        },
      );
    } else {
      controller.addToCart(item, stockType: 'packet');
    }
  }

  void _handleRemoveTap(InventoryItem item) {
    final double packetQty = controller.getProductCartQty(
      item,
      stockType: 'packet',
    );
    final double looseQty = controller.getProductCartQty(
      item,
      stockType: 'loose',
    );
    if (packetQty > 0 && looseQty > 0) {
      checkProductStatusDialog(
        label: 'Which item would you like to decrease/remove?',
        packetOnTap: () {
          Get.back();
          controller.removeFromCart(item, stockType: 'packet');
        },
        looseDoneOnTap: () {
          Get.back();
          controller.removeFromCart(item, stockType: 'loose');
        },
      );
    } else if (looseQty > 0) {
      controller.removeFromCart(item, stockType: 'loose');
    } else {
      controller.removeFromCart(item, stockType: 'packet');
    }
  }

  @override
  void initState() {
    super.initState();
    controller = Get.put(ManualSellController());
  }

  @override
  void dispose() {
    Get.delete<ManualSellController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double sheetHeight = MediaQuery.of(context).size.height * 0.7;
    return Container(
      height: sheetHeight,
      color: Colors.white,
      child: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Obx(
              () => CommonSearch(
                label: 'Search',
                hintText: 'Search by name or barcode...',
                controller: controller.searchCtrl,
                icon:
                    controller.searchQuery.value.isNotEmpty
                        ? InkWell(
                          onTap: () {
                            controller.searchCtrl.clear();
                            controller.searchQuery.value = "";
                            controller.applyFilter();
                          },
                          child: Icon(
                            CupertinoIcons.clear_circled_solid,
                            size: 20.sp,
                            color: AppColors.blackColor,
                          ),
                        )
                        : null,
                onChanged: (val) {
                  controller.searchQuery.value = val;
                  controller.applyFilter();
                },
              ),
            ),
          ),

          // Product List or Loader
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CommonProgressBar(
                    size: 40,
                    color: AppColors.blackColor,
                  ),
                );
              }
              if (controller.filteredProducts.isEmpty) {
                return _buildEmptyState();
              }
              return ListView.builder(
                controller: controller.scrollCtrl,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                itemCount:
                    controller.filteredProducts.length +
                    (controller.isLoadingMore.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == controller.filteredProducts.length) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: const Center(
                        child: CommonProgressBar(
                          size: 24,
                          color: AppColors.blackColor,
                        ),
                      ),
                    );
                  }
                  final item = controller.filteredProducts[index];
                  return Obx(() => _buildProductRow(item));
                },
              );
            }),
          ),

          // Sticky Bottom Checkout Button
          _buildCheckoutButton(),
          setHeight(height: 10),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Obx(
        () => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 40.h),
            CommonNoDataFound(
              message:
                  'No product found locally matching "${controller.searchQuery.value}"',
            ),
            SizedBox(height: 20.h),
            if (controller.searchQuery.value.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: CommonButton(
                  label:
                      controller.isDbSearching.value
                          ? 'Searching...'
                          : 'Search Database by Barcode',
                  onTap: () {
                    if (!controller.isDbSearching.value) {
                      controller.searchBarcodeInDb(
                        controller.searchQuery.value,
                      );
                    }
                  },
                ),
              ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildProductRow(InventoryItem item) {
    final double inCartQty = controller.getProductCartQty(item);
    final double availableQty =
        double.tryParse(item.quantity?.toString() ?? '0') ?? 0;
    final bool isOutOfStock = availableQty <= 0;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color:
              inCartQty > 0
                  ? AppColors.deepPurple.withValues(alpha: 0.3)
                  : Colors.grey.shade200,
          width: inCartQty > 0 ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name ?? 'Unnamed Product',
                  style: CustomTextStyle.customPoppin(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blackColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                if ((item.barcode ?? '').isNotEmpty)
                  Text(
                    item.barcode!,
                    style: CustomTextStyle.customOpenSans(
                      fontSize: 11,
                      color: AppColors.greyColor,
                    ),
                  ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Text(
                      '₹${item.sellingPrice ?? '0'}',
                      style: CustomTextStyle.customPoppin(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.blackColor,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isOutOfStock
                                ? Colors.red.shade50
                                : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        isOutOfStock
                            ? 'Out of stock'
                            : 'Stock: ${availableQty.toInt()}',
                        style: CustomTextStyle.customOpenSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color:
                              isOutOfStock ? Colors.red : Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Add / Quantity Selector Button
          if (isOutOfStock)
            const SizedBox.shrink()
          else if (inCartQty == 0)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deepPurple,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              ),
              onPressed: () => _handleAddTap(item),
              child: Text(
                'Add',
                style: CustomTextStyle.customPoppin(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            )
          else
            Row(
              children: [
                // Minus button
                InkWell(
                  onTap: () => _handleRemoveTap(item),
                  child: Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CupertinoIcons.minus,
                      size: 14.sp,
                      color: AppColors.blackColor,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Text(
                  inCartQty.toInt().toString(),
                  style: CustomTextStyle.customPoppin(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 10.w),
                // Plus button
                InkWell(
                  onTap: () => _handleAddTap(item),
                  child: Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(
                      color: AppColors.deepPurple.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CupertinoIcons.plus,
                      size: 14.sp,
                      color: AppColors.deepPurple,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton() {
    return Obx(() {
      final bool isFromReview =
          Get.currentRoute == AppRouteName.sellListAfterScan ||
          Get.previousRoute == AppRouteName.sellListAfterScan;
      final int totalItems = controller.cartItems.fold(
        0,
        (sum, item) =>
            sum +
            (double.tryParse(item.quantity?.toString() ?? '0') ?? 0).toInt(),
      );
      print(totalItems);
      print(isFromReview);
      if (totalItems <= 0) {
        return const SizedBox.shrink();
      }
      return CommonButton(
        label:
            isFromReview
                ? 'Done ($totalItems items)'
                : 'Proceed to Sell ($totalItems items)',
        onTap: () {
          Get.back();
          if (totalItems > 0 && !isFromReview) {
            AppRoutes.navigateRoutes(routeName: AppRouteName.sellListAfterScan);
          }
        },
      );
    });
  }
}
