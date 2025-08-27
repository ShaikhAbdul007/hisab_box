import 'package:flutter/material.dart';
import 'package:inventory/helper/textstyle.dart';

import 'colors.dart';

class CommonDropDown extends StatelessWidget {
  final List<dynamic> listItems;
  final dynamic selectedDropDownItem;
  final dynamic hintText;

  final Function(dynamic value) notifyParent;
  const CommonDropDown({
    super.key,
    required this.listItems,
    required this.hintText,
    required this.notifyParent,
    this.selectedDropDownItem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 0.5, color: Colors.grey.shade100),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<dynamic>(
          decoration: InputDecoration(
            fillColor: Colors.grey.shade100,
            iconColor: AppColors.blackColor,
            filled: true,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.transparent),
            ),
            contentPadding: EdgeInsets.only(left: 10, right: 5, top: 15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.transparent),
            ),
          ),
          validator:
              ((value) => value == null ? "Please $hintText" : null),
          isExpanded: true,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          isDense: true,
          value: selectedDropDownItem,
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
    );
  }
}



class CustomDropDown extends StatelessWidget {
  final List<dynamic> listItems;
  final dynamic selectedDropDownItem;
  final dynamic hintText;

  final Function(dynamic value) notifyParent;
  const CustomDropDown({
    super.key,
    required this.listItems,
    required this.hintText,
    required this.notifyParent,
    this.selectedDropDownItem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 0.5, color: Colors.grey.shade100),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<dynamic>(
          decoration: InputDecoration(
            fillColor: Colors.grey.shade100,
            iconColor: AppColors.blackColor,
            filled: true,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.transparent),
            ),
            contentPadding: EdgeInsets.only(left: 10, right: 5, top: 15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.transparent),
            ),
          ),
          validator:
              ((value) => value == null ? "Please $hintText" : null),
          isExpanded: true,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          isDense: true,
          value: selectedDropDownItem,
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
    );
  }
}
