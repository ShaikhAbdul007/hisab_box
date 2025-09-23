import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_container.dart';
import 'package:inventory/common_widget/common_nodatafound.dart';
import 'package:inventory/common_widget/common_progressbar.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/module/inventorylist/widget/inventory_update_popup_component.dart';
import 'package:inventory/responsive_layout/responsive_screens/mobile.dart';
import 'package:inventory/responsive_layout/responsive_tempate.dart';
import '../../../common_widget/search.dart';
import '../../../helper/textstyle.dart';
import '../../../routes/routes.dart';
import '../controller/inventory_controller.dart';
import '../widget/inventory_list_text.dart';

class InventroyList extends GetView<InventoryListController> {
  const InventroyList({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveTemplate(
      desktop: DesktopScreen(controller: controller),
      tablet: MobileScreen(controller: controller),
      mobile: MobileScreen(controller: controller),
    );
  }
}

class DesktopScreen extends StatelessWidget {
  final InventoryListController controller;
  const DesktopScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      appBarLabel: 'Inventroy List',
      firstActionChild: SizedBox(
        width: 500,
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
                      await controller.fetchAllProducts();
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
                    Expanded(
                      flex: 19,
                      child: ListView.builder(
                        itemCount: controller.productList.length,
                        itemBuilder: (context, index) {
                          var inventoryList = controller.productList[index];
                          return Obx(
                            () =>
                                inventoryList.name!.toLowerCase().contains(
                                          controller.searchText.value,
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
                                    ? InventroyListText(
                                      onTap: () {
                                        controller.setQuantitydata(index);
                                        updateDataDialog(index);
                                      },
                                      isInventoryScanSelected:
                                          controller
                                              .isInventoryScanSelected
                                              .value,
                                      inventoryModel: inventoryList,
                                    )
                                    : Container(),
                          );
                        },
                      ),
                    ),
                  ],
                )
                : CommonNodatafound(message: 'No product found'),
      ),
    );
  }

  void updateDataDialog(int index) {
    Get.defaultDialog(
      title: '',
      titleStyle: CustomTextStyle.customNato(fontSize: 0),
      titlePadding: EdgeInsets.zero,
      barrierDismissible: false,
      content: InventoryUpdatePopupComponent(
        controller: controller,
        index: index,
      ),
    );
  }
}

class MobileScreen extends StatelessWidget {
  final InventoryListController controller;
  const MobileScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      appBarLabel: 'Inventroy List',
      // firstActionChild: Obx(
      //   () =>
      //       controller.isInventoryScanSelected.value
      //           ? InkWell(
      //             onTap: () {
      //               controller.importProductsFromExcel();
      //             },
      //             child: CommonContainer(
      //               height: 40,
      //               width: 40,
      //               radius: 10,
      //               color: AppColors.greenColorShade100,
      //               child: Icon(
      //                 CupertinoIcons.doc,
      //                 color: AppColors.blackColor,
      //               ),
      //             ),
      //           )
      //           : Container(),
      // ),
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
                      await controller.fetchAllProducts();
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
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
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
                    ),
                    Expanded(
                      flex: 19,
                      child: ListView.builder(
                        itemCount: controller.productList.length,
                        itemBuilder: (context, index) {
                          var inventoryList = controller.productList[index];
                          return Obx(
                            () =>
                                inventoryList.name!.toLowerCase().contains(
                                          controller.searchText.value,
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
                                    ? InventroyListText(
                                      onTap: () {
                                        controller.setQuantitydata(index);
                                        updateDataDialog(index);
                                      },
                                      isInventoryScanSelected:
                                          controller
                                              .isInventoryScanSelected
                                              .value,
                                      inventoryModel: inventoryList,
                                    )
                                    : Container(),
                          );
                        },
                      ),
                    ),
                  ],
                )
                : CommonNodatafound(message: 'No product found'),
      ),
    );
  }

  void updateDataDialog(int index) {
    Get.defaultDialog(
      title: '',
      titleStyle: CustomTextStyle.customNato(fontSize: 0),
      titlePadding: EdgeInsets.zero,
      barrierDismissible: false,
      content: InventoryUpdatePopupComponent(
        controller: controller,
        index: index,
      ),
    );
  }
}
