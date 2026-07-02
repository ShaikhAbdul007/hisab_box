import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/appbar_add_button.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_nodatafound.dart';
import 'package:inventory/common_widget/common_progressbar.dart';
import 'package:inventory/module/add_user/controller/all_user_controller.dart';
import 'package:inventory/responsive_layout/dimension.dart';
import 'package:inventory/routes/route_name.dart';
import 'package:inventory/routes/routes.dart';

class AllUserView extends GetView<AllUserController> {
  const AllUserView({super.key});

  @override
  Widget build(BuildContext context) {
    if (isDesktop(context)) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text('Users'),
          leading: IconButton(
            icon: const Icon(CupertinoIcons.back),
            onPressed: () => Get.back(),
          ),
          actions: [
            Obx(
              () => (controller.empolyeeModel.value.data?.length ?? 0) < 3
                  ? AppBarAddButton(
                      tooltip: 'Add User',
                      onTap: () async {
                        bool res = await AppRoutes.futureNavigationToRoute(
                          routeName: AppRouteName.addUser,
                        );
                        if (res == true) {
                          controller.getEmployees();
                        }
                      },
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(width: 20),
          ],
          surfaceTintColor: AppColors.greyColorShade100,
          backgroundColor: AppColors.greyColorShade100,
        ),
        body: Center(
          child: Container(
            width: 600,
            margin: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Obx(
              () => controller.isLoading.value
                  ? const Center(child: CommonProgressBar(color: AppColors.blackColor))
                  : controller.empolyeeModel.value.data!.isEmpty
                      ? const CommonNoDataFound(message: 'No user found')
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: controller.empolyeeModel.value.data?.length ?? 0,
                          separatorBuilder: (context, index) => const Divider(height: 1),
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
                              trailing: const Icon(Icons.arrow_forward_ios, size: 12),
                            );
                          },
                        ),
            ),
          ),
        ),
      );
    }

    return CommonAppbar(
      appBarLabel: "Users",
      firstActionChild: Obx(
        () =>
            (controller.empolyeeModel.value.data?.length ?? 0) < 3
                ? AppBarAddButton(
                  tooltip: 'Add User',
                  onTap: () async {
                    bool res = await AppRoutes.futureNavigationToRoute(
                      routeName: AppRouteName.addUser,
                    );
                    if (res == true) {
                      controller.getEmployees();
                    }
                  },
                )
                : Container(),
      ),
      body: Obx(
        () =>
            controller.isLoading.value
                ? CommonProgressBar(color: AppColors.blackColor)
                : controller.empolyeeModel.value.data!.isEmpty
                ? CommonNoDataFound(message: 'No user found')
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
