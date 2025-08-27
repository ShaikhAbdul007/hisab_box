import 'package:flutter/material.dart';

class CustomGridModel {
  final String label;
  final double numbers;
  final String? routeName;
  final IconData? icon;
  final bool? isTextRequired;

  CustomGridModel({
    this.icon,
    this.isTextRequired,
    this.routeName,
    required this.label,
    required this.numbers,
  });
}
