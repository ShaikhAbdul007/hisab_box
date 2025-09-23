import 'package:flutter/material.dart';

import '../helper/textstyle.dart';

class CommonNodatafound extends StatelessWidget {
  final String message;
  final double size;
  const CommonNodatafound({super.key, required this.message, this.size = 20});

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
