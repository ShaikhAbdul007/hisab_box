import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_container.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/module/loose_category/model/loose_category_model.dart';
import '../../../helper/textstyle.dart';

class LooseCategoryComponent extends StatelessWidget {
  final LooseCategoryModel looseCategoryModel;
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
        looseCategoryModel.name,
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
                looseCategoryModel.price.toString(),
                style: CustomTextStyle.customNato(),
              ),
              setWidth(width: 25),
              Text(
                looseCategoryModel.unit,
                style: CustomTextStyle.customNato(),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                looseCategoryModel.createdAt,
                style: CustomTextStyle.customNato(),
              ),
              setWidth(width: 25),
              Text(
                looseCategoryModel.time,
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
