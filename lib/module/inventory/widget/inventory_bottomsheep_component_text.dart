import 'package:flutter/material.dart';

import '../../../common_widget/textfiled.dart';

class InventoryBottomsheetComponentText extends StatelessWidget {
  final int flex1;
  final int flex2;
  final int? inputLength1;
  final int? inputLength2;
  final TextEditingController controller1;
  final TextEditingController controller2;
  final String label1;
  final String hintText1;
  final String label2;
  final String hintText2;
  final bool readOnly2;
  final bool readOnly1;
  final TextInputType? keyboardType1;
  final TextInputType? keyboardType2;
  final String? Function(String?)? validator1;
  final String? Function(String?)? validator2;
  final Function(String)? onChanged2;
  final Function(String)? onChanged1;
  const InventoryBottomsheetComponentText({
    super.key,
    required this.controller1,
    required this.controller2,
    this.keyboardType1,
    this.keyboardType2,
    required this.label1,
    required this.hintText1,
    required this.label2,
    required this.hintText2,
    this.validator1,
    this.validator2,
    this.flex1 = 1,
    this.flex2 = 1,
    this.inputLength1,
    this.inputLength2,
    this.readOnly2 = false,
    this.readOnly1 = false,
    this.onChanged2,
    this.onChanged1,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          flex: flex1,
          child: CommonTextField(
            onChanged: onChanged1,
            readOnly: readOnly1,
            validator: validator1,
            contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            inputLength: inputLength1,
            keyboardType: keyboardType1,
            hintText: hintText1,
            label: label1,
            controller: controller1,
          ),
        ),
        Flexible(
          flex: flex2,
          child: CommonTextField(
            onChanged: onChanged2,
            readOnly: readOnly2,
            validator: validator2,
            contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            inputLength: inputLength2,
            keyboardType: keyboardType2,
            hintText: hintText2,
            label: label2,
            controller: controller2,
          ),
        ),
      ],
    );
  }
}
