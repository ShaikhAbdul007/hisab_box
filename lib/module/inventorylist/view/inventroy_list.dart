import 'package:inventory/responsive_layout/dimension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/app_popup_menu.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_nodatafound.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/common_progressbar.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/helper.dart';
import '../../../common_widget/search.dart';
import '../../../helper/textstyle.dart';
import '../../../routes/route_name.dart';
import '../../../routes/routes.dart';
import '../controller/inventory_list_controller.dart';
import '../widget/inventory_list_text.dart';

import 'package:inventory/module/generate_barcode/widget/generate_barcode.dart';
import 'package:inventory/module/generate_barcode/controller/generate_barcode_controller.dart';

enum _InventoryModeMenu { scan, manual }

class InventroyList extends GetView<InventoryListController> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  InventroyList({super.key});

  @override
  Widget build(BuildContext context) {
    if (isDesktop(context)) {
      return Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.grey.shade50,
        endDrawer: Drawer(
          width: 550,
          child: Column(
            children: [
              AppBar(
                title: const Text(
                  'Add Product',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => scaffoldKey.currentState?.closeEndDrawer(),
                ),
              ),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (!Get.isRegistered<GenerateBarcodeController>()) {
                      Get.put(GenerateBarcodeController());
                    }
                    return GenerateBarcodeComponent(
                      controller: Get.find<GenerateBarcodeController>(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        appBar: AppBar(
          title: Text(
            'Product Inventory',
            style: CustomTextStyle.customNato(fontSize: 16),
          ),
          actionsPadding: const EdgeInsets.only(right: 20),
          actions: [
            // Quick action to add product
            ElevatedButton.icon(
              onPressed: () {
                if (!Get.isRegistered<GenerateBarcodeController>()) {
                  Get.put(GenerateBarcodeController());
                } else {
                  final formController = Get.find<GenerateBarcodeController>();
                  formController.clear();
                  formController.setBarcode();
                }
                scaffoldKey.currentState?.openEndDrawer();
              },
              icon: const Icon(CupertinoIcons.add_circled, size: 16),
              label: const Text('Add Product'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blackColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
          surfaceTintColor: AppColors.greyColorShade100,
          backgroundColor: AppColors.greyColorShade100,
        ),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left pane: Search, Tabs & Product grid/list
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                    child: CommonSearch(
                      icon: Obx(
                        () =>
                            controller.searchText.value.isNotEmpty
                                ? InkWell(
                                  onTap: () {
                                    controller.clear();
                                    unfocus();
                                  },
                                  child: Icon(
                                    CupertinoIcons.clear_circled_solid,
                                    size: 20.sp,
                                    color: AppColors.blackColor,
                                  ),
                                )
                                : const SizedBox.shrink(),
                      ),
                      label: 'Search',
                      hintText: 'Search products by barcode, name or weight...',
                      controller: controller.searchController,
                      onChanged: (val) => controller.searchProduct(val),
                    ),
                  ),

                  // Tab bar (Shop vs Godown)
                  Obx(() {
                    if (!controller.isGodownEnabled.value) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      child: _ObxTabBar(controller: controller),
                    );
                  }),

                  // List / Grid body
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Obx(() {
                        if (controller.isDataLoading.value) {
                          return const Center(
                            child: CommonProgressBar(
                              size: 50,
                              color: AppColors.blackColor,
                            ),
                          );
                        }
                        final isGodown =
                            controller.isGodownEnabled.value &&
                            controller.selectedTab.value == 1;

                        // Desktop specific grid layout
                        return _ProductGridTab(
                          type: isGodown ? 'godown' : 'shop',
                          controller: controller,
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),

            // Right pane: Summary dashboard metrics
            Container(
              width: 320,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(left: BorderSide(color: Colors.grey.shade200)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stock Summary',
                    style: CustomTextStyle.customPoppin(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.blackColor,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Metric Card 1
                  _InventoryMetricCard(
                    title: 'Total Items',
                    value: controller.shopProductList.length.toString(),
                    icon: CupertinoIcons.cube_box_fill,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),

                  // Metric Card 2
                  _InventoryMetricCard(
                    title: 'Godown Stock',
                    value: controller.goDownProductList.length.toString(),
                    icon: CupertinoIcons.home,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 16),

                  // Quick tip
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade100),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          CupertinoIcons.lightbulb_fill,
                          color: Colors.amber,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Click on any product card on the left list to view details, update stocks, or download barcodes.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.amber.shade900,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return CommonAppbar(
      appBarLabel: 'Product List',
      secondActionChild: Obx(() {
        if (!controller.isInventoryScanSelected.value) {
          return const SizedBox.shrink();
        }
        final items = <AppPopupItem<_InventoryModeMenu>>[];
        if (controller.isClothingScanSelected.value) {
          items.add(
            const AppPopupItem(
              value: _InventoryModeMenu.scan,
              label: 'Scan',
              icon: CupertinoIcons.barcode_viewfinder,
              color: Color(0xFF1565C0),
            ),
          );
        }
        items.add(
          AppPopupItem(
            value: _InventoryModeMenu.manual,
            label: 'Manual',
            icon: CupertinoIcons.square_pencil_fill,
            color: const Color(0xFF2E7D32),
            isDividerAbove: controller.isInventoryScanSelected.value,
          ),
        );

        return AppPopupMenu<_InventoryModeMenu>(
          items: items,
          onSelected: (_InventoryModeMenu value) async {
            if (value == _InventoryModeMenu.scan) {
              var res = await AppRoutes.futureNavigationToRoute(
                routeName: AppRouteName.inventoryView,
                data: {'flag': true},
              );
              if (res == true) controller.fetchInventoryByTab('shop');
            } else {
              var res = await AppRoutes.futureNavigationToRoute(
                routeName: AppRouteName.generateBarcode,
                data: {'flag': true},
              );
              if (res == true) controller.fetchInventoryByTab('shop');
            }
          },
        );
      }),
      body: Column(
        children: [
          setHeight(height: 10),

          // ── Search bar ─────────────────────────────────────────────────
          CustomPadding(
            paddingOption: SymmetricPadding(horizontal: 12),
            child: CommonSearch(
              icon: Obx(
                () =>
                    controller.searchText.value.isNotEmpty
                        ? InkWell(
                          onTap: () {
                            controller.clear();
                            unfocus();
                          },
                          child: Icon(
                            CupertinoIcons.clear_circled_solid,
                            size: 20.sp,
                            color: AppColors.blackColor,
                          ),
                        )
                        : const SizedBox.shrink(),
              ),
              label: 'Search',
              hintText: 'search product',
              controller: controller.searchController,
              onChanged: (val) => controller.searchProduct(val),
            ),
          ),

          setHeight(height: 10),

          // ── Tab bar (pure Obx, no TabController) ───────────────────────
          Obx(() {
            if (!controller.isGodownEnabled.value) {
              return const SizedBox.shrink();
            }
            return _ObxTabBar(controller: controller);
          }),

          // ── Content ────────────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (controller.isDataLoading.value) {
                return const Center(
                  child: CommonProgressBar(
                    size: 50,
                    color: AppColors.blackColor,
                  ),
                );
              }
              final isGodown =
                  controller.isGodownEnabled.value &&
                  controller.selectedTab.value == 1;
              return _ProductListTab(
                type: isGodown ? 'godown' : 'shop',
                controller: controller,
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Pure Obx tab bar ─────────────────────────────────────────────────────────
class _ObxTabBar extends StatelessWidget {
  final InventoryListController controller;
  const _ObxTabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 10.h),
      child: Obx(() {
        final selected = controller.selectedTab.value;
        return Container(
          height: 42.h,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              _TabButton(
                label: 'Shop',
                isSelected: selected == 0,
                onTap: () => controller.switchTab(0),
              ),
              _TabButton(
                label: 'Godown',
                isSelected: selected == 1,
                onTap: () => controller.switchTab(1),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          margin: EdgeInsets.all(4.r),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.blackColor : Colors.transparent,
            borderRadius: BorderRadius.circular(9.r),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                    : [],
          ),
          child: Center(
            child: Text(
              label,
              style: CustomTextStyle.customPoppin(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Product list tab ─────────────────────────────────────────────────────────
class _ProductListTab extends StatelessWidget {
  final String type;
  final InventoryListController controller;

  const _ProductListTab({required this.type, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isShop = type == 'shop';
    final list =
        isShop ? controller.shopProductList : controller.goDownProductList;
    final scrollCtrl =
        isShop
            ? controller.shopScrollController
            : controller.godownScrollController;
    final emptyMsg =
        isShop ? 'No product found in SHOP.' : 'No product found in GODOWN.';

    return Obx(() {
      if (list.isEmpty) return CommonNoDataFound(message: emptyMsg);

      final q = controller.searchText.value.toLowerCase();
      final filtered =
          q.isEmpty
              ? list.toList()
              : list.where((item) {
                return (item.name ?? '').toLowerCase().contains(q) ||
                    (item.barcode ?? '').toLowerCase().contains(q) ||
                    (item.weight ?? '').toLowerCase().contains(q);
              }).toList();

      if (filtered.isEmpty) {
        return CommonNoDataFound(
          message: 'No results for "${controller.searchText.value}"',
        );
      }

      return ListView.builder(
        controller: scrollCtrl,
        itemCount: filtered.length + 1,
        itemBuilder: (context, index) {
          if (index == filtered.length) {
            return Obx(() {
              if (!controller.isLoadingMore.value) return setHeight(height: 16);
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: CommonProgressBar(
                    size: 30,
                    color: AppColors.blackColor,
                  ),
                ),
              );
            });
          }

          final item = filtered[index];
          return Hero(
            tag: 'herotag_${item.id ?? index}',
            child: InventroyListText(
              onTap: () async {
                customMessageOrErrorPrint(message: "List id: ${item.id}");
                var res = await AppRoutes.futureNavigationToRoute(
                  routeName: AppRouteName.productDetailView,
                  data: {'product': item, 'isProductLoosed': false},
                );
                if (res == true) {
                  controller.fetchInventoryByTab(type);
                }
              },
              isInventoryScanSelected: controller.isInventoryScanSelected.value,
              inventoryModel: item,
              shopType: controller.shopTypeEnum,
            ),
          );
        },
      );
    });
  }
}

class _ProductGridTab extends StatelessWidget {
  final String type;
  final InventoryListController controller;

  const _ProductGridTab({required this.type, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isShop = type == 'shop';
    final list =
        isShop ? controller.shopProductList : controller.goDownProductList;
    final scrollCtrl =
        isShop
            ? controller.shopScrollController
            : controller.godownScrollController;
    final emptyMsg =
        isShop ? 'No product found in SHOP.' : 'No product found in GODOWN.';

    return Obx(() {
      if (list.isEmpty) return CommonNoDataFound(message: emptyMsg);

      final q = controller.searchText.value.toLowerCase();
      final filtered =
          q.isEmpty
              ? list.toList()
              : list.where((item) {
                return (item.name ?? '').toLowerCase().contains(q) ||
                    (item.barcode ?? '').toLowerCase().contains(q) ||
                    (item.weight ?? '').toLowerCase().contains(q);
              }).toList();

      if (filtered.isEmpty) {
        return CommonNoDataFound(
          message: 'No results for "${controller.searchText.value}"',
        );
      }

      return GridView.builder(
        controller: scrollCtrl,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 400,
          mainAxisExtent: 130,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final item = filtered[index];
          return Hero(
            tag: 'herotag_${item.id ?? index}',
            child: InventroyListText(
              onTap: () async {
                customMessageOrErrorPrint(message: "List id: ${item.id}");
                await AppRoutes.futureNavigationToRoute(
                  routeName: AppRouteName.productDetailView,
                  data: {'product': item, 'isProductLoosed': false},
                );
              },
              isInventoryScanSelected: controller.isInventoryScanSelected.value,
              inventoryModel: item,
              shopType: controller.shopTypeEnum,
            ),
          );
        },
      );
    });
  }
}

class _InventoryMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _InventoryMetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: CustomTextStyle.customOpenSans(
                    fontSize: 12,
                    color: AppColors.greyColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: CustomTextStyle.customPoppin(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
