import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/common_progressbar.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/logger.dart';
import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/helper/shop_type.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/module/product_details/widget/product_field_card.dart';
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
        _saveButton(bodyBuilder: _petShopBody),
        setHeight(height: 50),
      ],
    );
  }

  // ── Clothing Shop form (Matrix Grid) ─────────────────────────────────────
  Widget _clothingForm(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Product Info ───────────────────────────────────────────────
        ProductFieldCard(
          icon: CupertinoIcons.tag_fill,
          iconColor: const Color(0xFF1565C0),
          title: 'Product Info',
          child: Column(
            children: [
              CommonTextField(
                validator: (v) => v!.isEmpty ? emptyProductName : null,
                hintText: 'Enter product name',
                label: 'Product Name',
                controller: controller.productName,
                onChanged: controller.onProductNameChanged,
              ),
              setHeight(height: 10),
              Obx(
                () =>
                    controller.categoryListLoading.value
                        ? Center(
                          child: CommonProgressBar(color: AppColors.blackColor),
                        )
                        : _categoryDropdown(),
              ),
              setHeight(height: 10),
              Obx(
                () => CustomStaticDropDown(
                  selectedDropDownItem:
                      ['Normal', 'Imp'].contains(controller.brandType.value)
                          ? controller.brandType.value
                          : null,
                  listItems: const ['Normal', 'Imp'],
                  hintText: 'Brand Type',
                  notifyParent:
                      (val) =>
                          controller.brandType.value = (val ?? '').toString(),
                ),
              ),
            ],
          ),
        ),

        setHeight(height: 12),

        // ── Colors (multi-select) ──────────────────────────────────────
        ProductFieldCard(
          icon: CupertinoIcons.paintbrush_fill,
          iconColor: const Color(0xFFE53935),
          title: 'Select Colors',
          child: Obx(() {
            if (controller.colorListLoading.value) {
              return Center(
                child: CommonProgressBar(color: AppColors.blackColor),
              );
            }
            if (controller.colorList.isEmpty) {
              return Text(
                'No colors found. Add colors in Settings.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              );
            }
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  controller.colorList.map((colorItem) {
                    final isSelected = controller.selectedColors.any(
                      (c) => c.id == colorItem.id,
                    );
                    return GestureDetector(
                      onTap: () => controller.toggleColor(colorItem),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? AppColors.blackColor
                                  : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                isSelected
                                    ? AppColors.blackColor
                                    : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          colorItem.name ?? '',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color:
                                isSelected
                                    ? AppColors.whiteColor
                                    : AppColors.blackColor,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            );
          }),
        ),

        // ── Sizes (multi-select) ───────────────────────────────────────
        Obx(
          () => ProductFieldCard(
            icon: CupertinoIcons.resize,
            iconColor: const Color(0xFF7B1FA2),
            title: controller.isSizeRequired.value ? 'Select Sizes' : 'Select Sizes (Optional)',
            trailing: CupertinoSwitch(
              activeColor: const Color(0xFF7B1FA2),
              value: controller.isSizeRequired.value,
              onChanged: (val) {
                controller.isSizeRequired.value = val;
                if (!val) {
                  controller.selectedSizes.clear();
                }
                controller.regenerateCombinations();
              },
            ),
            child: controller.isSizeRequired.value
                ? Obx(() {
                    if (controller.animalCategoryListLoading.value) {
                      return Center(
                        child: CommonProgressBar(color: AppColors.blackColor),
                      );
                    }
                    if (controller.animalTypeList.isEmpty) {
                      return Text(
                        'No sizes found. Add sizes in Settings.',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      );
                    }
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: controller.animalTypeList.map((size) {
                        final isSelected = controller.selectedSizes.any(
                          (s) => s.id == size.id,
                        );
                        return GestureDetector(
                          onTap: () => controller.toggleSize(size),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.blackColor
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.blackColor
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              size.name ?? '',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? AppColors.whiteColor
                                      : AppColors.blackColor),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  })
                : const SizedBox.shrink(),
          ),
        ),

      setHeight(height: 12),

        // ── Pricing ───────────────────────────────────────────────────
        ProductFieldCard(
          icon: CupertinoIcons.money_dollar_circle_fill,
          iconColor: const Color(0xFF2E7D32),
          title: 'Pricing (Same for all variants)',
          child: Column(
            children: [
              InventoryBottomsheetComponentText(
                inputLength1: 10,
                keyboardType1: TextInputType.number,
                hintText1: 'Selling Price',
                label1: 'Selling Price (₹)',
                controller1: controller.sellingPrice,
                validator1: (v) => v!.isEmpty ? emptyProductSellingPrice : null,
                inputLength2: 10,
                keyboardType2: TextInputType.number,
                hintText2: 'Purchase Price',
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
                hintText1: 'Discount',
                label1: 'Discount (%)',
                controller1: controller.discount,
                validator1: (v) => v!.isEmpty ? emptyDiscount : null,
                hintText2: 'Level',
                label2: 'Level',
                controller2: controller.level,
              ),
              setHeight(height: 8),
              Row(
                children: [
                  Flexible(child: _locationDropdown()),
                  const SizedBox(width: 8),
                  Flexible(child: _rackField()),
                ],
              ),
              setHeight(height: 8),
              _purchaseDateField(context),
            ],
          ),
        ),

        setHeight(height: 12),

        // ── Variant Combinations ───────────────────────────────────────
        Obx(() {
          if (controller.variantCombinations.isEmpty) {
            return const SizedBox.shrink();
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter Stock for Combinations:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.blackColor,
                ),
              ),
              setHeight(height: 10),
              ...controller.variantCombinations.asMap().entries.map((entry) {
                final idx = entry.key;
                final variant = entry.value;
                return _GBVariantCard(
                  key: ValueKey('${variant['colorId']}_${variant['sizeId']}'),
                  productName: controller.productName.text,
                  variant: variant,
                  index: idx,
                  controller: controller,
                );
              }),
            ],
          );
        }),

        setHeight(height: 20),

        // ── Save Button ────────────────────────────────────────────────
        Obx(
          () => Center(
            child: CommonButton(
              isLoading: controller.isSavingVariants.value,
              label:
                  controller.variantCombinations.isEmpty
                      ? saveButton
                      : 'Save Product with Variants (${controller.variantCombinations.length})',
              onTap: () async {
                if (!controller.inventoryScanKey.currentState!.validate()) {
                  return;
                }
                unfocus();
                if (controller.selectedColors.isEmpty) {
                  showSnackBar(error: 'Please select at least one color');
                  return;
                }
                if (controller.isSizeRequired.value && controller.selectedSizes.isEmpty) {
                  showSnackBar(error: 'Please select at least one size');
                  return;
                }
                if (controller.variantCombinations.isEmpty) {
                  showSnackBar(
                    error: controller.isSizeRequired.value
                        ? 'Please select at least one color and size'
                        : 'Please select at least one color',
                  );
                  return;
                }
                await controller.saveProductWithVariants();
              },
            ),
          ),
        ),

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

  Widget _saveButton({required Map<String, dynamic> Function() bodyBuilder}) {
    return Obx(
      () => CommonButton(
        isLoading: controller.isSaveLoading.value,
        label: saveButton,
        onTap: () async {
          if (controller.inventoryScanKey.currentState!.validate()) {
            unfocus();
            AppLogger.error('Generate Barcode ${bodyBuilder()}');
            await controller.saveNewProduct(body: bodyBuilder());
          }
        },
      ),
    );
  }

  // ── Body maps ─────────────────────────────────────────────────────────────

  Map<String, dynamic> _petShopBody() => {
    "name": controller.productName.text,
    "barcodes": controller.barcode.text,
    "quantity": parsePrice(controller.quantity.text),
    "selling_price": parsePrice(controller.sellingPrice.text),
    "purchase_price": parsePrice(controller.purchasePrice.text),
    "location": controller.location.text.toLowerCase(),
    "stock_type": "packet",
    "isloosed": controller.isLoose,
    "isflavorRequired": controller.isFlavorAndWeightNotRequired.value,
    "purchase_date": parseAppDate(controller.purchaseDate.text),
    "expiry_date": parseAppDate(controller.exprieDate.text),
    "category": controller.selectedCategoryId.value,
    "animal_type": controller.selectedAnimalTypeId.value,
    "flavour": controller.flavor.text,
    "level": controller.level.text,
    "rack": controller.rack.text,
    "weight": controller.weight.text,
    "discount": controller.discount.text,
  };


}

// ── Variant Combination Card for Generate Barcode ─────────────────────────────
class _GBVariantCard extends StatefulWidget {
  final String productName;
  final Map<String, dynamic> variant;
  final int index;
  final GenerateBarcodeController controller;

  const _GBVariantCard({
    super.key,
    required this.productName,
    required this.variant,
    required this.index,
    required this.controller,
  });

  @override
  State<_GBVariantCard> createState() => _GBVariantCardState();
}

class _GBVariantCardState extends State<_GBVariantCard> {
  late final TextEditingController _stockCtrl;
  late final TextEditingController _barcodeCtrl;

  @override
  void initState() {
    super.initState();
    _stockCtrl = TextEditingController(
      text: widget.variant['stock']?.toString() ?? '',
    );
    _barcodeCtrl = TextEditingController(
      text: widget.variant['barcode']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _stockCtrl.dispose();
    _barcodeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorName = widget.variant['colorName'] ?? '';
    final sizeName = widget.variant['sizeName'] ?? '';
    final title =
        sizeName.isNotEmpty
            ? '${widget.productName.trim()} [ $colorName - $sizeName ]'
            : '${widget.productName.trim()} [ $colorName ]';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: CustomTextStyle.customNato(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Flexible(
                child: CommonTextField(
                  keyboardType: TextInputType.number,
                  hintText: 'Stock',
                  label: 'Stock',
                  controller: _stockCtrl,
                  onChanged:
                      (v) =>
                          widget.controller.updateVariantStock(widget.index, v),
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: CommonTextField(
                  readOnly: true,
                  hintText: 'Barcode',
                  label: 'Barcode',
                  controller: _barcodeCtrl,
                  onChanged:
                      (v) => widget.controller.updateVariantBarcode(
                        widget.index,
                        v,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
