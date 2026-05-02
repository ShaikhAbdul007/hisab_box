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
      // firstActionChild: Obx(
      //   () =>
      //       controller.isInventoryScanSelected.value
      //           ? InkWell(
      //             onTap: () async {
      //               var res = await AppRoutes.futureNavigationToRoute(
      //                 routeName: AppRouteName.inventoryView,
      //                 data: {'flag': true},
      //               );
      //               if (res == true) {
      //                 controller.fetchAllInventory();
      //               }
      //             },
      //             child: CommonContainer(
      //               height: 40,
      //               width: 40,
      //               radius: 10,
      //               color: AppColors.whiteColor,
      //               child: Icon(
      //                 CupertinoIcons.barcode_viewfinder,
      //                 color: AppColors.blackColor,
      //               ),
      //             ),
      //           )
      //           : Container(),
      // ),
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
                      if (res == true) {
                        controller.fetchInventoryByTab('shop');
                      }
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
                : controller.shopProductList.isNotEmpty
                ? Column(
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
                      child: TabBar(
                        controller: controller.tabController,
                        indicatorSize: TabBarIndicatorSize.tab,
                        unselectedLabelStyle: CustomTextStyle.customPoppin(),
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
                        tabs: [
                          Tab(child: Text('Shop')),
                          Tab(child: Text('Godown')),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: controller.tabController,
                        children: [
                          controller.shopProductList.isNotEmpty
                              ? ListView.builder(
                                itemCount: controller.shopProductList.length,
                                itemBuilder: (context, index) {
                                  var inventoryList =
                                      controller.shopProductList[index];
                                  return Obx(
                                    () =>
                                        (inventoryList.name ?? '')
                                                    .toLowerCase()
                                                    .contains(
                                                      controller
                                                          .searchText
                                                          .value
                                                          .toLowerCase(),
                                                    ) ||
                                                (inventoryList.barcode ?? '')
                                                    .toLowerCase()
                                                    .contains(
                                                      controller
                                                          .searchController
                                                          .text
                                                          .toLowerCase(),
                                                    ) ||
                                                (inventoryList.weight ?? '')
                                                    .toLowerCase()
                                                    .contains(
                                                      controller
                                                          .searchController
                                                          .text
                                                          .toLowerCase(),
                                                    )
                                            ? Hero(
                                              tag:
                                                  'herotag_${inventoryList.name ?? UniqueKey()}',
                                              child: InventroyListText(
                                                onTap: () async {
                                                  customMessageOrErrorPrint(
                                                    message:
                                                        "List id: ${inventoryList.id}",
                                                  );

                                                  var res =
                                                      await AppRoutes.futureNavigationToRoute(
                                                        routeName:
                                                            AppRouteName
                                                                .productDetailView,
                                                        data: {
                                                          'product':
                                                              inventoryList,
                                                          'isProductLoosed':
                                                              false,
                                                        },
                                                      );
                                                },
                                                isInventoryScanSelected:
                                                    controller
                                                        .isInventoryScanSelected
                                                        .value,
                                                inventoryModel: inventoryList,
                                              ),
                                            )
                                            : Container(),
                                  );
                                },
                              )
                              : CommonNoDataFound(
                                message: 'No product found in SHOP.',
                              ),
                          controller.goDownProductList.isEmpty
                              ? CommonNoDataFound(
                                message: 'No product found in GODOWN.',
                              )
                              : ListView.builder(
                                itemCount: controller.goDownProductList.length,
                                itemBuilder: (context, index) {
                                  var goDownInventoryList =
                                      controller.goDownProductList[index];
                                  return Obx(
                                    () =>
                                        goDownInventoryList.name!
                                                    .toLowerCase()
                                                    .contains(
                                                      controller
                                                          .searchText
                                                          .value,
                                                    ) ||
                                                goDownInventoryList.barcode!
                                                    .toLowerCase()
                                                    .contains(
                                                      controller
                                                          .searchController
                                                          .value
                                                          .text,
                                                    ) ||
                                                goDownInventoryList.weight!
                                                    .toLowerCase()
                                                    .contains(
                                                      controller
                                                          .searchController
                                                          .value
                                                          .text,
                                                    )
                                            ? Hero(
                                              tag: 'herotag_${UniqueKey()}',
                                              child: InventroyListText(
                                                onTap: () async {
                                                  customMessageOrErrorPrint(
                                                    message:
                                                        "List id: ${goDownInventoryList.id}",
                                                  );
                                                  var res =
                                                      await AppRoutes.futureNavigationToRoute(
                                                        routeName:
                                                            AppRouteName
                                                                .productDetailView,
                                                        data: {
                                                          'product':
                                                              goDownInventoryList,
                                                          'isProductLoosed':
                                                              false,
                                                        },
                                                      );
                                                  if (res == true) {
                                                    //
                                                  }
                                                },
                                                isInventoryScanSelected:
                                                    controller
                                                        .isInventoryScanSelected
                                                        .value,
                                                inventoryModel:
                                                    goDownInventoryList,
                                              ),
                                            )
                                            : Container(),
                                  );
                                },
                              ),
                        ],
                      ),
                    ),
                  ],
                )
                : CommonNoDataFound(message: 'No product found'),
      ),
    );
  }
}
