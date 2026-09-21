import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_bottom_sheet.dart';
import 'package:inventory/common_widget/common_button.dart';
import 'package:inventory/common_widget/common_nodatafound.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/search.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/common_widget/textfiled.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/module/easy_billing/controller/easy_billing_controller.dart';
import 'package:inventory/module/inventorylist/model/inventory_model.dart';

class EasyBillingView extends StatelessWidget {
  const EasyBillingView({super.key});

  @override
  Widget build(BuildContext context) {
    final EasyBillingController controller = Get.put(EasyBillingController());

    return CommonAppbar(
      appBarLabel: 'Easy Billing',
      isleadingButtonRequired: false,
      firstActionChild: IconButton(
        tooltip: 'Refresh',
        onPressed: () => controller.loadData(),
        icon: const Icon(
          CupertinoIcons.refresh,
          color: AppColors.blackColor,
          size: 20,
        ),
      ),
      secondActionChild: Obx(() {
        if (controller.totalSelectedCount > 0) {
          return IconButton(
            tooltip: 'Clear Cart',
            onPressed: () => controller.clearCart(),
            icon: const Icon(
              CupertinoIcons.trash,
              color: AppColors.redColor,
              size: 20,
            ),
          );
        }
        return const SizedBox.shrink();
      }),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Quick Actions Bar (Option 1 & Option 2) ────────────────
            CustomPadding(
              paddingOption: SymmetricPadding(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  // Option 1: Custom Charge Item (Fast Continuous Multi-Add)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          () => _showCustomItemDialog(context, controller),
                      icon: const Icon(
                        CupertinoIcons.money_dollar_circle_fill,
                        size: 16,
                      ),
                      label: Text(
                        '+ Custom Item',
                        style: CustomTextStyle.customPoppin(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.whiteColor,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blackColor,
                        foregroundColor: AppColors.whiteColor,
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        elevation: 1,
                      ),
                    ),
                  ),
                  setWidth(width: 8),
                  // Option 2: Quick Add Minimal Product
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          () => _showQuickAddProductDialog(context, controller),
                      icon: Icon(
                        CupertinoIcons.add_circled_solid,
                        size: 16,
                        color: AppColors.deepPurple,
                      ),
                      label: Text(
                        '+ Quick Product',
                        style: CustomTextStyle.customPoppin(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.deepPurple,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: AppColors.deepPurple,
                          width: 1.5,
                        ),
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Search Bar ──────────────────────────────────────────────────
            CustomPadding(
              paddingOption: SymmetricPadding(horizontal: 12, vertical: 4),
              child: CommonSearch(
                label: 'Search',
                hintText: 'Search product by name or barcode...',
                controller: controller.searchController,
                onChanged: (val) {
                  controller.searchText.value = val;
                  controller.filterProducts();
                },
                icon: Obx(() {
                  if (controller.searchText.isNotEmpty) {
                    return IconButton(
                      icon: const Icon(
                        CupertinoIcons.xmark_circle_fill,
                        size: 18,
                      ),
                      onPressed: () {
                        controller.searchController.clear();
                        controller.searchText.value = '';
                        controller.filterProducts();
                      },
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ),
            ),

            setHeight(height: 6),

            // ── Prominent Top Horizontal Category Scroll Bar ─────────────────
            Obx(() {
              if (controller.isLoadingCategories.value) {
                return const SizedBox.shrink();
              }

              final categories = [
                'All',
                ...controller.categoryList
                    .map((c) => c.name ?? '')
                    .where((n) => n.isNotEmpty),
              ];

              return Container(
                height: 42.h,
                color: AppColors.whiteColor,
                padding: EdgeInsets.symmetric(vertical: 4.h),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  itemCount: categories.length,
                  separatorBuilder: (context, index) => SizedBox(width: 8.w),
                  itemBuilder: (context, index) {
                    final categoryName = categories[index];
                    return Obx(() {
                      final isSelected =
                          controller.selectedCategoryName.value == categoryName;

                      return InkWell(
                        onTap: () => controller.selectCategory(categoryName),
                        borderRadius: BorderRadius.circular(20.r),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 6.h,
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
                          child: Row(
                            children: [
                              Icon(
                                index == 0
                                    ? CupertinoIcons.square_grid_2x2_fill
                                    : CupertinoIcons.tag_fill,
                                size: 13.sp,
                                color:
                                    isSelected
                                        ? AppColors.whiteColor
                                        : Colors.grey.shade700,
                              ),
                              setWidth(width: 6),
                              Text(
                                categoryName,
                                style: CustomTextStyle.customPoppin(
                                  fontSize: 12,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                  color:
                                      isSelected
                                          ? AppColors.whiteColor
                                          : AppColors.blackColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    });
                  },
                ),
              );
            }),

            const Divider(height: 1, color: Colors.black12),

            // ── Full-Width Product Grid Area ─────────────────────────────────
            Expanded(
              child: Obx(() {
                if (controller.isLoadingProducts.value) {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                }

                if (controller.filteredProducts.isEmpty &&
                    controller.selectedCategoryName.value != 'All') {
                  return const CommonNoDataFound(
                    message: 'No products found in this category',
                  );
                }

                // Total items = Option 3 Open Tile (1) + Filtered Products
                final totalItemsCount = 1 + controller.filteredProducts.length;

                return GridView.builder(
                  padding: EdgeInsets.all(12.w),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.60,
                  ),
                  itemCount: totalItemsCount,
                  itemBuilder: (context, index) {
                    // Index 0 is Option 3: "Open Item Tile (Custom Price)"
                    if (index == 0) {
                      return _OpenCategoryItemCard(
                        categoryName: controller.selectedCategoryName.value,
                        onTap:
                            () => _showCustomItemDialog(
                              context,
                              controller,
                              defaultCategory:
                                  controller.selectedCategoryName.value,
                            ),
                      );
                    }

                    final item = controller.filteredProducts[index - 1];
                    return _ProductItemCard(item: item, controller: controller);
                  },
                );
              }),
            ),

            // ── Floating / Sticky Bottom Cart Summary Bar ────────────────────
            Obx(() {
              if (controller.totalSelectedCount == 0) {
                return const SizedBox.shrink();
              }

              return Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: AppColors.deepPurple.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        CupertinoIcons.cart_fill,
                        color: AppColors.deepPurple,
                        size: 22.sp,
                      ),
                    ),
                    setWidth(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${controller.totalSelectedCount} ${controller.totalSelectedCount == 1 ? 'Item' : 'Items'} Selected',
                          style: CustomTextStyle.customPoppin(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          '₹ ${controller.totalAmount.toStringAsFixed(2)}',
                          style: CustomTextStyle.customPoppin(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.blackColor,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    CommonButton(
                      label: 'Proceed to Bill',
                      width: 140.w,
                      height: 42.h,
                      radius: 12.r,
                      bgColor: AppColors.deepPurple,
                      onTap: () => controller.proceedToCheckout(),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Option 1: Fast Continuous Multi-Custom Item Entry Sheet (Sheet stays open!)
  void _showCustomItemDialog(
    BuildContext context,
    EasyBillingController controller, {
    String? defaultCategory,
  }) {
    final priceController = TextEditingController();
    final nameController = TextEditingController();
    final FocusNode priceFocusNode = FocusNode();

    bool addCurrentInput() {
      final price = double.tryParse(priceController.text.trim()) ?? 0.0;
      if (price <= 0) {
        Get.snackbar('Invalid Price', 'Please enter a valid price amount');
        return false;
      }
      controller.addCustomItem(name: nameController.text.trim(), price: price);
      priceController.clear();
      nameController.clear();
      priceFocusNode.requestFocus();
      return true;
    }

    commonBottomSheet(
      label: 'Fast Multi Custom Items',
      onPressed: () => Get.back(),
      child: CustomPadding(
        paddingOption: SymmetricPadding(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Live Cart Summary Chip inside Sheet
            Obx(() {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.deepPurple.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: AppColors.deepPurple.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.cart_fill,
                          size: 16.sp,
                          color: AppColors.deepPurple,
                        ),
                        setWidth(width: 6),
                        Text(
                          'In Cart: ${controller.totalSelectedCount} ${controller.totalSelectedCount == 1 ? 'item' : 'items'}',
                          style: CustomTextStyle.customPoppin(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.blackColor,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '₹ ${controller.totalAmount.toStringAsFixed(2)}',
                      style: CustomTextStyle.customPoppin(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.deepPurple,
                      ),
                    ),
                  ],
                ),
              );
            }),

            setHeight(height: 14),

            // Inputs
            CommonTextField(
              label: 'Price (₹)',
              hintText: 'Enter price (e.g. 50)',
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              astraIsRequred: true,
            ),

            setHeight(height: 10),

            CommonTextField(
              label: 'Item Name (Optional)',
              hintText: 'e.g. Custom Item / Repair',
              controller: nameController,
              astraIsRequred: false,
            ),

            setHeight(height: 16),

            // Continuous Buttons Row
            Row(
              children: [
                // Button 1: Add & Next (+) (Sheet stays open!)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      addCurrentInput();
                    },
                    icon: const Icon(
                      CupertinoIcons.add,
                      size: 16,
                      color: AppColors.blackColor,
                    ),
                    label: Text(
                      'Add & Next (+)',
                      style: CustomTextStyle.customPoppin(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.blackColor,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      side: const BorderSide(
                        color: AppColors.blackColor,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                ),

                setWidth(width: 10),

                // Button 2: Done & Checkout
                Expanded(
                  child: CommonButton(
                    label: 'Done',
                    height: 44.h,
                    radius: 10.r,
                    bgColor: AppColors.deepPurple,
                    onTap: () {
                      if (priceController.text.trim().isNotEmpty) {
                        addCurrentInput();
                      }
                      Get.back();
                    },
                  ),
                ),
              ],
            ),

            setHeight(height: 16),
          ],
        ),
      ),
    );
  }

  /// Option 2: Continuous Quick Product Add Sheet
  void _showQuickAddProductDialog(
    BuildContext context,
    EasyBillingController controller,
  ) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final categoryController = TextEditingController(
      text:
          controller.selectedCategoryName.value == 'All'
              ? 'General'
              : controller.selectedCategoryName.value,
    );
    final FocusNode nameFocusNode = FocusNode();

    bool addCurrentProduct() {
      final name = nameController.text.trim();
      final price = double.tryParse(priceController.text.trim()) ?? 0.0;

      if (name.isEmpty || price <= 0) {
        Get.snackbar('Required', 'Please enter valid product name and price');
        return false;
      }

      controller.addQuickProduct(
        name: name,
        price: price,
        categoryName: categoryController.text.trim(),
      );

      nameController.clear();
      priceController.clear();
      nameFocusNode.requestFocus();
      return true;
    }

    commonBottomSheet(
      label: 'Fast Multi Quick Products',
      onPressed: () => Get.back(),
      child: CustomPadding(
        paddingOption: SymmetricPadding(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.deepPurple.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: AppColors.deepPurple.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cart Items: ${controller.totalSelectedCount}',
                      style: CustomTextStyle.customPoppin(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.blackColor,
                      ),
                    ),
                    Text(
                      '₹ ${controller.totalAmount.toStringAsFixed(2)}',
                      style: CustomTextStyle.customPoppin(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.deepPurple,
                      ),
                    ),
                  ],
                ),
              );
            }),

            setHeight(height: 12),

            CommonTextField(
              label: 'Product Name',
              hintText: 'e.g. Samosa / Cold Coffee',
              controller: nameController,
              astraIsRequred: true,
            ),
            setHeight(height: 10),
            CommonTextField(
              label: 'Selling Price (₹)',
              hintText: 'Enter selling price',
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              astraIsRequred: true,
            ),
            setHeight(height: 10),
            CommonTextField(
              label: 'Category',
              hintText: 'Category name',
              controller: categoryController,
              astraIsRequred: false,
            ),
            setHeight(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => addCurrentProduct(),
                    icon: Icon(
                      CupertinoIcons.add,
                      size: 16,
                      color: AppColors.deepPurple,
                    ),
                    label: Text(
                      'Save & Next (+)',
                      style: CustomTextStyle.customPoppin(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepPurple,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      side: BorderSide(color: AppColors.deepPurple, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                ),
                setWidth(width: 10),
                Expanded(
                  child: CommonButton(
                    label: 'Done',
                    height: 44.h,
                    radius: 10.r,
                    bgColor: AppColors.deepPurple,
                    onTap: () {
                      if (nameController.text.trim().isNotEmpty &&
                          priceController.text.trim().isNotEmpty) {
                        addCurrentProduct();
                      }
                      Get.back();
                    },
                  ),
                ),
              ],
            ),
            setHeight(height: 16),
          ],
        ),
      ),
    );
  }
}

/// Option 3: Special Open Category Item Card
class _OpenCategoryItemCard extends StatelessWidget {
  final String categoryName;
  final VoidCallback onTap;

  const _OpenCategoryItemCard({
    required this.categoryName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: Colors.amber.shade700, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.amber.shade700,
              radius: 18.r,
              child: Icon(CupertinoIcons.add, color: Colors.white, size: 20.sp),
            ),
            setHeight(height: 8),
            Text(
              'Open Item',
              style: CustomTextStyle.customPoppin(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            setHeight(height: 2),
            Text(
              'Tap for custom price',
              textAlign: TextAlign.center,
              style: CustomTextStyle.customOpenSans(
                fontSize: 10,
                color: Colors.amber.shade900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductItemCard extends StatelessWidget {
  final InventoryItem item;
  final EasyBillingController controller;

  const _ProductItemCard({required this.item, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final qty = controller.getItemQuantity(item);
      final isSelected = qty > 0;
      final price = double.tryParse(item.sellingPrice ?? '0') ?? 0.0;
      final stock = item.quantity ?? '0';

      return Container(
        padding: EdgeInsets.all(7.w),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected ? AppColors.deepPurple : Colors.grey.shade200,
            width: isSelected ? 1.8 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  isSelected
                      ? AppColors.deepPurple.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Tag (Category Name & Stock)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      item.categoryName ?? 'General',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CustomTextStyle.customOpenSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
                setWidth(width: 4),
                Text(
                  'Qty: $stock',
                  style: CustomTextStyle.customOpenSans(
                    fontSize: 9,
                    color:
                        (double.tryParse(stock) ?? 0) <= 5
                            ? AppColors.redColor
                            : Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            setHeight(height: 4),

            // Product Name
            Expanded(
              child: Text(
                item.name ?? 'Unnamed Product',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: CustomTextStyle.customPoppin(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blackColor,
                ),
              ),
            ),

            //setHeight(height: 2),

            // Price Tag
            Text(
              '₹ ${price.toStringAsFixed(2)}',
              style: CustomTextStyle.customPoppin(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.blackColor,
              ),
            ),

            // setHeight(height: 8),

            // ── Quantity Controller (- / Count / +) ──────────────────────────
            if (!isSelected)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => controller.incrementItem(item),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.deepPurple),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 6.h),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.add,
                        size: 14.sp,
                        color: AppColors.deepPurple,
                      ),
                      setWidth(width: 4),
                      Text(
                        'ADD',
                        style: CustomTextStyle.customPoppin(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: AppColors.deepPurple,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => controller.decrementItem(item),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.r),
                        bottomLeft: Radius.circular(10.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        child: Icon(
                          CupertinoIcons.minus,
                          size: 14.sp,
                          color: AppColors.whiteColor,
                        ),
                      ),
                    ),
                    Text(
                      '$qty',
                      style: CustomTextStyle.customPoppin(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.whiteColor,
                      ),
                    ),
                    InkWell(
                      onTap: () => controller.incrementItem(item),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10.r),
                        bottomRight: Radius.circular(10.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        child: Icon(
                          CupertinoIcons.add,
                          size: 14.sp,
                          color: AppColors.whiteColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }
}
