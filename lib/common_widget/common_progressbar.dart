import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'colors.dart';

class CommonProgressbar extends StatelessWidget {
  final double size;
  final Color color;
  const CommonProgressbar({
    super.key,
    this.size = 35,
    this.color = AppColors.whiteColor,
  });

  @override
  Widget build(BuildContext context) {
    return SpinKitFadingCircle(color: color, size: size);
  }
}
