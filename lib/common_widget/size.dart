import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget setHeight({required double height}) {
  return SizedBox(height: height.h);
}

Widget setWidth({required double width}) {
  return SizedBox(width: width.w);
}
