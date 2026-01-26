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
import '../controller/inventory_controller.dart';
import '../widget/inventory_list_text.dart';

class InventroyList extends GetView<InventoryListController> {
  const InventroyList({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      appBarLabel: 'Product List',
      secondActionChild: Obx(
        () =>
            controller.isInventoryScanSelected.value
                ? InkWell(
                  onTap: () async {
                    var res = await AppRoutes.futureNavigationToRoute(
                      routeName: AppRouteName.inventoryView,
                      data: {'flag': true},
                    );
                    if (res == true) {
                      // await controller.fetchAllProducts();
                    }
                  },
                  child: CommonContainer(
                    height: 40,
                    width: 40,
                    radius: 10,
                    color: AppColors.whiteColor,
                    child: Icon(
                      CupertinoIcons.barcode_viewfinder,
                      color: AppColors.blackColor,
                    ),
                  ),
                )
                : Container(),
      ),
      body: Obx(
        () =>
            controller.isDataLoading.value
                ? CommonProgressbar(size: 50, color: AppColors.blackColor)
                : controller.productList.isNotEmpty
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
                                        inventoryList.name!
                                                    .toLowerCase()
                                                    .contains(
                                                      controller
                                                          .searchText
                                                          .value,
                                                    ) ||
                                                inventoryList.barcode!
                                                    .toLowerCase()
                                                    .contains(
                                                      controller
                                                          .searchController
                                                          .value
                                                          .text,
                                                    ) ||
                                                inventoryList.weight!
                                                    .toLowerCase()
                                                    .contains(
                                                      controller
                                                          .searchController
                                                          .value
                                                          .text,
                                                    ) ||
                                                inventoryList.category!
                                                    .toLowerCase()
                                                    .contains(
                                                      controller
                                                          .searchController
                                                          .value
                                                          .text,
                                                    ) ||
                                                inventoryList.flavor!
                                                    .toLowerCase()
                                                    .contains(
                                                      controller
                                                          .searchController
                                                          .value
                                                          .text,
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
                                                  // if (res == true) {
                                                  //   await controller
                                                  //       .fetchAllProducts();
                                                  // }
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
                              : CommonNodatafound(
                                message: 'No product found in SHOP.',
                              ),
                          controller.goDownProductList.isEmpty
                              ? CommonNodatafound(
                                message: 'No product found in SHOP.',
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
                                                    ) ||
                                                goDownInventoryList.category!
                                                    .toLowerCase()
                                                    .contains(
                                                      controller
                                                          .searchController
                                                          .value
                                                          .text,
                                                    ) ||
                                                goDownInventoryList.flavor!
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
                : CommonNodatafound(message: 'No product found'),
      ),
    );
  }
}
