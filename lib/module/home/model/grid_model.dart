import 'package:flutter/material.dart';

class CustomGridModel {
  final String? label;
  final double numbers;
  final String? routeName;
  final IconData? icon;

  CustomGridModel({
    this.icon,
    this.routeName,
    this.label,
    required this.numbers,
  });
}
