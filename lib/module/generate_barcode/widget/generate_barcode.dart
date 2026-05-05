import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/common_progressbar.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/helper/shop_type.dart';
import 'package:inventory/module/product_details/widget/product_field_card.dart';
import '../../../common_widget/colors.dart';
import '../../../common_widget/common_button.dart';
import '../../../common_widget/common_calender.dart';
import '../../../common_widget/common_dropdown.dart';
import '../../../common_widget/common_switch.dart';
import '../../../common_widget/textfiled.dart';
import '../../../helper/app_message.dart';
import '../../../helper/helper.dart';
import '../../product_details/widget/inventory_bottomsheep_component_text.dart';
import '../controller/generate_barcode_controller.dart';

class GenerateBarcodeComponent extends StatelessWidget {
  final GenerateBarcodeController controller;
  const GenerateBarcodeComponent({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: controller.inventoryScanKey,
        child: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding:
                    SymmetricPadding(horizontal: 14, vertical: 14).getPadding(),
                child: _buildFormBody(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Switch on shopType — same pattern as product_view.dart
  Widget _buildFormBody(BuildContext context) {
    switch (controller.shopTypeEnum) {
      case ShopType.clothingShop:
        return _clothingForm(context);
      case ShopType.petShop:
        return _petShopForm(context);
    }
  }

  // ── Pet Shop form ─────────────────────────────────────────────────────────
  Widget _petShopForm(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Product Info
        ProductFieldCard(
          icon: CupertinoIcons.barcode,
          iconColor: const Color(0xFF1565C0),
          title: 'Product Info',
          child: Column(
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
              setHeight(height: 8),
              Row(
                children: [
                  Flexible(child: _categoryDropdown()),
                  Flexible(child: _secondaryDropdown(hint: 'Animal Category')),
                ],
              ),
              setHeight(height: 8),
              Row(
                children: [
                  Flexible(child: _stockField()),
                  Flexible(child: _isLooseDropdown()),
                ],
              ),
            ],
          ),
        ),
        setHeight(height: 12),

        // Pricing
        ProductFieldCard(
          icon: CupertinoIcons.money_dollar_circle_fill,
          iconColor: const Color(0xFF2E7D32),
          title: 'Pricing',
          child: Column(
            children: [
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
              setHeight(height: 8),
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
            ],
          ),
        ),
        setHeight(height: 12),

        // Dates & Flavor
        ProductFieldCard(
          icon: CupertinoIcons.calendar,
          iconColor: const Color(0xFFE65100),
          title: 'Location, Dates & Details',
          child: Column(
            children: [
              Row(
                children: [
                  Flexible(child: _rackField()),
                  Flexible(child: _locationDropdown()),
                ],
              ),
              setHeight(height: 8),
              Row(
                children: [
                  Flexible(child: _purchaseDateField(context)),
                  Flexible(child: _expiryDateField(context)),
                ],
              ),
              Obx(
                () =>
                    controller.isFlavorAndWeightNotRequired.value
                        ? Column(
                          children: [
                            setHeight(height: 8),
                            InventoryBottomsheetComponentText(
                              hintText1: 'Enter flavor',
                              label1: 'Flavor',
                              controller1: controller.flavor,
                              validator1:
                                  (v) => v!.isEmpty ? emptyflavor : null,
                              hintText2: 'Enter weight',
                              label2: 'Weight',
                              controller2: controller.weight,
                              validator2:
                                  (v) => v!.isEmpty ? emptyWeight : null,
                            ),
                          ],
                        )
                        : const SizedBox.shrink(),
              ),
              setHeight(height: 8),
              Obx(
                () => CustomPadding(
                  paddingOption: SymmetricPadding(horizontal: 4.0),
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
            ],
          ),
        ),
        setHeight(height: 20),
        _saveButton(body: _petShopBody()),
        setHeight(height: 50),
      ],
    );
  }

  // ── Clothing Shop form ────────────────────────────────────────────────────
  Widget _clothingForm(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Product Info
        ProductFieldCard(
          icon: CupertinoIcons.barcode,
          iconColor: const Color(0xFF1565C0),
          title: 'Product Info',
          child: Column(
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
              setHeight(height: 8),
              Row(
                children: [
                  Flexible(child: _categoryDropdown()),
                  Flexible(child: _secondaryDropdown(hint: 'Size')),
                ],
              ),
              setHeight(height: 8),
              Row(
                children: [
                  Flexible(child: _colorDropdown()),
                  Flexible(child: _brandTypeDropdown()),
                ],
              ),
              setHeight(height: 8),
              Row(children: [Flexible(child: _stockField())]),
            ],
          ),
        ),
        setHeight(height: 12),

        // Pricing
        ProductFieldCard(
          icon: CupertinoIcons.money_dollar_circle_fill,
          iconColor: const Color(0xFF2E7D32),
          title: 'Pricing',
          child: Column(
            children: [
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
              setHeight(height: 8),
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
            ],
          ),
        ),
        setHeight(height: 12),

        // Location & Date
        ProductFieldCard(
          icon: CupertinoIcons.map_pin,
          iconColor: const Color(0xFF6A1B9A),
          title: 'Location & Date',
          child: Column(
            children: [
              Row(
                children: [
                  Flexible(child: _locationDropdown()),
                  Flexible(child: _rackField()),
                ],
              ),
              setHeight(height: 8),
              _purchaseDateField(context),
            ],
          ),
        ),
        setHeight(height: 20),
        _saveButton(body: _clothingBody()),
        setHeight(height: 50),
      ],
    );
  }

  // ── Shared field widgets ──────────────────────────────────────────────────

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

  Widget _secondaryDropdown({required String hint}) {
    return Obx(
      () =>
          controller.animalCategoryListLoading.value
              ? Center(child: CommonProgressBar(color: AppColors.blackColor))
              : controller.animalTypeList.isEmpty
              ? CustomDropDown(
                listItems: controller.animalTypeList,
                hintText: 'Add $hint First',
                notifyParent: (_) {},
              )
              : CustomDropDown(
                selectedDropDownItem: controller.selectedAnimalTypeId.value,
                hintText: hint,
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

  Widget _brandTypeDropdown() {
    return CustomStaticDropDown(
      selectedDropDownItem:
          controller.brandType.value.isEmpty
              ? null
              : controller.brandType.value,
      listItems: const ['Normal', 'Imp'],
      hintText: 'Brand Type',
      notifyParent: (val) => controller.brandType.value = val?.toString() ?? '',
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

  // ── Save button ───────────────────────────────────────────────────────────

  Widget _saveButton({required Map<String, dynamic> body}) {
    return Obx(
      () => CommonButton(
        isLoading: controller.isSaveLoading.value,
        label: saveButton,
        onTap: () async {
          if (controller.inventoryScanKey.currentState!.validate()) {
            unfocus();
            await controller.saveNewProduct(body: body);
          }
        },
      ),
    );
  }

  // ── Body maps ─────────────────────────────────────────────────────────────

  Map<String, dynamic> _petShopBody() => {
    "name": controller.productName.text,
    "barcodes": controller.barcode.text,
    "quantity": safeNum(controller.quantity.text),
    "selling_price": safeNum(controller.sellingPrice.text),
    "purchase_price": safeNum(controller.purchasePrice.text),
    "location": controller.location.text.toLowerCase(),
    "stock_type": "packet",
    "isloosed": controller.isLoose,
    "isflavorRequired": controller.isFlavorAndWeightNotRequired.value,
    "purchase_date": parseAppDate(controller.purchaseDate.text),
    "expiry_date": parseAppDate(controller.exprieDate.text),
    "category": controller.category.text,
    "animal_type": controller.animalType.text,
    "flavour": controller.flavor.text,
    "level": controller.level.text,
    "rack": controller.rack.text,
    "weight": controller.weight.text,
    "discount": controller.discount.text,
  };

  Map<String, dynamic> _clothingBody() => {
    "name": controller.productName.text,
    "barcodes": controller.barcode.text,
    "quantity": safeNum(controller.quantity.text),
    "selling_price": safeNum(controller.sellingPrice.text),
    "purchase_price": safeNum(controller.purchasePrice.text),
    "location": controller.location.text.toLowerCase(),
    "stock_type": "clothing",
    "category": controller.selectedCategoryId.value,
    "animal_type": controller.selectedAnimalTypeId.value,
    "color_id": controller.selectedColorId.value,
    "brand": controller.brandType.value,
    "level": controller.level.text,
    "rack": controller.rack.text,
    "purchase_date": parseAppDate(controller.purchaseDate.text),
    "discount": controller.discount.text,
  };
}
