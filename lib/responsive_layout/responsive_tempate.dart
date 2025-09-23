import 'package:flutter/material.dart';
import 'responsive_layout.dart';
import 'responsive_screens/desktop.dart';
import 'responsive_screens/mobile.dart';
import 'responsive_screens/tablet.dart';

class ResponsiveTemplate extends StatelessWidget {
  final Widget? desktop;
  final Widget? tablet;
  final Widget? mobile;
  const ResponsiveTemplate({
    super.key,
    required this.desktop,
    required this.tablet,
    required this.mobile,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
        desktop: Desktop(body: desktop),
        tablet: Tablet(body: tablet ?? desktop),
        mobile: Mobile(body: mobile ?? desktop),
      ),
    );
  }
}
