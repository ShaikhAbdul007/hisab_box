import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/module/near_expire_product/model/near_expiry_model.dart';

class NearExpiryText extends StatelessWidget {
  final NeaExpiryItemData inventoryModel;
  final void Function()? onTap;
  const NearExpiryText({super.key, required this.inventoryModel, this.onTap});

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
              // Icon
              Container(
                width: 44.w,
                height: 44.h,
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  CupertinoIcons.time_solid,
                  color: Colors.orange.shade700,
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
                      inventoryModel.name ?? '',
                      style: CustomTextStyle.customPoppin(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if ((inventoryModel.flavour ?? '').isNotEmpty)
                      Text(
                        inventoryModel.flavour!,
                        style: CustomTextStyle.customOpenSans(
                          fontSize: 12,
                          color: AppColors.greyColor,
                        ),
                      ),
                    setHeight(height: 3),
                    _infoRow([
                      inventoryModel.animalCategoryName,
                      inventoryModel.weight,
                      inventoryModel.categoryName,
                    ]),
                    setHeight(height: 4),
                    // Expiry date row — highlighted
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.calendar,
                          size: 11.sp,
                          color: AppColors.greyColor,
                        ),
                        setWidth(width: 3),
                        Text(
                          formatDateTime(inventoryModel.purchaseDate ?? ''),
                          style: CustomTextStyle.customOpenSans(
                            fontSize: 11,
                            color: AppColors.greyColor,
                          ),
                        ),
                        Icon(
                          CupertinoIcons.arrow_right,
                          size: 10.sp,
                          color: AppColors.greyColor,
                        ),
                        Text(
                          formatDateTime(inventoryModel.expiryDate ?? ''),
                          style: CustomTextStyle.customOpenSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.redColor,
                          ),
                        ),
                      ],
                    ),
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

              // Price + qty badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${inventoryModel.sellingPrice ?? ''}',
                    style: CustomTextStyle.customPoppin(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
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
