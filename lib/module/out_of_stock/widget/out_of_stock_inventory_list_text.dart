import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_button.dart';
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
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(5.r),
      ),
      margin: SymmetricPadding(horizontal: 15, vertical: 5).getPadding(),
      padding: SymmetricPadding(horizontal: 5, vertical: 4).getPadding(),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  neaExpiryItemData.name ?? '',
                  style: CustomTextStyle.customPoppin(fontSize: 17),
                ),
                Text(
                  neaExpiryItemData.barcode!,
                  style: CustomTextStyle.customOpenSans(
                    color: AppColors.greyColor,
                  ),
                ),
                if (!_isClothing) ...[
                  if ((neaExpiryItemData.flavour ?? '').isNotEmpty) ...[
                    setHeight(height: 2),
                    Text(
                      neaExpiryItemData.flavour!,
                      style: CustomTextStyle.customOpenSans(
                        color: AppColors.greyColor,
                      ),
                    ),
                  ],
                  _infoRow([
                    neaExpiryItemData.weight,
                    neaExpiryItemData.categoryName,
                  ]),
                  if ((neaExpiryItemData.purchaseDate ?? '').isNotEmpty ||
                      (neaExpiryItemData.expiryDate ?? '').isNotEmpty)
                    _dateRow(
                      neaExpiryItemData.purchaseDate,
                      neaExpiryItemData.expiryDate,
                    ),
                ],
                if (_isClothing) ...[
                  _infoRow([
                    neaExpiryItemData.categoryName,
                    neaExpiryItemData.animalCategoryName,
                    neaExpiryItemData.color,
                    neaExpiryItemData.brand,
                  ]),
                ],

                Row(
                  children: [
                    Icon(CupertinoIcons.map_pin, size: 15.sp),
                    Text(
                      _locationText(level, rack),
                      style: CustomTextStyle.customOpenSans(
                        color: AppColors.greyColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Icon(
                  CupertinoIcons.cube_box_fill,
                  size: 27,
                  color: AppColors.redColor,
                ),
                setHeight(height: 5),
                Text(
                  '\u{20B9} ${neaExpiryItemData.sellingPrice ?? ''}',
                  style: CustomTextStyle.customPoppin(
                    color: AppColors.blackColor,
                    fontSize: 18,
                  ),
                ),
                FittedBox(
                  child: RichText(
                    text: TextSpan(
                      text: neaExpiryItemData.quantity.toString(),
                      style: CustomTextStyle.customOpenSans(
                        color: AppColors.blackColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text: ' in stock',
                          style: CustomTextStyle.customOpenSans(
                            color: AppColors.blackColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // CommonButton(
                //   isLoading: isDeleteLoading,
                //   height: 25,
                //   radius: 5,
                //   bgColor: AppColors.redColor,
                //   onTap: deleteOnTap,
                //   label: 'Delete',
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(List<String?> values) {
    final parts = values.where((v) => v != null && v.isNotEmpty).toList();
    if (parts.isEmpty) return const SizedBox.shrink();
    return Text(
      parts.join(' / '),
      style: CustomTextStyle.customOpenSans(color: AppColors.greyColor),
    );
  }

  Widget _dateRow(String? purchase, String? expiry) {
    final p = formatDateTime(purchase ?? '');
    final e = formatDateTime(expiry ?? '');
    if (p.isEmpty && e.isEmpty) return const SizedBox.shrink();
    return Row(
      children: [
        if (p.isNotEmpty)
          Text(
            p,
            style: CustomTextStyle.customOpenSans(
              color: AppColors.greyColor,
              fontSize: 11,
            ),
          ),
        if (p.isNotEmpty && e.isNotEmpty)
          Icon(
            CupertinoIcons.arrow_right,
            size: 12.sp,
            color: AppColors.blackColor,
          ),
        if (e.isNotEmpty)
          Text(
            e,
            style: CustomTextStyle.customOpenSans(
              color: AppColors.redColor,
              fontSize: 11,
            ),
          ),
      ],
    );
  }

  String _locationText(String level, String rack) {
    final loc = neaExpiryItemData.location ?? '';
    if (level.isNotEmpty && rack.isNotEmpty) return '$loc/$level/$rack';
    if (rack.isNotEmpty) return '$loc/$rack';
    if (level.isNotEmpty) return '$loc/$level';
    return loc;
  }
}
