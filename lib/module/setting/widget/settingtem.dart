import 'package:flutter/material.dart';
import '../../../common_widget/colors.dart';
import '../../../helper/textstyle.dart';

class SettingItem extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool subtitleReq;
  final Widget? trailing;
  final Widget? leading;
  final Function()? onTap;
  const SettingItem({
    super.key,
    required this.label,
    this.subtitle = '',
    this.onTap,
    this.trailing,
    this.leading,
    this.subtitleReq = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: ListTile(
        onTap: onTap,
        leading: leading ?? SizedBox(height: 0, width: 0),
        title: Text(label, style: CustomTextStyle.customPoppin()),
        subtitle:
            subtitleReq
                ? Text(
                  subtitle,
                  style: CustomTextStyle.customRaleway(
                    color: AppColors.greyColor,
                  ),
                )
                : null,
        trailing: trailing ?? SizedBox(height: 0, width: 0),
      ),
    );
  }
}
