import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/module/inventorylist/model/inventory_model.dart';
import 'package:inventory/module/near_expire_product/model/near_expiry_model.dart';
import '../../inventory/model/product_model.dart';

class NearExpiryText extends StatelessWidget {
  final NeaExpiryItemData inventoryModel;
  final void Function()? onTap;
  const NearExpiryText({super.key, required this.inventoryModel, this.onTap});

  @override
  Widget build(BuildContext context) {
    String rack = inventoryModel.rack ?? '';
    String level = inventoryModel.level ?? '';
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
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        inventoryModel.name ?? '',
                        style: CustomTextStyle.customPoppin(fontSize: 17),
                      ),
                      if (inventoryModel.flavour case ('' || null)) ...{
                        Container(),
                      } else ...{
                        setHeight(height: 2),
                        Text(
                          inventoryModel.flavour ?? '',
                          style: CustomTextStyle.customOpenSans(
                            color: AppColors.greyColor,
                          ),
                        ),
                      },
                      Row(
                        children: [
                          Text(
                            '${inventoryModel.animalCategoryName}',
                            style: CustomTextStyle.customOpenSans(
                              color: AppColors.greyColor,
                            ),
                          ),
                          if (inventoryModel.weight?.isNotEmpty ?? false) ...{
                            Text(
                              '/${inventoryModel.weight}',
                              style: CustomTextStyle.customOpenSans(
                                color: AppColors.greyColor,
                              ),
                            ),
                          },

                          Text(
                            '/${inventoryModel.categoryName}',
                            style: CustomTextStyle.customOpenSans(
                              color: AppColors.greyColor,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(CupertinoIcons.map_pin, size: 15.sp),
                          Text(
                            level.isNotEmpty && rack.isNotEmpty
                                ? '${inventoryModel.location}/$level/$rack'
                                : level.isEmpty && rack.isNotEmpty
                                ? '${inventoryModel.location}/$rack'
                                : rack.isEmpty && level.isNotEmpty
                                ? '${inventoryModel.location}/$level'
                                : '${inventoryModel.location}',
                            style: CustomTextStyle.customOpenSans(
                              color: AppColors.greyColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
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
                      '\u{20B9} ${inventoryModel.sellingPrice}',
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

  String getText() {
    String? text;
    int qty = int.tryParse(inventoryModel.quantity ?? '0') ?? 0;
    if (qty > 0 && qty < 10) {
      text = 'Low Stock';
    } else if (qty == 0) {
      text = 'Out of Stock';
    }
    return text ?? '';
  }

  Color getColor() {
    double qty =
        double.tryParse(inventoryModel.quantity?.toString() ?? '0') ?? 0;
    if (qty > 0 && qty < 10) {
      return AppColors.orangeColor;
    } else if (qty == 0) {
      return AppColors.redColor;
    } else {
      return AppColors.blackColor;
    }
  }
}
