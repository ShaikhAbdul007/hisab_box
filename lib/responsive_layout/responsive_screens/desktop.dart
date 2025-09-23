import 'package:flutter/material.dart';

import '../../common_widget/colors.dart';

class Desktop extends StatelessWidget {
  final Widget? body;
  final String? headerLabel;

  const Desktop({super.key, this.body, this.headerLabel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
     // persistentFooterButtons: [Footer()],
      body: Row(
        children: [
         // Expanded(flex: 2, child: CustomDrawer()),
          Expanded(
            flex: 15,
            child: Container(
              color: AppColors.whiteColor,
              child: body ?? Container(),
            ),
          ),
        ],
      ),
    );
  }
}
