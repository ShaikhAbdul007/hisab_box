import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/module/out_of_stock/controller/out_of_stock_controller.dart';
import '../../../common_widget/colors.dart';
import '../../../common_widget/common_nodatafound.dart';
import '../../../common_widget/common_progressbar.dart';
import '../../../common_widget/search.dart';
import '../../../common_widget/size.dart';
import '../../../helper/helper.dart';
import '../widget/out_of_stock_inventory_list_text.dart';

class OutOfStockView extends GetView<OutOfStockController> {
  const OutOfStockView({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      appBarLabel: 'Out Of Stock',
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
                      child: CustomPadding(
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
                                    ? Obx(
                                      () => OutOfStockInventoryListText(
                                        isDeleteLoading:
                                            controller.isDeleteLoading.value,
                                        inventoryModel: inventoryList,
                                        deleteOnTap: () {
                                          controller.deactivateSpecificProduct(
                                            productId:
                                                controller
                                                    .productList[index]
                                                    .id ??
                                                '',
                                          );
                                        },
                                      ),
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
}
