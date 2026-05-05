import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory/common_widget/common_bottom_sheet.dart';
import 'package:inventory/module/inventorylist/model/inventory_model.dart';
import '../../../common_widget/colors.dart';
import '../../../common_widget/common_button.dart';
import '../../../common_widget/size.dart';
import '../../../helper/textstyle.dart';

// ── Shared sheet body wrapper ─────────────────────────────────────────────────
Widget _SheetBody({
  required IconData icon,
  required Color iconColor,
  required String title,
  required String message,
  required List<Widget> actions,
}) {
  return Padding(
    padding: EdgeInsets.fromLTRB(20.w, 8, 20.w, 0),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon
        Container(
          width: 56.w,
          height: 56.h,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 26.sp),
        ),
        setHeight(height: 12),
        // Title
        Text(
          title,
          style: CustomTextStyle.customPoppin(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        setHeight(height: 8),
        // Message
        Text(
          message,
          style: CustomTextStyle.customOpenSans(
            fontSize: 13,
            color: AppColors.greyColor,
          ),
          textAlign: TextAlign.center,
        ),
        setHeight(height: 20),
        // Actions
        ...actions,
        setHeight(height: 30),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. Existing product dialog
// ─────────────────────────────────────────────────────────────────────────────
void exisitngProductDialog({
  required String message,
  required VoidCallback onPressed,
}) {
  commonBottomSheet(
    size: 18,
    label: 'Product Already Exists',
    onPressed: onPressed,
    child: _SheetBody(
      icon: CupertinoIcons.cube_box_fill,
      iconColor: const Color(0xFF1565C0),
      title: 'Already in Inventory',
      message: message,
      actions: [CommonButton(label: 'Got it, Scan Again', onTap: onPressed)],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. Product not available dialog
// ─────────────────────────────────────────────────────────────────────────────
void productNotAvailableDialog({
  required String label,
  required VoidCallback onTap,
  required VoidCallback? scannedDoneOnTap,
  required List<InventoryItem> productModel,
}) {
  commonBottomSheet(
    size: 18,
    label: 'Product Not Found',
    onPressed: () {},
    isCancelButtonRequire: false,
    child: PopScope(
      canPop: false,
      child: _SheetBody(
        icon: CupertinoIcons.exclamationmark_triangle_fill,
        iconColor: const Color(0xFFC62828),
        title: 'Not Available',
        message: label,
        actions: [
          CommonButton(label: 'Scan Again', onTap: onTap),
          if (productModel.isNotEmpty) ...[
            setHeight(height: 10),
            CommonButton(
              bgColor: AppColors.redColor,
              label: 'Done Scanning',
              onTap: scannedDoneOnTap ?? () {},
            ),
          ],
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. Product not with scanned available dialog
// ─────────────────────────────────────────────────────────────────────────────
void productNotWithScannedAvailableDialog(
  String label, {
  required void Function() scanAgainOnTap,
  required void Function() scanningDoneOnTap2,
  required void Function() manualSellOnTap,
}) {
  commonBottomSheet(
    label: 'Out of Stock',
    onPressed: () {},
    isCancelButtonRequire: false,
    child: PopScope(
      canPop: false,
      child: _SheetBody(
        icon: CupertinoIcons.xmark_circle_fill,
        iconColor: const Color(0xFFC62828),
        title: 'Out of Stock',
        message: label,
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: scanAgainOnTap,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.blackColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                  child: Text(
                    'Scan Again',
                    style: CustomTextStyle.customPoppin(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              setWidth(width: 12),
              Expanded(
                child: CommonButton(
                  bgColor: AppColors.redColor,
                  label: 'Done Scanning',
                  onTap: scanningDoneOnTap2,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. Product saving / scan success dialog
// ─────────────────────────────────────────────────────────────────────────────
void productSavingDialog({
  required String label,
  required void Function() scanAgainOnTap,
  required void Function() scanccingDoneOnTap,
}) {
  commonBottomSheet(
    label: 'Product Added',
    isCancelButtonRequire: false,
    onPressed: () {},
    child: PopScope(
      canPop: false,
      child: _SheetBody(
        icon: CupertinoIcons.checkmark_circle_fill,
        iconColor: const Color(0xFF2E7D32),
        title: 'Added to Cart',
        message: label,
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: scanAgainOnTap,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.blackColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                  child: Text(
                    'Scan Again',
                    style: CustomTextStyle.customPoppin(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              setWidth(width: 12),
              Expanded(
                child: CommonButton(label: 'Done', onTap: scanccingDoneOnTap),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. Check product status (Packet / Loose)
// ─────────────────────────────────────────────────────────────────────────────
void checkProductStatusDialog({
  required String label,
  required VoidCallback packetOnTap,
  required VoidCallback looseDoneOnTap,
}) {
  commonBottomSheet(
    label: 'Select Stock Type',
    isCancelButtonRequire: false,
    onPressed: () {},
    child: PopScope(
      canPop: false,
      child: _SheetBody(
        icon: CupertinoIcons.cube_box,
        iconColor: const Color(0xFF6A1B9A),
        title: 'Packet or Loose?',
        message: label,
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: packetOnTap,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.blackColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.cube_box_fill,
                        size: 16.sp,
                        color: AppColors.blackColor,
                      ),
                      setWidth(width: 6),
                      Text(
                        'Packet',
                        style: CustomTextStyle.customPoppin(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              setWidth(width: 12),
              Expanded(
                child: CommonButton(
                  bgColor: const Color(0xFF6A1B9A),
                  label: 'Loose',
                  onTap: looseDoneOnTap,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
