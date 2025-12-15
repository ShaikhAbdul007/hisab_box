import 'package:flutter/material.dart';
import '../helper/textstyle.dart';
import 'colors.dart';

class CommonSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final void Function(bool) onChanged;
  final double labelSize;

  const CommonSwitch({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.labelSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: CustomTextStyle.customNato(fontSize: labelSize)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeTrackColor: AppColors.blackColor,
          activeThumbColor: AppColors.whiteColor,
          inactiveThumbColor: AppColors.whiteColor,
          inactiveTrackColor: AppColors.blackColor,
        ),
      ],
    );
  }
}
