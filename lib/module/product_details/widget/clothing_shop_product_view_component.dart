import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/module/product_details/controller/controller.dart';
import 'package:inventory/module/product_details/widget/product_field_card.dart';

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
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Product Info ──────────────────────────────────────────
            ProductFieldCard(
              icon: CupertinoIcons.tag_fill,
              iconColor: const Color(0xFF1565C0),
              title: 'Product Info',
              child: Column(
                children: [
                  // Product Name
                  CommonTextField(
                    validator: (v) => v!.isEmpty ? emptyProductName : null,
                    hintText: 'Enter product name',
                    label: 'Product Name',
                    controller: controller.productName,
                    onChanged: controller.onProductNameChanged,
                  ),
                  setHeight(height: 10),
                  // Category
                  Obx(
                    () =>
                        controller.categoryListLoading.value
                            ? Center(
                              child: CommonProgressBar(
                                color: AppColors.blackColor,
                              ),
                            )
                            : _CategoryDropdown(controller: controller),
                  ),
                  setHeight(height: 10),
                  // Brand Type
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
                              controller.brandType.value =
                                  (val ?? '').toString(),
                    ),
                  ),
                ],
              ),
            ),

            setHeight(height: 12),

            // ── 2. Colors (multi-select chips) ───────────────────────────
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
                    'No colors found. Add colors in Settings → Color Category.',
                    style: CustomTextStyle.customRaleway(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  );
                }
                return Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children:
                      controller.colorList.map((color) {
                        final isSelected = controller.selectedColors.any(
                          (c) => c.id == color.id,
                        );
                        return GestureDetector(
                          onTap: () => controller.toggleColor(color),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 7.h,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? AppColors.blackColor
                                      : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? AppColors.blackColor
                                        : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              color.name ?? '',
                              style: CustomTextStyle.customRaleway(
                                fontSize: 13,
                                color:
                                    isSelected
                                        ? AppColors.whiteColor
                                        : AppColors.blackColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                );
              }),
            ),

            setHeight(height: 12),

            // ── 3. Sizes (multi-select chips) ────────────────────────────
            ProductFieldCard(
              icon: CupertinoIcons.resize,
              iconColor: const Color(0xFF7B1FA2),
              title: 'Select Sizes',
              child: Obx(() {
                if (controller.animalCategoryListLoading.value) {
                  return Center(
                    child: CommonProgressBar(color: AppColors.blackColor),
                  );
                }
                if (controller.animalTypeList.isEmpty) {
                  return Text(
                    'No sizes found. Add sizes in Settings → Size Category.',
                    style: CustomTextStyle.customRaleway(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  );
                }
                return Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children:
                      controller.animalTypeList.map((size) {
                        final isSelected = controller.selectedSizes.any(
                          (s) => s.id == size.id,
                        );
                        return GestureDetector(
                          onTap: () => controller.toggleSize(size),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 7.h,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? AppColors.blackColor
                                      : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? AppColors.blackColor
                                        : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              size.name ?? '',
                              style: CustomTextStyle.customRaleway(
                                fontSize: 13,
                                color:
                                    isSelected
                                        ? AppColors.whiteColor
                                        : AppColors.blackColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                );
              }),
            ),

            setHeight(height: 12),

            // ── 4. Pricing ───────────────────────────────────────────────
            ProductFieldCard(
              icon: CupertinoIcons.money_dollar_circle_fill,
              iconColor: const Color(0xFF2E7D32),
              title: 'Pricing (Same for all variants)',
              child: Column(
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: CommonTextField(
                          inputLength: 10,
                          keyboardType: TextInputType.number,
                          hintText: 'Selling Price',
                          label: 'Selling Price (₹)',
                          controller: controller.sellingPrice,
                          validator:
                              (v) =>
                                  v!.isEmpty ? emptyProductSellingPrice : null,
                          onChanged: (_) => controller.calculatePurchasePrice(),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Flexible(
                        child: CommonTextField(
                          inputLength: 10,
                          keyboardType: TextInputType.number,
                          hintText: 'Purchase Price',
                          label: 'Purchase Price (₹)',
                          controller: controller.purchasePrice,
                          validator:
                              (v) =>
                                  v!.isEmpty ? emptyProductPurchasePrice : null,
                        ),
                      ),
                    ],
                  ),
                  setHeight(height: 8),
                  Row(
                    children: [
                      Flexible(
                        child: CommonTextField(
                          inputLength: 2,
                          keyboardType: TextInputType.number,
                          hintText: 'Discount',
                          label: 'Discount (%)',
                          controller: controller.discount,
                          validator: (v) => v!.isEmpty ? emptyDiscount : null,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Flexible(child: _locationDropdown()),
                    ],
                  ),
                  setHeight(height: 8),
                  Row(
                    children: [
                      Flexible(
                        child: CommonTextField(
                          hintText: 'Level',
                          label: 'Level',
                          controller: controller.level,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Flexible(
                        child: CommonTextField(
                          hintText: 'Rack',
                          label: 'Rack',
                          controller: controller.rack,
                        ),
                      ),
                    ],
                  ),
                  setHeight(height: 8),
                  _purchaseDateField(context),
                ],
              ),
            ),

            setHeight(height: 12),

            // ── 5. Variant Combinations ──────────────────────────────────
            Obx(() {
              if (controller.variantCombinations.isEmpty) {
                return const SizedBox.shrink();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter Stock for Combinations:',
                    style: CustomTextStyle.customNato(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  setHeight(height: 10),
                  ...controller.variantCombinations.asMap().entries.map((
                    entry,
                  ) {
                    final idx = entry.key;
                    final variant = entry.value;
                    return _VariantCombinationCard(
                      key: ValueKey(
                        '${variant['colorId']}_${variant['sizeId']}',
                      ),
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

            // ── 6. Save Button ───────────────────────────────────────────
            Obx(
              () => Center(
                child: CommonButton(
                  isLoading: controller.isSavingVariants.value,
                  label:
                      controller.variantCombinations.isEmpty
                          ? 'Save Product'
                          : 'Save Product with Variants (${controller.variantCombinations.length})',
                  onTap: () async {
                    if (!controller.inventoryScanKey.currentState!.validate()) {
                      return;
                    }
                    unfocus();
                    if (controller.variantCombinations.isEmpty) {
                      // Fallback: single product save (no variants selected)
                      await controller.saveNewProduct(
                        body: {
                          "name": controller.productName.text,
                          "barcodes": controller.barcode.text,
                          "quantity": '0',
                          "selling_price": controller.sellingPrice.text,
                          "purchase_price": controller.purchasePrice.text,
                          "location": controller.location.text.toLowerCase(),
                          "stock_type": "clothing",
                          "category": controller.selectedCategoryId.value ?? '',
                          "animal_type":
                              controller.selectedAnimalTypeId.value ?? '',
                          "color_id": controller.selectedColorId.value ?? '',
                          "brand": controller.brandType.value,
                          "level": controller.level.text,
                          "rack": controller.rack.text,
                          "discount": controller.discount.text,
                          "purchase_date": controller.purchaseDate.text,
                        },
                      );
                    } else {
                      await controller.saveProductWithVariants();
                    }
                  },
                ),
              ),
            ),

            setHeight(height: 50),
          ],
        ),
      ),
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
        enable: !controller.isLocationLocked.value,
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
}

// ── Category Dropdown ─────────────────────────────────────────────────────────

class _CategoryDropdown extends StatelessWidget {
  final ProductController controller;
  const _CategoryDropdown({required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.categoryList.isEmpty) {
      return CustomDropDown(
        listItems: controller.categoryList,
        hintText: 'Add Category First',
        notifyParent: (_) {},
      );
    }
    return CustomDropDown(
      selectedDropDownItem: controller.selectedCategoryId.value,
      listItems: controller.categoryList,
      hintText: 'Category',
      notifyParent: (val) {
        controller.selectedCategoryId.value = val;
        final match = controller.categoryList.cast<dynamic>().firstWhere(
          (e) => e.id == val,
          orElse: () => null,
        );
        controller.category.text = match?.name ?? '';
      },
    );
  }
}

// ── Single Variant Combination Card ──────────────────────────────────────────

class _VariantCombinationCard extends StatefulWidget {
  final String productName;
  final Map<String, dynamic> variant;
  final int index;
  final ProductController controller;

  const _VariantCombinationCard({
    super.key,
    required this.productName,
    required this.variant,
    required this.index,
    required this.controller,
  });

  @override
  State<_VariantCombinationCard> createState() =>
      _VariantCombinationCardState();
}

class _VariantCombinationCardState extends State<_VariantCombinationCard> {
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
    final title = '${widget.productName.trim()} [ $colorName - $sizeName ]';

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
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
          // Title
          Text(
            title,
            style: CustomTextStyle.customNato(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          setHeight(height: 10),
          // Stock + Barcode row
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
              SizedBox(width: 10.w),
              Flexible(
                child: CommonTextField(
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
