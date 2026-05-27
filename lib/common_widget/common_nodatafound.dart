import 'package:flutter/material.dart';

import '../helper/textstyle.dart';

class CommonNoDataFound extends StatelessWidget {
  final String message;
  final double size;
  const CommonNoDataFound({super.key, required this.message, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: CustomTextStyle.customRaleway(fontSize: size),
      ),
    );
  }
}
