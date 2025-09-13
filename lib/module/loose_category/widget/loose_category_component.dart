import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_container.dart';
import 'package:inventory/common_widget/size.dart';
import '../../../helper/textstyle.dart';
import '../../inventory/model/product_model.dart';

class LooseCategoryComponent extends StatelessWidget {
  final ProductModel looseCategoryModel;
  final void Function()? onTap;

  const LooseCategoryComponent({
    super.key,
    required this.looseCategoryModel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        looseCategoryModel.name ?? '',
        style: CustomTextStyle.customNato(
          fontSize: 18,
          color: AppColors.blackColor,
        ),
      ),
      subtitle: Column(
        children: [
          Row(
            children: [
              Text(
                looseCategoryModel.weight ?? '',
                style: CustomTextStyle.customNato(),
              ),
              setWidth(width: 25),
              Text(
                '\u{20B9} ${looseCategoryModel.sellingPrice}',
                style: CustomTextStyle.customNato(),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                looseCategoryModel.createdDate ?? '',
                style: CustomTextStyle.customNato(),
              ),
              setWidth(width: 25),
              Text(
                looseCategoryModel.createdTime ?? '',
                style: CustomTextStyle.customNato(),
              ),
            ],
          ),
        ],
      ),
      trailing: InkWell(
        onTap: onTap,

        child: CommonContainer(
          height: 40,
          width: 50,
          radius: 5,
          color: AppColors.blackColor,
          child: Icon(
            CupertinoIcons.delete,
            size: 18,
            color: AppColors.whiteColor,
          ),
        ),
      ),
    );
  }
}
