import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../helper/textstyle.dart';

class CommonPopupAppbar extends StatelessWidget {
  final String label;
  final void Function() onPressed;
  final double size;
  const CommonPopupAppbar({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = 15,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label, style: CustomTextStyle.customNato(fontSize: size)),
          IconButton(icon: Icon(CupertinoIcons.clear), onPressed: onPressed),
        ],
      ),
    );
  }
}
