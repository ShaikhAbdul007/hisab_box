import 'package:flutter/material.dart';
import 'package:inventory/common_widget/common_appbar.dart';

class ReportView extends StatelessWidget {
  const ReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      appBarLabel: 'Reports',
      body: ListView(children: [Text('Reports')]),
    );
  }
}
