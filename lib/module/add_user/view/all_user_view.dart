import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_button.dart';
import 'package:inventory/common_widget/common_container.dart';
import 'package:inventory/common_widget/common_progressbar.dart';
import 'package:inventory/module/add_user/controller/all_user_controller.dart';
import 'package:inventory/routes/route_name.dart';
import 'package:inventory/routes/routes.dart';

class AllUserView extends GetView<AllUserController> {
  const AllUserView({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      appBarLabel: "Users",
      firstActionChild: CommonContainer(
        height: 30,
        width: 40,
        radius: 5,
        color: AppColors.whiteLigthColor,
        child: InkWell(
          onTap: () async {
            bool res = await AppRoutes.futureNavigationToRoute(
              routeName: AppRouteName.addUser,
            );
            if (res == true) {
              controller.getEmployees();
            }
          },
          child: Icon(CupertinoIcons.add),
        ),
      ),
      body: Obx(
        () =>
            controller.isLoading.value
                ? CommonProgressBar(color: AppColors.blackColor)
                : ListView.builder(
                  itemCount: controller.empolyeeModel.value.data?.length,
                  itemBuilder: (context, index) {
                    var empList = controller.empolyeeModel.value.data?[index];
                    return ListTile(
                      onTap: () {
                        AppRoutes.navigateRoutes(
                          routeName: AppRouteName.allUserDetail,
                          data: empList,
                        );
                      },
                      title: Text(empList?.name ?? ''),
                      subtitle: Text(empList?.role?.name ?? ''),
                      trailing: Icon(Icons.arrow_forward_ios, size: 12.sp),
                    );
                  },
                ),
      ),
    );
  }
}
