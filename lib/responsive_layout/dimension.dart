import 'dart:io';
import 'package:flutter/material.dart';

const destopSize = 1000;
const tabletSize = 800;
const mobileScreen = 500;

bool isDesktop(BuildContext context) {
  return MediaQuery.sizeOf(context).width >= destopSize;
}

bool isTablet(BuildContext context) {
  return MediaQuery.sizeOf(context).width >= tabletSize &&
      MediaQuery.sizeOf(context).width < destopSize;
}

bool isMobile(BuildContext context) {
  return MediaQuery.sizeOf(context).width < mobileScreen;
}

bool isIosOrMac() {
  return Platform.isIOS || Platform.isMacOS;
}

bool isAndriodOrWindow() {
  return Platform.isAndroid || Platform.isWindows;
}