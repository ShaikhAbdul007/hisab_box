import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/helper/shop_type.dart';
import 'package:inventory/module/product_details/widget/clothing_gr_product_view_component.dart';
import 'package:inventory/module/product_details/widget/clothing_shop_product_view_component.dart';
import 'package:inventory/module/product_details/widget/pet_shop_loosed_product_view_component.dart';
import 'package:inventory/module/product_details/widget/pet_shop_product_view_component.dart';
import '../controller/controller.dart';

class ProductView extends GetView<ProductController> {
  const ProductView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => CommonAppbar(
        isleadingButtonRequired: true,
        backgroundColor: AppColors.whiteColor,
        appBarLabel: _appBarLabel(
          shopType: controller.shopTypeEnum,
          isLoosed: controller.loosedProduct.value,
        ),
        body: _buildProductView(context),
      ),
    );
  }

  /// Returns the correct appbar label based on shopType + loosedProduct
  String _appBarLabel({required ShopType shopType, required bool isLoosed}) {
    switch (shopType) {
      case ShopType.clothingShop:
        return isLoosed ? 'Add GR Product' : 'Add Product';
      case ShopType.petShop:
        return isLoosed ? 'Add Loose Product' : 'Add Product';
    }
  }

  /// Returns the correct component based on shopType + loosedProduct
  Widget _buildProductView(BuildContext context) {
    final shopType = controller.shopTypeEnum;
    final isLoosed = controller.loosedProduct.value;
    final formKey = controller.inventoryScanKey;

    switch (shopType) {
      case ShopType.clothingShop:
        return isLoosed
            ? ClothingGrProductViewComponent(
              controller: controller,
              context: context,
              formkeys: formKey,
            )
            : ClothingShopProductViewComponent(
              controller: controller,
              context: context,
              formkeys: formKey,
            );
      case ShopType.petShop:
        return isLoosed
            ? PetShopLoosedProductViewComponent(
              controller: controller,
              context: context,
              formkeys: formKey,
            )
            : PetShopProductViewComponent(
              controller: controller,
              context: context,
              formkeys: formKey,
            );
    }
  }
}
