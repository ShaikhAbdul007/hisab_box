import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_button.dart';
import 'package:inventory/common_widget/common_calender.dart';
import 'package:inventory/common_widget/common_dropdown.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/common_progressbar.dart';
import 'package:inventory/common_widget/common_switch.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/common_widget/textfiled.dart';
import 'package:inventory/helper/app_message.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/module/product_details/controller/controller.dart';
import 'package:inventory/module/product_details/widget/inventory_bottomsheep_component_text.dart';

class PetShopProductViewComponent extends StatelessWidget {
  final ProductController controller;
  final BuildContext context;
  final GlobalKey<FormState> formkeys;
  const PetShopProductViewComponent({
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
              Row(
                children: [
                  Flexible(child: _categoryDropdown()),
                  Flexible(child: _animalTypeDropdown()),
                ],
              ),
              Row(
                children: [
                  Flexible(child: _stockField()),
                  Flexible(child: _isLooseDropdown()),
                ],
              ),
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
              Row(
                children: [
                  Flexible(child: _rackField()),
                  Flexible(child: _locationDropdown()),
                ],
              ),
              Row(
                children: [
                  Flexible(child: _purchaseDateField(context)),
                  Flexible(child: _expiryDateField(context)),
                ],
              ),
              Obx(
                () =>
                    controller.isFlavorAndWeightNotRequired.value
                        ? InventoryBottomsheetComponentText(
                          hintText1: 'Enter flavor',
                          label1: 'Flavor',
                          controller1: controller.flavor,
                          validator1: (v) => v!.isEmpty ? emptyflavor : null,
                          hintText2: 'Enter weight',
                          label2: 'Weight',
                          controller2: controller.weight,
                          validator2: (v) => v!.isEmpty ? emptyWeight : null,
                        )
                        : const SizedBox.shrink(),
              ),
              Obx(
                () => CustomPadding(
                  paddingOption: SymmetricPadding(horizontal: 15.0),
                  child: CommonSwitch(
                    labelSize: 12,
                    label: 'Flavor & Weight Required',
                    value: controller.isFlavorAndWeightNotRequired.value,
                    onChanged: (_) {
                      controller.isFlavorAndWeightNotRequired.value =
                          !controller.isFlavorAndWeightNotRequired.value;
                    },
                  ),
                ),
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
                          "stock_type": "packet",
                          "isloosed": controller.isLoose,
                          "isflavorRequired":
                              controller.isFlavorAndWeightNotRequired.value,
                          "purchase_date": parseAppDate(
                            controller.purchaseDate.text,
                          ),
                          "expiry_date": parseAppDate(
                            controller.exprieDate.text,
                          ),
                          "category_id":
                              controller.selectedCategoryId.value ?? '',
                          "animal_type_id":
                              controller.selectedAnimalTypeId.value ?? '',
                          "flavour": controller.flavor.text,
                          "level": controller.level.text,
                          "rack": controller.rack.text,
                          "weight": controller.weight.text,
                          "discount": controller.discount.text,
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

  Widget _animalTypeDropdown() {
    return Obx(
      () =>
          controller.animalCategoryListLoading.value
              ? Center(child: CommonProgressBar(color: AppColors.blackColor))
              : controller.animalTypeList.isEmpty
              ? CustomDropDown(
                listItems: controller.animalTypeList,
                hintText: 'Add Animal Category First',
                notifyParent: (_) {},
              )
              : CustomDropDown(
                selectedDropDownItem: controller.selectedAnimalTypeId.value,
                hintText: 'Animal Type',
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

  Widget _isLooseDropdown() {
    return CustomStaticDropDown(
      listItems: const [true, false],
      hintText: 'Select isLoose',
      notifyParent: (val) => controller.isLoose = val,
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

  Widget _expiryDateField(BuildContext context) {
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
            if (res.isNotEmpty) controller.exprieDate.text = res;
          },
          child: const Icon(CupertinoIcons.calendar_today, size: 20),
        ),
      ),
      validator: (v) => v!.isEmpty ? emptyExpire : null,
      contentPadding: SymmetricPadding(vertical: 5, horizontal: 5).getPadding(),
      hintText: 'dd-MM-yyyy',
      label: 'Expire Date',
      controller: controller.exprieDate,
    );
  }
}
