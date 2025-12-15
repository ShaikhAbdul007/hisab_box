import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/state_manager.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_nodatafound.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/common_progressbar.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/module/home/controller/home_controller.dart';
import 'package:inventory/module/home/widget/home_grid_container.dart';
import 'package:inventory/module/home/widget/quick_action_component.dart';
import 'package:inventory/module/revenue/widget/revenue_list_text.dart';
import 'package:inventory/responsive_layout/responsive_tempate.dart';
import 'package:inventory/routes/routes.dart';
import '../../../common_widget/colors.dart';
import '../../../common_widget/common_divider.dart';
import '../../../helper/textstyle.dart';
import '../../../routes/route_name.dart';
import '../../reports/widget/report_common_continer.dart';
import '../../sell/widget/selling_list_text.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveTemplate(
      desktop: DeskTopScreen(controller: controller),
      tablet: TabletScreen(controller: controller),
      mobile: MobileScreen(controller: controller),
    );
  }
}

class TabletScreen extends StatelessWidget {
  final HomeController controller;
  const TabletScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      appBarLabel: 'Home',
      isleadingButtonRequired: false,
      body: Obx(
        () =>
            controller.isListLoading.value
                ? CommonProgressbar(color: AppColors.blackColor, size: 50)
                : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      setHeight(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.redColor,
                          border: Border.all(),
                        ),
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 3,
                                crossAxisSpacing: 3,
                                mainAxisSpacing: 10,
                              ),

