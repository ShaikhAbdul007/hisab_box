import 'package:flutter/material.dart';
import 'dimension.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget desktop;
  final Widget tablet;
  final Widget mobile;

  const ResponsiveLayout({
    super.key,
    required this.desktop,
    required this.tablet,
    required this.mobile,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth >= destopSize) {
          return desktop;
        } else if (constraints.maxWidth >= tabletSize &&
            constraints.maxWidth < destopSize) {
          return tablet;
        } else {
          return mobile;
        }
      },
    );
  }
}