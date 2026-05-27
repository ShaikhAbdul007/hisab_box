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

enum _InventoryModeMenu { scan, manual }

class InventroyList extends GetView<InventoryListController> {
  const InventroyList({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      appBarLabel: 'Product List',
      secondActionChild: Obx(
        () =>
            controller.isInventoryScanSelected.value
                ? AppPopupMenu<_InventoryModeMenu>(
                  items: const [
                    AppPopupItem(
                      value: _InventoryModeMenu.scan,
                      label: 'Scan',
                      icon: CupertinoIcons.barcode_viewfinder,
                      color: Color(0xFF1565C0),
                    ),
                    AppPopupItem(
                      value: _InventoryModeMenu.manual,
                      label: 'Manual',
                      icon: CupertinoIcons.square_pencil_fill,
                      color: Color(0xFF2E7D32),
                      isDividerAbove: true,
                    ),
                  ],
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
                )
                : const SizedBox.shrink(),
      ),
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
