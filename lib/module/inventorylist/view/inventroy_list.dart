import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_container.dart';
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
                ? PopupMenuButton<_InventoryModeMenu>(
                  color: AppColors.whiteColor,
                  position: PopupMenuPosition.under,
                  borderRadius: BorderRadius.circular(200.r),
                  onSelected: (_InventoryModeMenu value) async {
                    if (value.name == 'scan') {
                      var res = await AppRoutes.futureNavigationToRoute(
                        routeName: AppRouteName.inventoryView,
                        data: {'flag': true},
                      );
                      if (res == true) controller.fetchInventoryByTab('shop');
                    } else {
                      await AppRoutes.futureNavigationToRoute(
                        routeName: AppRouteName.generateBarcode,
                        data: {'flag': true},
                      );
                    }
                  },
                  itemBuilder:
                      (context) => [
                        PopupMenuItem<_InventoryModeMenu>(
                          value: _InventoryModeMenu.scan,
                          child: Row(
                            children: [
                              Icon(CupertinoIcons.barcode_viewfinder),
                              setWidth(width: 8),
                              Text(
                                'Scan',
                                style: CustomTextStyle.customOpenSans(),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem<_InventoryModeMenu>(
                          value: _InventoryModeMenu.manual,
                          child: Row(
                            children: [
                              Icon(
                                CupertinoIcons.square_pencil_fill,
                                color: AppColors.blackColor,
                              ),
                              setWidth(width: 8),
                              Text(
                                'Manual',
                                style: CustomTextStyle.customOpenSans(),
                              ),
                            ],
                          ),
                        ),
                      ],
                  child: CommonContainer(
                    height: 30,
                    width: 30,
                    radius: 10,
                    color: AppColors.whiteColor,
                    child: Icon(
                      CupertinoIcons.ellipsis_vertical,
                      color: AppColors.blackColor,
                    ),
                  ),
                )
                : Container(),
      ),
      body: Obx(
        () =>
            controller.isDataLoading.value
                ? CommonProgressBar(size: 50, color: AppColors.blackColor)
                : Column(
                  children: [
                    setHeight(height: 10),
                    CustomPadding(
                      paddingOption: SymmetricPadding(horizontal: 12),
                      child: CommonSearch(
                        icon: Obx(
                          () => InkWell(
                            onTap:
                                controller.searchText.value.isNotEmpty
                                    ? () {
                                      controller.clear();
                                      unfocus();
                                    }
                                    : null,
                            child: Icon(
                              controller.searchText.value.isNotEmpty
                                  ? CupertinoIcons.clear
                                  : CupertinoIcons.search,
                            ),
                          ),
                        ),
                        label: 'Search',
                        hintText: 'search product',
                        controller: controller.searchController,
                        onChanged: (val) => controller.searchProduct(val),
                      ),
                    ),
                    setHeight(height: 10),
                    CommonContainer(
                      height: 40,
                      width: 350,
                      color: Colors.grey.shade300,
                      radius: 10,
                      child: Obx(
                        () {
                          final showGodown = controller.isGodownEnabled.value;
                          if (controller.tabController == null) {
                            return const SizedBox.shrink();
                          }
                          return TabBar(
                            controller: controller.tabController,
                            indicatorSize: TabBarIndicatorSize.tab,
                            unselectedLabelStyle:
                                CustomTextStyle.customPoppin(),
                            labelStyle: CustomTextStyle.customPoppin(
                              color: AppColors.whiteColor,
                            ),
                            indicatorPadding:
                                SymmetricPadding(
                                  horizontal: 10,
                                  vertical: 5,
                                ).getPadding(),
                            dividerHeight: 0.0,
                            indicator: BoxDecoration(
                              color: AppColors.blackColor,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            tabs:
                                showGodown
                                    ? const [
                                      Tab(child: Text('Shop')),
                                      Tab(child: Text('Godown')),
                                    ]
                                    : const [Tab(child: Text('Shop'))],
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: Obx(
                        () {
                          final showGodown = controller.isGodownEnabled.value;
                          if (controller.tabController == null) {
                            return const SizedBox.shrink();
                          }
                          return TabBarView(
                            controller: controller.tabController,
                            children:
                                showGodown
                                    ? [
                                      _ProductListTab(
                                        type: 'shop',
                                        controller: controller,
                                      ),
                                      _ProductListTab(
                                        type: 'godown',
                                        controller: controller,
                                      ),
                                    ]
                                    : [
                                      _ProductListTab(
                                        type: 'shop',
                                        controller: controller,
                                      ),
                                    ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}

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

      final filtered =
          list.where((item) {
            final q = controller.searchText.value.toLowerCase();
            if (q.isEmpty) return true;
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
        // +1 for the bottom loader row
        itemCount: filtered.length + 1,
        itemBuilder: (context, index) {
          // Last item — pagination loader
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
