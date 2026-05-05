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
    final Color stockColor = _stockColor();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
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
              // ── Left: product icon ──────────────────────────────────────
              Container(
                width: 44.w,
                height: 44.h,
                decoration: BoxDecoration(
                  color: stockColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  CupertinoIcons.cube_box_fill,
                  color: stockColor,
                  size: 22.sp,
                ),
              ),
              setWidth(width: 10),

              // ── Middle: product info ────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      inventoryModel.name ?? '',
                      style: CustomTextStyle.customPoppin(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if ((inventoryModel.barcode ?? '').isNotEmpty)
                      Text(
                        inventoryModel.barcode!,
                        style: CustomTextStyle.customOpenSans(
                          fontSize: 11,
                          color: AppColors.greyColor,
                        ),
                      ),
                    setHeight(height: 3),

                    // Pet Shop specific
                    if (!_isClothing) ...[
                      if ((inventoryModel.flavour ?? '').isNotEmpty)
                        _chip(inventoryModel.flavour!, Colors.purple),
                      _infoRow([
                        inventoryModel.weight,
                        inventoryModel.categoryName,
                        inventoryModel.animalTypeName,
                      ]),
                      if ((inventoryModel.purchaseDate ?? '').isNotEmpty ||
                          (inventoryModel.expireDate ?? '').isNotEmpty)
                        _dateRow(
                          inventoryModel.purchaseDate,
                          inventoryModel.expireDate,
                        ),
                    ],

                    // Clothing specific
                    if (_isClothing)
                      _infoRow([
                        inventoryModel.categoryName,
                        inventoryModel.animalTypeName,
                        inventoryModel.color,
                        inventoryModel.brand,
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

              // ── Right: price + stock badge ──────────────────────────────
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${inventoryModel.sellingPrice ?? ''}',
                    style: CustomTextStyle.customPoppin(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.blackColor,
                    ),
                  ),
                  setHeight(height: 6),
                  Container(
                    padding:
                        SymmetricPadding(
                          horizontal: 8,
                          vertical: 3,
                        ).getPadding(),
                    decoration: BoxDecoration(
                      color: stockColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      '${inventoryModel.quantity ?? 0}',
                      style: CustomTextStyle.customOpenSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: stockColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 3),
      padding: SymmetricPadding(horizontal: 6, vertical: 2).getPadding(),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        label,
        style: CustomTextStyle.customOpenSans(fontSize: 11, color: color),
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
    final loc = inventoryModel.location ?? '';
    if (level.isNotEmpty && rack.isNotEmpty) return '$loc / $level / $rack';
    if (rack.isNotEmpty) return '$loc / $rack';
    if (level.isNotEmpty) return '$loc / $level';
    return loc;
  }

  Color _stockColor() {
    final qty =
        double.tryParse(inventoryModel.quantity?.toString() ?? '0') ?? 0;
    if (qty == 0) return AppColors.redColor;
    if (qty < 10) return AppColors.orangeColor;
    return Colors.green.shade600;
  }

  Color getColor() => _stockColor();
}
