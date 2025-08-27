import 'package:flutter/material.dart';

class CommonContainer extends StatelessWidget {
  final double height;
  final double width;
  final double radius;
  final Widget child;
  final Color color;
  const CommonContainer({
    super.key,
    required this.height,
    required this.width,
    required this.radius,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: color,
      ),
      child: child,
    );
  }
}
