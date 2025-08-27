import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/module/loose_sell/widget/loose_inventroy_list_text.dart';
import '../../../common_widget/colors.dart';
import '../../../common_widget/common_container.dart';
import '../../../common_widget/common_nodatafound.dart';
import '../../../common_widget/common_progressbar.dart';
import '../../../common_widget/search.dart';
import '../../../common_widget/size.dart';
import '../../../helper/helper.dart';
import '../../../helper/textstyle.dart';
import '../../../routes/routes.dart';
import '../controller/loose_controller.dart';
import '../widget/loose_inventroy_update_popup_component.dart';

class LooseSell extends GetView<LooseController> {
  const LooseSell({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      // firstActionChild: AddExpensesButton(
      //   onTap: () {
      //     Get.bottomSheet(
      //       backgroundColor: AppColors.whiteColor,
      //       enableDrag: false,
      //       isDismissible: false,
      //       LooseSellBottomsheetComponent(
      //         controller: controller,
      //         formkeys: inventoryScanKey,
      //       ),
      //     );
      //   },
      // ),
      secondActionChild: InkWell(
        onTap: () async {
          var res = await AppRoutes.futureNavigationToRoute(
            routeName: AppRouteName.inventoryView,
            data: {'flag': false, 'navigate': 'loose'},
          );
          if (res == true) {
            await controller.fetchLooseProduct();
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
      ),
      appBarLabel: 'Loose Sell',
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
                                            )
                                    ? LooseInventroyListText(
                                      onTap: () {
                                        controller.setQuantitydata(index);
                                        updateDataDialog(index);
                                      },
                                      isInventoryScanSelected: true,
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
      content: LooseInventoryUpdatePopupComponent(
        controller: controller,
        index: index,
      ),
    );
  }
}
