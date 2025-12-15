import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory/common_widget/colors.dart';

import '../helper/textstyle.dart';

class CommomAminatedtext extends StatelessWidget {
  final double fontSize;
  final String label;
  final FontWeight fontWeight;
  final Color? color;
  const CommomAminatedtext({
    super.key,
    this.fontSize = 15,
    required this.label,
    this.fontWeight = FontWeight.w700,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedTextKit(
      isRepeatingAnimation: false,
      repeatForever: false,
      animatedTexts: [
        TypewriterAnimatedText(
          label,
          textStyle: CustomTextStyle.customNato(
            fontSize: fontSize.sp,
            fontWeight: fontWeight,
            color: color ?? AppColors.blackColor,
          ),
        ),
      ],
    );
  }
}
