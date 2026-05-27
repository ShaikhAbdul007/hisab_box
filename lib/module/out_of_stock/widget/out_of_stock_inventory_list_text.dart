import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/helper/shop_type.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/module/near_expire_product/model/near_expiry_model.dart';

class OutOfStockInventoryListText extends StatelessWidget {
  final NeaExpiryItemData neaExpiryItemData;
  final void Function() deleteOnTap;
  final bool isDeleteLoading;
  final ShopType shopType;

  const OutOfStockInventoryListText({
    super.key,
    required this.neaExpiryItemData,
    required this.deleteOnTap,
    required this.isDeleteLoading,
    required this.shopType,
  });

  bool get _isClothing => shopType == ShopType.clothingShop;

  @override
  Widget build(BuildContext context) {
    final String rack = neaExpiryItemData.rack ?? '';
    final String level = neaExpiryItemData.level ?? '';

    return Container(
      margin: SymmetricPadding(horizontal: 12, vertical: 5).getPadding(),
      padding: SymmetricPadding(horizontal: 12, vertical: 10).getPadding(),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 44.w,
            height: 44.h,
            decoration: BoxDecoration(
              color: AppColors.redColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              CupertinoIcons.cube_box_fill,
              color: AppColors.redColor,
              size: 22.sp,
            ),
          ),
          setWidth(width: 10),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  neaExpiryItemData.name ?? '',
                  style: CustomTextStyle.customPoppin(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if ((neaExpiryItemData.barcode ?? '').isNotEmpty)
                  Text(
                    neaExpiryItemData.barcode!,
                    style: CustomTextStyle.customOpenSans(
                      fontSize: 11,
                      color: AppColors.greyColor,
                    ),
                  ),
                setHeight(height: 3),
                if (!_isClothing) ...[
                  if ((neaExpiryItemData.flavour ?? '').isNotEmpty)
                    Text(
                      neaExpiryItemData.flavour!,
                      style: CustomTextStyle.customOpenSans(
                        fontSize: 12,
                        color: AppColors.greyColor,
                      ),
                    ),
                  _infoRow([
                    neaExpiryItemData.weight,
                    neaExpiryItemData.categoryName,
                    neaExpiryItemData.animalCategoryName,
                  ]),
                  if ((neaExpiryItemData.purchaseDate ?? '').isNotEmpty ||
                      (neaExpiryItemData.expiryDate ?? '').isNotEmpty)
                    _dateRow(
                      neaExpiryItemData.purchaseDate,
                      neaExpiryItemData.expiryDate,
                    ),
                ],
                if (_isClothing)
                  _infoRow([
                    neaExpiryItemData.categoryName,
                    neaExpiryItemData.animalCategoryName,
                    neaExpiryItemData.color,
                    neaExpiryItemData.brand,
                  ]),
                setHeight(height: 4),
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.map_pin,
                      size: 11.sp,
                      color: AppColors.greyColor,
                    ),
                    setWidth(width: 3),
                    Text(
                      _locationText(level, rack),
                      style: CustomTextStyle.customOpenSans(
                        fontSize: 11,
                        color: AppColors.greyColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Price + Out of Stock badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${neaExpiryItemData.sellingPrice ?? ''}',
                style: CustomTextStyle.customPoppin(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              setHeight(height: 6),
              Container(
                padding:
                    SymmetricPadding(horizontal: 8, vertical: 3).getPadding(),
                decoration: BoxDecoration(
                  color: AppColors.redColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'Out of Stock',
                  style: CustomTextStyle.customOpenSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
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

  Widget _infoRow(List<String?> values) {
    final parts = values.where((v) => v != null && v.isNotEmpty).toList();
    if (parts.isEmpty) return const SizedBox.shrink();
    return Text(
      parts.join('  ·  '),
      style: CustomTextStyle.customOpenSans(
        fontSize: 12,
        color: AppColors.greyColor,
      ),
    );
  }

  Widget _dateRow(String? purchase, String? expiry) {
    final p = formatDateTime(purchase ?? '');
    final e = formatDateTime(expiry ?? '');
    if (p.isEmpty && e.isEmpty) return const SizedBox.shrink();
    return Row(
      children: [
        Icon(CupertinoIcons.calendar, size: 11.sp, color: AppColors.greyColor),
        setWidth(width: 3),
        if (p.isNotEmpty)
          Text(
            p,
            style: CustomTextStyle.customOpenSans(
              fontSize: 11,
              color: AppColors.greyColor,
            ),
          ),
        if (p.isNotEmpty && e.isNotEmpty)
          Icon(
            CupertinoIcons.arrow_right,
            size: 10.sp,
            color: AppColors.greyColor,
          ),
        if (e.isNotEmpty)
          Text(
            e,
            style: CustomTextStyle.customOpenSans(
              fontSize: 11,
              color: AppColors.redColor,
            ),
          ),
      ],
    );
  }

  String _locationText(String level, String rack) {
    final loc = neaExpiryItemData.location ?? '';
    if (level.isNotEmpty && rack.isNotEmpty) return '$loc / $level / $rack';
    if (rack.isNotEmpty) return '$loc / $rack';
    if (level.isNotEmpty) return '$loc / $level';
    return loc;
  }
}