                          itemCount: controller.lis.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () async {
                                if (controller.lis[index].routeName == null) {
                                } else {
                                  var res =
                                      await AppRoutes.futureNavigationToRoute(
                                        routeName:
                                            controller.lis[index].routeName!,
                                      );
                                  if (res == true) {
                                    controller.getRevenveAndStock();
                                  }
                                }
                              },
                              child: HomeGridContainer(
                                customGridModel: controller.lis[index],
                              ),
                            );
                          },
                        ),
                      ),

                      CustomPadding(
                        paddingOption: SymmetricPadding(horizontal: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Activity',
                              style: CustomTextStyle.customOpenSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            controller.sellsList.isNotEmpty
                                ? InkWell(
                                  onTap: () async {
                                    var res =
                                        await AppRoutes.futureNavigationToRoute(
                                          routeName: AppRouteName.sell,
                                        );
                                    if (res == true) {
                                      controller.getRevenveAndStock();
                                    }
                                  },
                                  child: Text(
                                    'see more',
                                    style: CustomTextStyle.customNato(
                                      fontSize: 14,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                )
                                : Container(),
                          ],
                        ),
                      ),
                      setHeight(height: 10),
                      SizedBox(
                        height: 400.h,
                        child:
                            controller.sellsList.isNotEmpty
                                ? ListView.builder(
                                  itemCount:
                                      controller.sellsList.length > 6
                                          ? 6
                                          : controller.sellsList.length,
                                  itemBuilder: (context, index) {
                                    var product = controller.sellsList[index];
                                    return RecentActivitySellingListText(
                                      billModel: product,
                                    );
                                  },
                                )
                                : CommonNodatafound(message: 'No sell found'),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}

class DeskTopScreen extends StatelessWidget {
  final HomeController controller;
  const DeskTopScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      appBarLabel: 'Home',
      // firstActionChild: CommonContainer(
      //   height: 50,
      //   width: 50,
      //   radius: 15,
      //   color: AppColors.whiteColor,
      //   child: Icon(Icons.notifications_none_outlined),
      // ),
      isleadingButtonRequired: false,
      body: Obx(
        () =>
            controller.isListLoading.value
                ? CommonProgressbar(color: AppColors.blackColor, size: 50)
                : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      setHeight(height: 10),
                      Container(
                        margin: SymmetricPadding(horizontal: 10).getPadding(),
                        height: 220,
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 5,
                                childAspectRatio: 3,
                                crossAxisSpacing: 5,
                                mainAxisSpacing: 10,
                              ),
                          itemCount: controller.lis.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () async {
                                if (controller.lis[index].routeName == null) {
                                } else {
                                  var res =
                                      await AppRoutes.futureNavigationToRoute(
                                        routeName:
                                            controller.lis[index].routeName!,
                                      );
                                  if (res == true) {
                                    controller.getRevenveAndStock();
                                  }
                                }
                              },
                              child: HomeGridContainer(
                                customGridModel: controller.lis[index],
                              ),
                            );
                          },
                        ),
                      ),
                      CommonDivider(
                        color: AppColors.blackColor,
                        endIndent: 25,
                        indent: 25,
                      ),
                      CustomPadding(
                        paddingOption: SymmetricPadding(horizontal: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Activity',
                              style: CustomTextStyle.customOpenSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            controller.sellsList.isNotEmpty
                                ? InkWell(
                                  onTap: () async {
                                    var res =
                                        await AppRoutes.futureNavigationToRoute(
                                          routeName: AppRouteName.sell,
                                        );
                                    if (res == true) {
                                      controller.getRevenveAndStock();
                                    }
                                  },
                                  child: Text(
                                    'see more',
                                    style: CustomTextStyle.customNato(
                                      fontSize: 14,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                )
                                : Container(),
                          ],
                        ),
                      ),
                      setHeight(height: 10),
                      SizedBox(
                        height: 400.h,
                        child:
                            controller.sellsList.isNotEmpty
                                ? ListView.builder(
                                  itemCount:
                                      controller.sellsList.length > 6
                                          ? 6
                                          : controller.sellsList.length,
                                  itemBuilder: (context, index) {
                                    var product = controller.sellsList[index];
                                    return RecentActivitySellingListText(
                                      billModel: product,
                                    );
                                  },
                                )
                                : CommonNodatafound(message: 'No sell found'),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}

class MobileScreen extends StatelessWidget {
  final HomeController controller;
  const MobileScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      appBarLabel: 'Home',
      isleadingButtonRequired: false,
      body: Obx(
        () =>
            controller.isListLoading.value
                ? CommonProgressbar(color: AppColors.blackColor, size: 50)
                : RefreshIndicator.adaptive(
                  color: AppColors.blackColor,
                  onRefresh: () {
                    return controller.getRevenveAndStock();
                  },
                  child: CustomPadding(
                    paddingOption: SymmetricPadding(horizontal: 10.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          setHeight(height: 5),
                          SizedBox(
                            height: 150.h,
                            width: 500.w,
                            child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 2.5,
                                    crossAxisSpacing: 0,
                                    mainAxisSpacing: 5,
                                  ),
                              itemCount: controller.lis.length,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () async {
                                    if (controller.lis[index].routeName !=
                                        null) {
                                      AppRoutes.futureNavigationToRoute(
                                        routeName:
                                            controller.lis[index].routeName!,
                                      );
                                    }
                                  },
                                  child: HomeGridContainer(
                                    customGridModel: controller.lis[index],
                                  ),
                                );
                              },
                            ),
                          ),
                          CustomPadding(
                            paddingOption: OnlyPadding(left: 10.0, bottom: 5),
                            child: Text(
                              'Quick Actions',
                              style: CustomTextStyle.customMontserrat(
                                fontSize: 17,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              QuickActionComponent(
                                onTap: () {
                                  AppRoutes.navigateRoutes(
                                    routeName: AppRouteName.inventroyList,
                                  );
                                },
                                contentColor: AppColors.blackColor,
                                bagGroundColor: AppColors.whiteColor,
                                label: 'Add Product',
                                icon: Icons.add,
                              ),
                              QuickActionComponent(
                                onTap: () async {
                                  var res = AppRoutes.futureNavigationToRoute(
                                    routeName: AppRouteName.inventoryView,
                                    data: {'flag': false},
                                  );
                                },
                                label: 'Scan Product',
                                icon: CupertinoIcons.barcode_viewfinder,
                              ),
                            ],
                          ),
                          setHeight(height: 5),
                          CustomPadding(
                            paddingOption: OnlyPadding(left: 10.0),
                            child: Text(
                              'Recent Activites',
                              style: CustomTextStyle.customMontserrat(
                                fontSize: 17,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          controller.sellsList.isNotEmpty
                              ? ReportCommonContiner(
                                height: 400,
                                width: 550,
                                child: ListView.builder(
                                  itemCount: controller.sellsList.length,
                                  itemBuilder: (context, index) {
                                    var product = controller.sellsList[index];
                                    return InkWell(
                                      child: RevenueListText(
                                        //
                                        // index: index,
                                        billModel: product,
                                      ),
                                    );
                                  },
                                ),
                              )
                              : CommonNodatafound(message: 'No sell found'),
                        ],
                      ),
                    ),
                  ),
                ),
      ),
    );
  }
}
