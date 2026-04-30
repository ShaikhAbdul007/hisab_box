import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_button.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/module/near_expire_product/model/near_expiry_model.dart';

class OutOfStockInventoryListText extends StatelessWidget {
  final NeaExpiryItemData neaExpiryItemData;
  final void Function() deleteOnTap;
  final bool isDeleteLoading;
  const OutOfStockInventoryListText({
    super.key,
    required this.neaExpiryItemData,
    required this.deleteOnTap,
    required this.isDeleteLoading,
  });

  @override
  Widget build(BuildContext context) {
    String rack = neaExpiryItemData.rack ?? '';
    String level = neaExpiryItemData.level ?? '';
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    neaExpiryItemData.name ?? '',
                    style: CustomTextStyle.customPoppin(fontSize: 17),
                  ),
                  if (neaExpiryItemData.flavour case ('' || null)) ...{
                    Container(),
                  } else ...{
                    setHeight(height: 2),
                    Text(
                      neaExpiryItemData.flavour ?? '',
                      style: CustomTextStyle.customOpenSans(
                        color: AppColors.greyColor,
                      ),
                    ),
                  },
                  Row(
                    children: [
                      Text(
                        '${neaExpiryItemData.animalCategoryName}',
                        style: CustomTextStyle.customOpenSans(
                          color: AppColors.greyColor,
                        ),
                      ),
                      if (neaExpiryItemData.weight?.isNotEmpty ?? false) ...{
                        Text(
                          '/${neaExpiryItemData.weight}',
                          style: CustomTextStyle.customOpenSans(
                            color: AppColors.greyColor,
                          ),
                        ),
                      },
                      Text(
                        '/${neaExpiryItemData.categoryName}',
                        style: CustomTextStyle.customOpenSans(
                          color: AppColors.greyColor,
                        ),
                      ),
                      Icon(CupertinoIcons.map_pin, size: 15.sp),
                      Text(
                        level.isNotEmpty && rack.isNotEmpty
                            ? '${neaExpiryItemData.location}/$level/$rack'
                            : level.isEmpty && rack.isNotEmpty
                            ? '${neaExpiryItemData.location}/$rack'
                            : rack.isEmpty && level.isNotEmpty
                            ? '${neaExpiryItemData.location}/$level'
                            : '${neaExpiryItemData.location}',
                        style: CustomTextStyle.customOpenSans(
                          color: AppColors.greyColor,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        (neaExpiryItemData.purchaseDate ?? ''),
                        style: CustomTextStyle.customOpenSans(
                          color: AppColors.greyColor,
                        ),
                      ),
                      Text(
                        ' - ',
                        style: CustomTextStyle.customOpenSans(
                          color: AppColors.greyColor,
                        ),
                      ),
                      Text(
                        (neaExpiryItemData.expiryDate ?? ''),
                        style: CustomTextStyle.customOpenSans(
                          color: AppColors.redColor,
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
                  color: AppColors.redColor,
                ),
                setHeight(height: 5),
                Text(
                  '\u{20B9} ${neaExpiryItemData.sellingPrice}',
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
                CommonButton(
                  isLoading: isDeleteLoading,
                  height: 25,
                  radius: 5,
                  bgColor: AppColors.redColor,
                  onTap: deleteOnTap,
                  label: 'Delete',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
