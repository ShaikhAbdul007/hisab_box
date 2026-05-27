import 'package:inventory/helper/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/shop_type.dart';
import 'package:inventory/module/inventorylist/model/inventory_model.dart';
import '../../../common_widget/colors.dart';
import '../../../helper/textstyle.dart';

class SellingConfirmationListText extends StatelessWidget with CacheManager {
  final InventoryItem inventoryModel;
  final void Function()? plusOnTap;
  final void Function()? minusOnTap;
  final void Function()? removeOnTap;
  final Widget sellingPrices;
  final TextEditingController dicountController;
  final void Function(String)? onDiscountChanged;
  final bool isLooseDiscountEnable;

  SellingConfirmationListText({
    super.key,
    required this.inventoryModel,
    this.plusOnTap,
    this.minusOnTap,
    required this.sellingPrices,
    this.removeOnTap,
    required this.dicountController,
    this.onDiscountChanged,
    required this.isLooseDiscountEnable,
  });

  @override
  Widget build(BuildContext context) {
    final bool sellType = inventoryModel.stockType == 'packet';
    final user = retrieveUserDetail();
    final bool isClothingShop =
        ShopType.fromString(user.data?.shopType ?? '') == ShopType.clothingShop;

    AppLogger.info(
      ('inventoryModel.sellType is ${inventoryModel.stockType}').toString(),
    );

    return Container(
      margin: SymmetricPadding(horizontal: 12, vertical: 6).getPadding(),
      padding: SymmetricPadding(horizontal: 14, vertical: 12).getPadding(),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row 1: Product info + price badge ──────────────────────
          Row(
            children: [
              // Icon
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: AppColors.blackColor.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  CupertinoIcons.cube_box_fill,
                  size: 18.sp,
                  color: AppColors.blackColor,
                ),
              ),
              setWidth(width: 10),
              // Name + barcode
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      inventoryModel.name ?? '',
                      style: CustomTextStyle.customPoppin(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if ((inventoryModel.barcode ?? '').isNotEmpty)
                      Text(
                        inventoryModel.barcode!,
                        style: CustomTextStyle.customOpenSans(
                          fontSize: 11,
                          color: AppColors.greyColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              setWidth(width: 8),
              // Price badge — constrained so large numbers don't overflow
              ConstrainedBox(
                constraints: BoxConstraints(minWidth: 70.w, maxWidth: 110.w),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.blackColor,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Center(child: sellingPrices),
                ),
              ),
            ],
          ),
          setHeight(height: 12),

          // ── Divider ────────────────────────────────────────────────
          Divider(height: 1, color: Colors.grey.shade100),
          setHeight(height: 10),

          // ── Row 2: Qty controls + discount + type badge + remove ───
          Row(
            children: [
              // ── Qty: − qty + ──────────────────────────────────────
              _QtyButton(
                icon: CupertinoIcons.minus,
                onTap: minusOnTap,
                color: Colors.grey.shade300,
                iconColor: AppColors.blackColor,
              ),
              setWidth(width: 6),
              Container(
                height: 34.h,
                width: 44.w,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: Text(
                    inventoryModel.quantity.toString(),
                    style: CustomTextStyle.customPoppin(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              setWidth(width: 6),
              _QtyButton(
                icon: CupertinoIcons.plus,
                onTap: plusOnTap,
                color: AppColors.blackColor,
                iconColor: Colors.white,
              ),
              setWidth(width: 10),

              // ── Discount field ─────────────────────────────────────
              SizedBox(
                height: 40.h,
                width: 60.w,
                child: TextFormField(
                  readOnly: isLooseDiscountEnable,
                  keyboardType: TextInputType.number,
                  controller: dicountController,
                  onChanged: onDiscountChanged,
                  cursorHeight: 14.sp,
                  cursorColor: AppColors.blackColor,
                  style: CustomTextStyle.customOpenSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(8.w, 0, 4.w, 12.h),
                    border: InputBorder.none,
                    label: Text(
                      '%',
                      style: CustomTextStyle.customPoppin(fontSize: 12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.blackColor,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.greyColor),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    labelStyle: CustomTextStyle.customOpenSans(
                      fontSize: 12,
                      color: AppColors.greyColor,
                    ),
                  ),
                ),
              ),
              setWidth(width: 8),

              // ── Type badge ─────────────────────────────────────────
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.blackColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  isClothingShop ? 'PC' : (sellType ? 'PKT' : 'PC'),
                  style: CustomTextStyle.customOpenSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.blackColor,
                  ),
                ),
              ),

              const Spacer(),

              // ── Remove button — icon only ──────────────────────────
              InkWell(
                onTap: removeOnTap,
                borderRadius: BorderRadius.circular(8.r),
                child: Container(
                  width: 34.w,
                  height: 34.h,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    CupertinoIcons.trash,
                    size: 16.sp,
                    color: AppColors.redColor,
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

// ── Qty Button ────────────────────────────────────────────────────────────────
class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;
  final Color iconColor;

  const _QtyButton({
    required this.icon,
    required this.onTap,
    required this.color,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        width: 32.w,
        height: 32.h,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, size: 14.sp, color: iconColor),
      ),
    );
  }
}
