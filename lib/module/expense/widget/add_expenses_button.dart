import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inventory/common_widget/colors.dart';

class AddExpensesButton extends StatelessWidget {
  final VoidCallback? onTap;
  const AddExpensesButton({super.key,  this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.green,
        ),
        height: 40,
        width: 40,
        child: Center(
          child: Icon(CupertinoIcons.add, color: AppColors.whiteColor),
        ),
      ),
    );
  }
}
