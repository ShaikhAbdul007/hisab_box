import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/app_popup_menu.dart';
import 'package:inventory/common_widget/common_bottom_sheet.dart';
import 'package:inventory/common_widget/common_dialogue.dart';
import 'package:inventory/common_widget/common_popup_appbar.dart';
import 'package:inventory/common_widget/edit_mode_banner.dart';
import 'package:inventory/helper/shop_type.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/helper/logger.dart';
import 'package:inventory/keys/keys.dart';
import '../../../common_widget/colors.dart';
import '../../../common_widget/common_appbar.dart';
import '../../../common_widget/common_button.dart';
import '../../../common_widget/common_calender.dart';
import '../../../common_widget/common_dropdown.dart';
import '../../../common_widget/common_padding.dart';
import '../../../common_widget/common_progressbar.dart';
import '../../../common_widget/size.dart';
import '../../../common_widget/textfiled.dart';
import '../../../helper/app_message.dart';
import '../../../helper/helper.dart';
import '../../../routes/route_name.dart';
import '../../../routes/routes.dart';
import '../controller/product_details_controller.dart';
import '../widget/inventory_bottomsheep_component_text.dart';

enum MenuOption { barcode, moveToShop, editProductDetails }

class ProductDetailView extends GetView<ProductDetailsController> {
  const ProductDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isProductLoosed = controller.data['isProductLoosed'];
    final bool godown = controller.data['product'].location == 'godown';

