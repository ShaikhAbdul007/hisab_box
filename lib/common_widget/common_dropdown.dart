import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory/helper/textstyle.dart';

import 'colors.dart';
import 'common_padding.dart';

class CustomStaticDropDown extends StatelessWidget {
  final List<dynamic> listItems;
  final dynamic selectedDropDownItem;
  final dynamic hintText;
  final Color? dropDownBgColor;
  final Function(dynamic value) notifyParent;
  const CustomStaticDropDown({
    super.key,
    required this.listItems,
    required this.hintText,
    required this.notifyParent,
    this.selectedDropDownItem,
    this.dropDownBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomPadding(
          paddingOption: OnlyPadding(left: 8.0, bottom: 5),
          child: RichText(
            text: TextSpan(
              text: hintText ?? '',
              style: CustomTextStyle.customNato(letterSpacing: 1, fontSize: 10),
              children: [
                TextSpan(
                  text: ' *',
                  style: CustomTextStyle.customNato(color: AppColors.redColor),
                ),
              ],
            ),
          ),
        ),
        Container(
          margin: SymmetricPadding(horizontal: 10).getPadding(),

          decoration: BoxDecoration(
            color: dropDownBgColor ?? AppColors.whiteColor,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: AppColors.greyColor, width: 0.5.w),
          ),

          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<dynamic>(
              decoration: InputDecoration(
                fillColor: Colors.white,
                iconColor: AppColors.blackColor,
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                contentPadding:
                    OnlyPadding(left: 10, right: 5, top: 15).getPadding(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(color: Colors.transparent),
                ),
              ),
              validator: ((value) => value == null ? "Please $hintText" : null),
              isExpanded: true,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              isDense: true,
              initialValue: selectedDropDownItem,
              dropdownColor: AppColors.whiteColor,
              hint: Text(
                hintText,
                style: CustomTextStyle.customNato(
                  fontSize: 12,
                  color: AppColors.greyColor,
                ),
              ),
              items:
                  listItems.map<DropdownMenuItem<dynamic>>((dynamic item) {
                    return DropdownMenuItem<dynamic>(
                      value: item,
                      child: Text(
                        "$item",
                        style: CustomTextStyle.customNato(
                          fontSize: 12,
                          color: AppColors.greyColor,
                        ),
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                notifyParent(value);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class CustomDropDown extends StatelessWidget {
  final List<dynamic> listItems;
  final dynamic selectedDropDownItem;
  final dynamic hintText;
  final Color? dropDownBgColor;
  final Function(dynamic value) notifyParent;
  const CustomDropDown({
    super.key,
    required this.listItems,
    required this.hintText,
    required this.notifyParent,
    this.selectedDropDownItem,
    this.dropDownBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomPadding(
          paddingOption: OnlyPadding(left: 8.0, bottom: 5),
          child: RichText(
            text: TextSpan(
              text: hintText ?? '',
              style: CustomTextStyle.customNato(letterSpacing: 1, fontSize: 10),
              children: [
                TextSpan(
                  text: ' *',
                  style: CustomTextStyle.customNato(color: AppColors.redColor),
                ),
              ],
            ),
          ),
        ),
        Container(
          margin: SymmetricPadding(horizontal: 10).getPadding(),
          decoration: BoxDecoration(
            color: dropDownBgColor ?? AppColors.whiteColor,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: AppColors.greyColor, width: 0.5.w),
          ),

          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<dynamic>(
              decoration: InputDecoration(
                fillColor: Colors.white,
                iconColor: AppColors.blackColor,
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                contentPadding:
                    OnlyPadding(left: 10, right: 5, top: 15).getPadding(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(color: Colors.transparent),
                ),
              ),
              validator: ((value) => value == null ? "Please $hintText" : null),
              isExpanded: true,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              isDense: true,
              initialValue: selectedDropDownItem,
              dropdownColor: AppColors.whiteColor,
              hint: Text(
                hintText,
                style: CustomTextStyle.customNato(
                  fontSize: 12,
                  color: AppColors.greyColor,
                ),
              ),
              items:
                  listItems.map<DropdownMenuItem<dynamic>>((dynamic item) {
                    return DropdownMenuItem<dynamic>(
                      value: item.id,
                      child: Text(
                        "${item.name}",
                        style: CustomTextStyle.customNato(
                          fontSize: 12,
                          color: AppColors.greyColor,
                        ),
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                notifyParent(value);
              },
            ),
          ),
        ),
      ],
    );
  }
}
