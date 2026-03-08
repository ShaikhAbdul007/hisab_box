import 'package:flutter/material.dart';
import 'package:inventory/common_widget/textfiled.dart';

class UserProfileWidget extends StatelessWidget {
  final String label;
  final String label2;
  final bool readOnly;
  final TextEditingController controller;
  final TextEditingController controller2;

  const UserProfileWidget({
    super.key,
    required this.label,
    this.readOnly = true,
    required this.label2,
    required this.controller,
    required this.controller2,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pehla TextField (e.g., Shop Name / Mobile No)
        Expanded(
          child: CommonTextField(
            readOnly: readOnly,
            label: label,
            hintText: label,
            controller: controller,
          ),
        ),

        const SizedBox(width: 10), // Dono fields ke beech thoda gap
        // Dusra TextField (e.g., Email / Alternative No)
        Expanded(
          child: CommonTextField(
            readOnly: readOnly,
            label: label2,
            hintText: label2,
            controller: controller2,
          ),
        ),
      ],
    );
  }
}
