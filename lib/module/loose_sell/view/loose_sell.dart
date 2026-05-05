import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/module/loose_sell/widget/loose_inventroy_list_text.dart';
import '../../../common_widget/colors.dart';
import '../../../common_widget/common_container.dart';
import '../../../common_widget/common_nodatafound.dart';
import '../../../common_widget/common_progressbar.dart';
import '../../../common_widget/search.dart';
import '../../../common_widget/size.dart';
import '../../../helper/helper.dart';
import '../../../helper/shop_type.dart';
import '../../../routes/route_name.dart';
import '../../../routes/routes.dart';
import '../controller/loose_controller.dart';

class LooseSell extends GetView<LooseController> {
  const LooseSell({super.key});

  @override
  Widget build(BuildContext context) {
    final isClothing = controller.shopTypeEnum == ShopType.clothingShop;
    return CommonAppbar(
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
      appBarLabel: isClothing ? 'Good Return (GR)' : 'Loose Inventory',
      body: Obx(() {
        if (controller.isDataLoading.value) {
          return CommonProgressBar(size: 50, color: AppColors.blackColor);
        }

        if (isClothing) {
          if (controller.grnList.isEmpty) {
            return CommonNoDataFound(message: 'No GR found');
          }
          return ListView.builder(
            itemCount: controller.grnList.length,
            itemBuilder: (context, index) {
              final grn = controller.grnList[index];
              return GrListText(
                inventoryModel: grn,
                shopType: controller.shopTypeEnum,
              );
            },
          );
        }

        if (controller.looseCategoryModelList.isEmpty) {
          return CommonNoDataFound(message: 'No product found');
        }

        return Column(
          children: [
            setHeight(height: 10),
            Expanded(
              flex: 2,
              child: CustomPadding(
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
            ),
            Expanded(
              flex: 19,
              child: ListView.builder(
                itemCount: controller.looseCategoryModelList.length,
                itemBuilder: (context, index) {
                  var inventoryList = controller.looseCategoryModelList[index];
                  String name = inventoryList.name?.toLowerCase() ?? '';
                  String barcode = inventoryList.barcode?.toLowerCase() ?? '';
                  return Obx(
                    () =>
                        name.toLowerCase().contains(
                                  controller.searchText.value,
                                ) ||
                                barcode.toLowerCase().contains(
                                  controller.searchController.value.text,
                                )
                            ? LooseInventroyListText(
                              onTap: () async {
                                var res =
                                    await AppRoutes.futureNavigationToRoute(
                                      routeName: AppRouteName.productDetailView,
                                      data: {
                                        'product': inventoryList,
                                        'isProductLoosed': true,
                                      },
                                    );
                                if (res == true) {
                                  controller.fetchLooseList();
                                }
                              },
                              isInventoryScanSelected: true,
                              inventoryModel: inventoryList,
                              shopType: controller.shopTypeEnum,
                            )
                            : Container(),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
