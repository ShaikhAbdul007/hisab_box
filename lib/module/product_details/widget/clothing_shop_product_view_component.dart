import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_button.dart';
import 'package:inventory/common_widget/common_calender.dart';
import 'package:inventory/common_widget/common_dropdown.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/common_progressbar.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/common_widget/textfiled.dart';
import 'package:inventory/helper/app_message.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/module/product_details/controller/controller.dart';
import 'package:inventory/module/product_details/widget/inventory_bottomsheep_component_text.dart';

class ClothingShopProductViewComponent extends StatelessWidget {
  final ProductController controller;
  final BuildContext context;
  final GlobalKey<FormState> formkeys;
  const ClothingShopProductViewComponent({
    super.key,
    required this.controller,
    required this.context,
    required this.formkeys,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.inventoryScanKey,
      child: CustomPadding(
        paddingOption: SymmetricPadding(horizontal: 10.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 10,
            children: [
              // Barcode + Product Name
              InventoryBottomsheetComponentText(
                readOnly1: true,
                controller1: controller.barcode,
                controller2: controller.productName,
                label1: 'Barcode',
                hintText1: 'Enter barcode',
                hintText2: 'Enter product name',
                label2: 'Product Name',
                validator2: (v) => v!.isEmpty ? emptyProductName : null,
              ),
              // Category + Size
              Row(
                children: [
                  Flexible(child: _categoryDropdown()),
                  Flexible(child: _sizeDropdown()),
                ],
              ),
              // Color + Brand Type
              Row(
                children: [
                  Flexible(child: _colorDropdown()),
                  Flexible(child: _brandTypeDropdown()),
                ],
              ),
              // Stock + Location
              Row(
                children: [
                  Flexible(child: _stockField()),
                  Flexible(child: _locationDropdown()),
                ],
              ),
              // Selling + Purchase price
              InventoryBottomsheetComponentText(
                inputLength1: 10,
                keyboardType1: TextInputType.number,
                hintText1: 'Selling Price (sp)',
                label1: 'Selling Price (₹)',
                controller1: controller.sellingPrice,
                validator1: (v) => v!.isEmpty ? emptyProductSellingPrice : null,
                inputLength2: 10,
                keyboardType2: TextInputType.number,
                hintText2: 'Purchase Price (mrp)',
                label2: 'Purchase Price (₹)',
                controller2: controller.purchasePrice,
                validator2:
                    (v) => v!.isEmpty ? emptyProductPurchasePrice : null,
                onChanged1: (_) => controller.calculatePurchasePrice(),
              ),
              // Discount + Level
              InventoryBottomsheetComponentText(
                inputLength1: 2,
                keyboardType1: TextInputType.number,
                hintText1: 'Enter discount',
                label1: 'Discount (%)',
                controller1: controller.discount,
                validator1: (v) => v!.isEmpty ? emptyDiscount : null,
                hintText2: 'Level',
                label2: 'Level',
                controller2: controller.level,
              ),
              // Rack + Purchase Date
              Row(
                children: [
                  Flexible(child: _rackField()),
                  Flexible(child: _purchaseDateField(context)),
                ],
              ),
              setHeight(height: 5),
              Obx(
                () => CommonButton(
                  isLoading: controller.isSaveLoading.value,
                  label: saveButton,
                  onTap: () async {
                    if (controller.inventoryScanKey.currentState!.validate()) {
                      unfocus();
                      controller.saveNewProduct(
                        body: {
                          "name": controller.productName.text,
                          "barcodes": controller.barcode.text,
                          "quantity": controller.quantity.text,
                          "selling_price": controller.sellingPrice.text,
                          "purchase_price": controller.purchasePrice.text,
                          "location": controller.location.text.toLowerCase(),
                          "stock_type": "clothing",
                          "category_id":
                              controller.selectedCategoryId.value ?? '',
                          "size_id":
                              controller.selectedAnimalTypeId.value ?? '',
                          "color_id": controller.selectedColorId.value ?? '',
                          "brand": controller.brandType.value,
                          "level": controller.level.text,
                          "rack": controller.rack.text,
                          "discount": controller.discount.text,
                          "purchase_date": parseAppDate(
                            controller.purchaseDate.text,
                          ),
                        },
                      );
                    }
                  },
                ),
              ),
              setHeight(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryDropdown() {
    return Obx(
      () =>
          controller.categoryListLoading.value
              ? Center(child: CommonProgressBar(color: AppColors.blackColor))
              : controller.categoryList.isEmpty
              ? CustomDropDown(
                listItems: controller.categoryList,
                hintText: 'Add Category First',
                notifyParent: (_) {},
              )
              : CustomDropDown(
                selectedDropDownItem: controller.selectedCategoryId.value,
                listItems: controller.categoryList,
                hintText: 'Category',
                notifyParent: (val) {
                  controller.selectedCategoryId.value = val;
                  final match = controller.categoryList
                      .cast<dynamic>()
                      .firstWhere((e) => e.id == val, orElse: () => null);
                  controller.category.text = match?.name ?? '';
                },
              ),
    );
  }

  Widget _sizeDropdown() {
    return Obx(
      () =>
          controller.animalCategoryListLoading.value
              ? Center(child: CommonProgressBar(color: AppColors.blackColor))
              : controller.animalTypeList.isEmpty
              ? CustomDropDown(
                listItems: controller.animalTypeList,
                hintText: 'Add Size First',
                notifyParent: (_) {},
              )
              : CustomDropDown(
                selectedDropDownItem: controller.selectedAnimalTypeId.value,
                hintText: 'Size',
                listItems: controller.animalTypeList,
                notifyParent: (val) {
                  controller.selectedAnimalTypeId.value = val;
                  final match = controller.animalTypeList
                      .cast<dynamic>()
                      .firstWhere((e) => e.id == val, orElse: () => null);
                  controller.animalType.text = match?.name ?? '';
                },
              ),
    );
  }

  Widget _colorDropdown() {
    return Obx(
      () =>
          controller.colorListLoading.value
              ? Center(child: CommonProgressBar(color: AppColors.blackColor))
              : controller.colorList.isEmpty
              ? CustomDropDown(
                listItems: controller.colorList,
                hintText: 'Add Color First',
                notifyParent: (_) {},
              )
              : CustomDropDown(
                selectedDropDownItem: controller.selectedColorId.value,
                hintText: 'Color',
                listItems: controller.colorList,
                notifyParent: (val) {
                  controller.selectedColorId.value = val;
                  final match = controller.colorList.cast<dynamic>().firstWhere(
                    (e) => e.id == val,
                    orElse: () => null,
                  );
                  controller.color.text = match?.name ?? '';
                },
              ),
    );
  }

  Widget _brandTypeDropdown() {
    return Obx(
      () => CustomStaticDropDown(
        selectedDropDownItem:
            ['Normal', 'Imp'].contains(controller.brandType.value)
                ? controller.brandType.value
                : null,
        listItems: const ['Normal', 'Imp'],
        hintText: 'Brand Type',
        notifyParent:
            (val) => controller.brandType.value = (val ?? '').toString(),
      ),
    );
  }

  Widget _stockField() {
    return CommonTextField(
      validator: (v) => v!.isEmpty ? emptyProductQuantity : null,
      contentPadding: SymmetricPadding(vertical: 5, horizontal: 5).getPadding(),
      inputLength: 5,
      keyboardType: TextInputType.number,
      hintText: 'Enter stock',
      label: 'Stock',
      controller: controller.quantity,
    );
  }

  Widget _locationDropdown() {
    return Obx(
      () => CustomStaticDropDown(
        selectedDropDownItem:
            controller.locationOptions.contains(controller.location.text)
                ? controller.location.text
                : null,
        listItems: controller.locationOptions,
        hintText: 'Location',
        notifyParent: (val) => controller.location.text = val?.toString() ?? '',
      ),
    );
  }

  Widget _rackField() {
    return CommonTextField(
      contentPadding: SymmetricPadding(vertical: 5, horizontal: 5).getPadding(),
      hintText: 'Rack',
      label: 'Rack',
      controller: controller.rack,
    );
  }

  Widget _purchaseDateField(BuildContext context) {
    return CommonTextField(
      readOnly: true,
      suffixIcon: CustomPadding(
        paddingOption: OnlyPadding(right: 10),
        child: InkWell(
          onTap: () async {
            final res = await customDatePicker(
              lastDate: DateTime(2040),
              context: context,
              selectedDate: DateTime.now(),
              controller: controller.dayDate,
            );
            if (res.isNotEmpty) controller.purchaseDate.text = res;
          },
          child: const Icon(CupertinoIcons.calendar_today, size: 20),
        ),
      ),
      validator: (v) => v!.isEmpty ? emptyPurchase : null,
      contentPadding: SymmetricPadding(vertical: 5, horizontal: 5).getPadding(),
      hintText: 'dd-MM-yyyy',
      label: 'Purchase Date',
      controller: controller.purchaseDate,
    );
  }
}
