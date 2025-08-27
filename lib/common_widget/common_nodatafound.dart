import 'package:flutter/material.dart';

import '../helper/textstyle.dart';

class CommonNodatafound extends StatelessWidget {
  final String message;
  const CommonNodatafound({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(message, style: CustomTextStyle.customRaleway(fontSize: 20)),
    );
  }
}
