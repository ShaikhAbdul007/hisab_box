import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/helper/shop_type.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/module/inventorylist/model/inventory_model.dart';

class InventroyListText extends StatelessWidget {
  final InventoryItem inventoryModel;
  final void Function()? onTap;
  final bool isInventoryScanSelected;
  final ShopType shopType;

  const InventroyListText({
    super.key,
    required this.inventoryModel,
    this.onTap,
    required this.isInventoryScanSelected,
    required this.shopType,
  });

  bool get _isClothing => shopType == ShopType.clothingShop;

  @override
  Widget build(BuildContext context) {
    final String rack = inventoryModel.rack ?? '';
    final String level = inventoryModel.level ?? '';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(5.r),
          ),
          margin: SymmetricPadding(horizontal: 15, vertical: 5).getPadding(),
          padding: SymmetricPadding(horizontal: 5, vertical: 4).getPadding(),
          child: Row(
            children: [
              // ── Left column ──────────────────────────────────────────────
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name — always shown
                    Text(
                      inventoryModel.name ?? '',
                      style: CustomTextStyle.customPoppin(fontSize: 17),
                    ),
                    Text(
                      inventoryModel.barcode!,
                      style: CustomTextStyle.customOpenSans(
                        color: AppColors.greyColor,
                      ),
                    ),

                    // ── Pet Shop only ─────────────────────────────────────
                    if (!_isClothing) ...[
                      // Flavour
                      if ((inventoryModel.flavour ?? '').isNotEmpty) ...[
                        setHeight(height: 2),
                        Text(
                          inventoryModel.flavour!,
                          style: CustomTextStyle.customOpenSans(
                            color: AppColors.greyColor,
                          ),
                        ),
                      ],
                      // weight / category (pet shop specific)
                      _infoRow([
                        inventoryModel.weight,
                        inventoryModel.categoryName,
                      ]),
                      // Purchase date → Expiry date
                      if ((inventoryModel.purchaseDate ?? '').isNotEmpty ||
                          (inventoryModel.expireDate ?? '').isNotEmpty)
                        _dateRow(
                          inventoryModel.purchaseDate,
                          inventoryModel.expireDate,
                        ),
                    ],

                    // ── Clothing Shop only ────────────────────────────────
                    if (_isClothing) ...[
                      // Category / Color / Brand (size is animalTypeName — shown in common)
                      _infoRow([
                        inventoryModel.categoryName,
                        inventoryModel.animalTypeName,
                        inventoryModel.color,
                        inventoryModel.brand,
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

              // ── Right column ─────────────────────────────────────────────
              Expanded(
                child: Column(
                  children: [
                    Icon(
                      CupertinoIcons.cube_box_fill,
                      size: 27,
                      color: getColor(),
                    ),
                    setHeight(height: 5),
                    Text(
                      '\u{20B9} ${inventoryModel.sellingPrice ?? ''}',
                      style: CustomTextStyle.customPoppin(
                        color: AppColors.blackColor,
                        fontSize: 18,
                      ),
                    ),
                    FittedBox(
                      child: RichText(
                        text: TextSpan(
                          text: inventoryModel.quantity.toString(),
                          style: CustomTextStyle.customOpenSans(
                            color: getColor(),
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Renders non-empty values joined by ' / '
  Widget _infoRow(List<String?> values) {
    final parts = values.where((v) => v != null && v.isNotEmpty).toList();
    if (parts.isEmpty) return const SizedBox.shrink();
    return Text(
      parts.join(' / '),
      style: CustomTextStyle.customOpenSans(color: AppColors.greyColor),
    );
  }

  /// Purchase date → Expiry date row
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
    final loc = inventoryModel.location ?? '';
    if (level.isNotEmpty && rack.isNotEmpty) return '$loc/$level/$rack';
    if (rack.isNotEmpty) return '$loc/$rack';
    if (level.isNotEmpty) return '$loc/$level';
    return loc;
  }

  Color getColor() {
    final qty =
        double.tryParse(inventoryModel.quantity?.toString() ?? '0') ?? 0;
    if (qty > 0 && qty < 10) return AppColors.orangeColor;
    if (qty == 0) return AppColors.redColor;
    return AppColors.blackColor;
  }
}
