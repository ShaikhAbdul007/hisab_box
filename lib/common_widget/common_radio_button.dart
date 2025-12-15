import 'package:flutter/material.dart';
import '../helper/textstyle.dart';
import 'colors.dart';

class CommonRadioButton extends StatelessWidget {
  final String label;
  final int groupValue;
  final int? radioValue;
  final void Function(int?)? onChanged;
  const CommonRadioButton({
    super.key,
    required this.label,
    required this.groupValue,
    this.onChanged,
    this.radioValue,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile(
      activeColor: AppColors.blackColor,
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: CustomTextStyle.customPoppin()),
      value: radioValue ?? 0,
      groupValue: groupValue,
      onChanged: onChanged,
    );
  }
}