    return CommonAppbar(
      isleadingButtonRequired: true,
      backgroundColor: AppColors.whiteColor,
      firstActionChild: AppPopupMenu<MenuOption>(
        items: [
          const AppPopupItem(
            value: MenuOption.editProductDetails,
            label: 'Edit',
            icon: CupertinoIcons.pencil,
            color: Color(0xFF1565C0),
          ),
          const AppPopupItem(
            value: MenuOption.barcode,
            label: 'Generate Barcode',
            icon: CupertinoIcons.barcode,
            color: Color(0xFF2E7D32),
            isDividerAbove: true,
          ),
          if (godown)
            const AppPopupItem(
              value: MenuOption.moveToShop,
              label: 'Move to Shop',
              icon: CupertinoIcons.arrow_right_arrow_left,
              color: Color(0xFF6A1B9A),
              isDividerAbove: true,
            ),
        ],
        onSelected: (MenuOption result) {
          if (result == MenuOption.barcode) {
            showBarcode(controller.barcodeQytController);
          } else if (result == MenuOption.moveToShop) {
            commonDialogBox(
              context: context,
              child: Form(
                key: inventoryScanKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CommonPopupAppbar(
                      label: 'Transfer Request',
                      onPressed: () {
                        controller.transferQuantityToShop.clear();
                        Get.back();
                      },
                    ),
                    const Divider(),
                    CommonTextField(
                      hintText: 'Enter Quantity',
                      label: 'Quantity',
                      controller: controller.transferQuantityToShop,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? false) return 'Enter Quantity';
                        return null;
                      },
                      inputLength: 5,
                    ),
                    setHeight(height: 10),
                    Obx(
                      () => CommonButton(
                        isLoading: controller.isTransferLoading.value,
                        label: 'Transfer',
                        onTap: () {
                          if (inventoryScanKey.currentState!.validate()) {
                            final qty = double.parse(
                              controller.transferQuantityToShop.text,
                            );
                            if (qty > controller.data['product'].quantity) {
                              unfocus();
                              showSnackBar(
                                error:
                                    'Quantity must be lower than available stock in godown',
                              );
                            } else {
                              controller.requestStockTransfer(
                                product: controller.data['product'],
                                requestedQty: qty,
                              );
                            }
                          }
                        },
                      ),
                    ),
                    setHeight(height: 20),
                  ],
                ),
              ),
            );
          } else if (result == MenuOption.editProductDetails) {
            controller.readOnly.value = !controller.readOnly.value;
            controller.dropDownReadOnly.value =
                !controller.dropDownReadOnly.value;
          } else {
            AppLogger.info(('result.name').toString());
          }
        },
      ),
      appBarLabel: _appBarLabel(
        isProductLoosed: isProductLoosed,
        godown: godown,
      ),
      body: Form(
        key: controller.inventoryScanKey,
        child: Obx(
          () =>
              controller.isDataLoading.value
                  ? const CommonProgressBar()
                  : SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ── Hero Header ──────────────────────────────────────
                        _ProductDetailHeader(controller: controller),
                        // ── Edit mode banner ─────────────────────────────────
                        Padding(
                          padding:
                              SymmetricPadding(
                                horizontal: 14,
                                vertical: 8,
                              ).getPadding(),
                          child: EditModeBanner(
                            readOnly: controller.readOnly,
                            readOnlyMessage:
                                'Tap the ⋮ menu (top right) → Edit to make changes.',
                            editingMessage:
                                'You are in edit mode. Make changes and tap Save.',
                          ),
                        ),
                        // ── Fields ───────────────────────────────────────────
                        Padding(
                          padding:
                              SymmetricPadding(
                                horizontal: 14,
                                vertical: 12,
                              ).getPadding(),
                          child: _buildDetailBody(
                            context: context,
                            isProductLoosed: isProductLoosed,
                          ),
                        ),
                      ],
                    ),
                  ),
        ),
      ),
    );
  }

  // ── AppBar label ────────────────────────────────────────────────────────
  String _appBarLabel({required bool isProductLoosed, required bool godown}) {
    if (isProductLoosed) {
      return controller.shopTypeEnum == ShopType.clothingShop
          ? 'GR Product Detail'
          : 'Loose Product Detail';
    }
    return godown ? 'Godown Product Detail' : 'Shop Product Detail';
  }

  // ── Switch on shopType ──────────────────────────────────────────────────
  Widget _buildDetailBody({
    required BuildContext context,
    required bool isProductLoosed,
  }) {
    switch (controller.shopTypeEnum) {
      case ShopType.clothingShop:
        return _clothingFields(
          context: context,
          isProductLoosed: isProductLoosed,
        );
      case ShopType.petShop:
        return _petShopFields(
          context: context,
          isProductLoosed: isProductLoosed,
        );
    }
  }

  // ── Pet Shop ────────────────────────────────────────────────────────────
  Widget _petShopFields({
    required BuildContext context,
    required bool isProductLoosed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldCard(
          icon: CupertinoIcons.barcode,
          iconColor: const Color(0xFF1565C0),
          title: 'Product Info',
          child: Column(
            children: [
              InventoryBottomsheetComponentText(
                readOnly1: true,
                readOnly2: controller.readOnly.value,
                controller1: controller.barcode,
                controller2: controller.productName,
                label1: 'Barcode',
                hintText1: 'Enter barcode',
                hintText2: 'Enter product name',
                label2: 'Product name',
                validator2: (v) => v!.isEmpty ? emptyProductName : null,
              ),
              Row(
                children: [
                  Flexible(child: _categoryDropdown()),
                  Flexible(child: _secondaryDropdown(hint: 'Animal Type')),
                ],
              ),
              Obx(
                () => Row(
                  children: [
                    Flexible(child: _stockField()),
                    Flexible(child: _isLooseDropdown()),
                  ],
                ),
              ),
            ],
          ),
        ),
        setHeight(height: 12),
        _FieldCard(
          icon: CupertinoIcons.money_dollar_circle_fill,
          iconColor: const Color(0xFF2E7D32),
          title: 'Pricing',
          child: Column(
            children: [
              Obx(
                () => InventoryBottomsheetComponentText(
                  readOnly1: controller.readOnly.value,
                  readOnly2: controller.readOnly.value,
                  inputLength1: 10,
                  keyboardType1: TextInputType.number,
                  hintText1: 'Selling Price (sp)',
                  label1: 'Selling Price (₹)',
                  controller1: controller.sellingPrice,
                  validator1:
                      (v) => v!.isEmpty ? emptyProductSellingPrice : null,
                  inputLength2: 10,
                  keyboardType2: TextInputType.number,
                  hintText2: 'Purchase Price (mrp)',
                  label2: 'Purchase Price (₹)',
                  controller2: controller.purchasePrice,
                  validator2:
                      (v) => v!.isEmpty ? emptyProductPurchasePrice : null,
                ),
              ),
              Obx(
                () => Row(
                  children: [
                    Flexible(child: _discountField()),
                    Flexible(child: _locationDropdown()),
                  ],
                ),
              ),
            ],
          ),
        ),
        setHeight(height: 12),
        _FieldCard(
          icon: CupertinoIcons.calendar,
          iconColor: const Color(0xFFE65100),
          title: 'Dates',
          child: Column(
            children: [
              Row(
                children: [
                  Flexible(
                    child: _purchaseDateField(context, controller.dayDate),
                  ),
                  Flexible(
                    child: _expiryDateField(context, controller.dayDate),
                  ),
                ],
              ),
              Obx(
                () =>
                    controller.isFlavorAndWeightNotRequired.value
                        ? InventoryBottomsheetComponentText(
                          readOnly1: controller.readOnly.value,
                          readOnly2: controller.readOnly.value,
                          hintText1: 'Flavor',
                          label1: 'Flavor',
                          controller1: controller.flavor,
                          validator1: (v) => v!.isEmpty ? emptyflavor : null,
                          hintText2: 'Weight',
                          label2: 'Weight',
                          controller2: controller.weight,
                          validator2: (v) => v!.isEmpty ? emptyWeight : null,
                        )
                        : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
        setHeight(height: 20),
        _saveButton(isProductLoosed: isProductLoosed),
        setHeight(height: 30),
      ],
    );
  }

  // ── Clothing Shop ───────────────────────────────────────────────────────
  Widget _clothingFields({
    required BuildContext context,
    required bool isProductLoosed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldCard(
          icon: CupertinoIcons.barcode,
          iconColor: const Color(0xFF1565C0),
          title: 'Product Info',
          child: Column(
            children: [
              InventoryBottomsheetComponentText(
                readOnly1: true,
                readOnly2: controller.readOnly.value,
                controller1: controller.barcode,
                controller2: controller.productName,
                label1: 'Barcode',
                hintText1: 'Enter barcode',
                hintText2: 'Enter product name',
                label2: 'Product name',
                validator2: (v) => v!.isEmpty ? emptyProductName : null,
              ),
              Row(
                children: [
                  Flexible(child: _categoryDropdown()),
                  Flexible(child: _secondaryDropdown(hint: 'Size')),
                ],
              ),
              Row(
                children: [
                  Flexible(child: _colorDropdown()),
                  Flexible(child: _brandDropdown()),
                ],
              ),
              Row(children: [Flexible(child: _stockField())]),
            ],
          ),
        ),
        setHeight(height: 12),
        _FieldCard(
          icon: CupertinoIcons.money_dollar_circle_fill,
          iconColor: const Color(0xFF2E7D32),
          title: 'Pricing',
          child: Column(
            children: [
              Obx(
                () => InventoryBottomsheetComponentText(
                  readOnly1: controller.readOnly.value,
                  readOnly2: controller.readOnly.value,
                  inputLength1: 10,
                  keyboardType1: TextInputType.number,
                  hintText1: 'Selling Price (sp)',
                  label1: 'Selling Price (₹)',
                  controller1: controller.sellingPrice,
                  validator1:
                      (v) => v!.isEmpty ? emptyProductSellingPrice : null,
                  inputLength2: 10,
                  keyboardType2: TextInputType.number,
                  hintText2: 'Purchase Price (mrp)',
                  label2: 'Purchase Price (₹)',
                  controller2: controller.purchasePrice,
                  validator2:
                      (v) => v!.isEmpty ? emptyProductPurchasePrice : null,
                ),
              ),
              Obx(
                () => Row(
                  children: [
                    Flexible(child: _discountField()),
                    Flexible(child: _locationDropdown()),
                  ],
                ),
              ),
            ],
          ),
        ),
        setHeight(height: 12),
        _FieldCard(
          icon: CupertinoIcons.map_pin,
          iconColor: const Color(0xFF6A1B9A),
          title: 'Location',
          child: Obx(
            () => InventoryBottomsheetComponentText(
              readOnly1: controller.readOnly.value,
              readOnly2: controller.readOnly.value,
              hintText1: 'Rack',
              label1: 'Rack',
              controller1: controller.rack,
              hintText2: 'Level',
              label2: 'Level',
              controller2: controller.level,
            ),
          ),
        ),
        setHeight(height: 20),
        _saveButton(isProductLoosed: isProductLoosed),
        setHeight(height: 30),
      ],
    );
  }

  // ── Shared widgets ──────────────────────────────────────────────────────

  Widget _categoryDropdown() {
    return Obx(
      () =>
          controller.categoryList.isEmpty
              ? Center(child: CommonProgressBar(color: AppColors.blackColor))
              : CustomDropDown(
                selectedDropDownItem: controller.selectedCategoryId.value,
                listItems: controller.categoryList,
                hintText: 'Category',
                notifyParent: (val) {
                  print(val);
                  controller.selectedCategoryId.value = val;
                  final match = controller.categoryList.firstWhereOrNull(
                    (e) => e.id == val,
                  );
                  controller.category.text = match?.name ?? '';
                },
              ),
    );
  }

  /// Pet Shop → 'Animal Type' | Clothing Shop → 'Size'
  Widget _secondaryDropdown({required String hint}) {
    return Obx(
      () =>
          controller.animalTypeList.isEmpty
              ? Center(child: CommonProgressBar(color: AppColors.blackColor))
              : CustomDropDown(
                hintText: hint,
                selectedDropDownItem: controller.selectedAnimalTypeId.value,
                listItems: controller.animalTypeList,
                notifyParent: (val) {
                  controller.selectedAnimalTypeId.value = val;
                  final match = controller.animalTypeList.firstWhereOrNull(
                    (e) => e.id == val,
                  );
                  controller.animalType.text = match?.name ?? '';
                  //  controller.selectedAnimalTypeId.value = match?.id ?? '';
                },
              ),
    );
  }

  Widget _stockField() {
    return CommonTextField(
      readOnly: controller.readOnly.value,
      validator: (v) => v!.isEmpty ? emptyProductQuantity : null,
      contentPadding: SymmetricPadding(vertical: 5, horizontal: 5).getPadding(),
      inputLength: 5,
      keyboardType: TextInputType.number,
      hintText: 'Enter Stock',
      label: 'Stock',
      controller: controller.quantity,
    );
  }

  Widget _isLooseDropdown() {
    return CustomStaticDropDown(
      selectedDropDownItem: controller.isLoose,
      listItems: const [true, false],
      hintText: 'Select isLoose',
      notifyParent: (val) => controller.isLoose = val,
    );
  }

  Widget _brandDropdown() {
    return Obx(
      () => CustomStaticDropDown(
        selectedDropDownItem: controller.brand.text,
        listItems: ['Imp', 'Normal'],
        hintText: 'Brand',
        notifyParent: (val) => controller.brand.text = (val ?? '').toString(),
        enable: !controller.readOnly.value,
      ),
    );
  }

  Widget _colorDropdown() {
    return Obx(
      () =>
          controller.colorOptions.isEmpty
              ? Center(child: CommonProgressBar(color: AppColors.blackColor))
              : CustomDropDown(
                selectedDropDownItem: controller.selectedColorId.value,
                listItems: controller.colorOptions,
                hintText: 'Color',
                notifyParent: (val) {
                  controller.selectedColorId.value = val;
                  print(
                    'Selected Color ID: ${controller.selectedColorId.value}',
                  );
                  final match = controller.colorOptions.firstWhereOrNull(
                    (e) => e.id == val,
                  );
                  controller.color.text = match?.name ?? '';
                },
                enable: !controller.readOnly.value,
              ),
    );
  }

  Widget _discountField() {
    return CommonTextField(
      readOnly: controller.readOnly.value,
      validator: (v) => v!.isEmpty ? emptyDiscount : null,
      contentPadding: SymmetricPadding(vertical: 5, horizontal: 5).getPadding(),
      inputLength: 5,
      keyboardType: TextInputType.number,
      hintText: 'Enter Discount',
      label: 'Discount (%)',
      controller: controller.discount,
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
        notifyParent: (val) => controller.location.text = val,
      ),
    );
  }

  Widget _purchaseDateField(BuildContext context, RxString rxDate) {
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
              controller: rxDate,
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

  Widget _expiryDateField(BuildContext context, RxString rxDate) {
    return CommonTextField(
      readOnly: true,
      suffixIcon: CustomPadding(
        paddingOption: OnlyPadding(right: 10),
        child: InkWell(
          onTap: () async {
            final res = await customDatePicker(
              context: context,
              lastDate: DateTime(2040),
              selectedDate: DateTime.now(),
              controller: rxDate,
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

  Widget _saveButton({required bool isProductLoosed}) {
    return Obx(
      () =>
          controller.readOnly.value
              ? const SizedBox.shrink()
              : CommonButton(
                isLoading: controller.isSaveLoading.value,
                label: saveButton,
                onTap: () async {
                  if (controller.inventoryScanKey.currentState!.validate()) {
                    unfocus();
                    if (!isProductLoosed) {
                      final body =
                          controller.shopTypeEnum == ShopType.clothingShop
                              ? {
                                "name": controller.productName.text,
                                "barcodes": controller.barcode.text,
                                "quantity":
                                    num.tryParse(controller.quantity.text) ?? 0,
                                "selling_price":
                                    num.tryParse(
                                      controller.sellingPrice.text,
                                    ) ??
                                    0,
                                "purchase_price":
                                    num.tryParse(
                                      controller.purchasePrice.text,
                                    ) ??
                                    0,
                                "location": controller.location.text,
                                "stock_type": "clothing",
                                "purchase_date": controller.purchaseDate.text,
                                "category": controller.selectedCategoryId.value,
                                "animal_type":
                                    controller.selectedAnimalTypeId.value,
                                "color_id": controller.selectedColorId.value,
                                "brand": controller.brand.text,
                                "level": controller.level.text,
                                "rack": controller.rack.text,
                                "discount":
                                    num.tryParse(controller.discount.text) ?? 0,
                              }
                              : {
                                "name": controller.productName.text,
                                "barcodes": controller.barcode.text,
                                "quantity":
                                    num.tryParse(controller.quantity.text) ?? 0,
                                "selling_price":
                                    num.tryParse(
                                      controller.sellingPrice.text,
                                    ) ??
                                    0,
                                "purchase_price":
                                    num.tryParse(
                                      controller.purchasePrice.text,
                                    ) ??
                                    0,
                                "location": controller.location.text,
                                "stock_type": "packet",
                                "isloosed": controller.isLoose,
                                "isflavorRequired":
                                    !controller
                                        .isFlavorAndWeightNotRequired
                                        .value,
                                "purchase_date": controller.purchaseDate.text,
                                "expiry_date": controller.exprieDate.text,
                                "category": controller.category.text,
                                "animal_type": controller.animalType.text,
                                "flavour": controller.flavor.text,
                                "color_id": controller.selectedColorId.value,
                                "brand": controller.brand.text,
                                "level": controller.level.text,
                                "rack": controller.rack.text,
                                "weight": controller.weight.text,
                                "discount":
                                    num.tryParse(controller.discount.text) ?? 0,
                              };
                      controller.updateProductQuantity(
                        body: body,
                        productId: controller.productId.value,
                      );
                    } else {
                      final body = {
                        "product_id": controller.productId.value,
                        "quantity": controller.looseQuantity.text,
                        "selling_price": controller.looseSellingPrice.text,
                      };
                      controller.updateLoosedProductQuantity(body: body);
                    }
                  }
                },
              ),
    );
  }

  // ── Barcode bottom sheet ────────────────────────────────────────────────
  void showBarcode(TextEditingController qtyController) {
    commonBottomSheet(
      label: 'BarCode',
      onPressed: () {
        Get.back();
        controller.setData();
      },
      child: Padding(
        padding: SymmetricPadding(horizontal: 20, vertical: 8).getPadding(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Barcode card ─────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                children: [
                  BarcodeWidget(
                    barcode: Barcode.code128(),
                    data: controller.barcode.text,
                    height: 80,
                    width: double.infinity,
                    drawText: true,
                  ),
                  setHeight(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.blackColor.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      controller.barcode.text,
                      style: CustomTextStyle.customOpenSans(
                        fontSize: 12,
                        color: AppColors.greyColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            setHeight(height: 20),
            // ── Quantity field ───────────────────────────────────────
            CommonTextField(
              label: 'Quantity',
              astraIsRequred: false,
              hintText: 'How many labels to print?',
              controller: qtyController,
              keyboardType: TextInputType.number,
            ),
            setHeight(height: 20),
            // ── Generate button ──────────────────────────────────────
            CommonButton(
              label: 'Generate Barcode',
              onTap: () {
                AppRoutes.navigateRoutes(
                  routeName: AppRouteName.barcodePrintView,
                  data: {
                    'productData': controller.data,
                    'qyt': double.tryParse(qtyController.text)?.toInt() ?? 1,
                  },
                );
              },
            ),
            setHeight(height: 50),
          ],
        ),
      ),
    );
  }
}

// ── Product Detail Header ─────────────────────────────────────────────────────
class _ProductDetailHeader extends StatelessWidget {
  final ProductDetailsController controller;
  const _ProductDetailHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.blackColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28.r),
          bottomRight: Radius.circular(28.r),
        ),
      ),
      child: Column(
        children: [
          // Icon
          Obx(
            () => Container(
              width: 72.w,
              height: 72.h,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: Icon(
                CupertinoIcons.cube_box_fill,
                size: 36.sp,
                color:
                    controller.readOnly.value
                        ? Colors.white
                        : Colors.red.shade300,
              ),
            ),
          ),
          setHeight(height: 12),
          // Product name
          Obx(
            () => Text(
              controller.rxProductName.value,
              style: CustomTextStyle.customPoppin(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          setHeight(height: 6),
          // Stock badge
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: RichText(
                text: TextSpan(
                  text: controller.rxQuantity.value,
                  style: CustomTextStyle.customPoppin(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  children: [
                    TextSpan(
                      text: '  in stock',
                      style: CustomTextStyle.customOpenSans(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Field Card ────────────────────────────────────────────────────────────────
class _FieldCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;

  const _FieldCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34.w,
                height: 34.h,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9.r),
                ),
                child: Icon(icon, color: iconColor, size: 17.sp),
              ),
              setWidth(width: 10),
              Text(
                title,
                style: CustomTextStyle.customPoppin(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          setHeight(height: 12),
          child,
        ],
      ),
    );
  }
}
