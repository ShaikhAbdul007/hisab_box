import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inventory/common_widget/common_padding.dart';
import '../helper/textstyle.dart';

class CommonPopupAppbar extends StatelessWidget {
  final String label;
  final void Function() onPressed;
  final double size;
  final bool isCancelButtonRequire;
  const CommonPopupAppbar({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = 15,
    this.isCancelButtonRequire = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPadding(
      paddingOption: SymmetricPadding(horizontal: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label, style: CustomTextStyle.customNato(fontSize: size)),
          isCancelButtonRequire
              ? IconButton(
                icon: Icon(CupertinoIcons.clear),
                onPressed: onPressed,
              )
              : Container(),
        ],
      ),
    );
  }
}
