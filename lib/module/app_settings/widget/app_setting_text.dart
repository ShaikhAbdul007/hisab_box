import 'package:flutter/material.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_switch.dart';

import '../../../helper/textstyle.dart';

class AppSettingText extends StatelessWidget {
  final String label;
  final bool value;
  final void Function(bool) onChanged;
  const AppSettingText({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5),
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: AppColors.whiteColor,
        ),
        child: CommonSwitch(label: label, value: value, onChanged: onChanged)
      ),
    );
  }
}
