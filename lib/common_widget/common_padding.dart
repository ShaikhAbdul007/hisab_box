import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

sealed class PaddingOption {
  EdgeInsets getPadding();
}

class SymmetricPadding extends PaddingOption {
  final double horizontal;
  final double vertical;

  SymmetricPadding({this.horizontal = 0, this.vertical = 0});

  @override
  EdgeInsets getPadding() {
    return EdgeInsets.symmetric(horizontal: horizontal.w, vertical: vertical.h);
  }
}

class AllPadding extends PaddingOption {
  final double all;

  AllPadding({required this.all});

  @override
  EdgeInsets getPadding() {
    return EdgeInsets.all(all.r);
  }
}

class OnlyPadding extends PaddingOption {
  final double left;
  final double top;
  final double right;
  final double bottom;

  OnlyPadding({this.left = 0, this.top = 0, this.right = 0, this.bottom = 0});

  @override
  EdgeInsets getPadding() {
    return EdgeInsets.only(
      left: left.w,
      top: top.h,
      right: right.w,
      bottom: bottom.h,
    );
  }
}

class CustomPadding extends StatelessWidget {
  final PaddingOption paddingOption;
  final Widget child;
  const CustomPadding({
    super.key,
    required this.child,
    required this.paddingOption,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(padding: paddingOption.getPadding(), child: child);
  }
}
