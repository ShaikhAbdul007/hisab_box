import 'package:flutter/material.dart';

import '../../common_widget/colors.dart';

class Tablet extends StatelessWidget {
  final Widget? body;
  const Tablet({super.key, this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,

      //  drawer: CustomDrawer(),
      body: body ?? Container(),
      // persistentFooterButtons: [Footer()],
    );
  }
}
