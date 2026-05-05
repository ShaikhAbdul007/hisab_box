import 'package:inventory/common_widget/appbar_add_button.dart';
import 'package:flutter/material.dart';

class AddExpensesButton extends StatelessWidget {
  final VoidCallback? onTap;
  const AddExpensesButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return FloatingAddButton(onTap: onTap);
  }
}
