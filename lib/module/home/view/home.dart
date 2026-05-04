import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/state_manager.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_nodatafound.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/common_progressbar.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/module/home/controller/home_controller.dart';
import 'package:inventory/module/home/model/dashboard_model.dart';
import 'package:inventory/module/home/widget/home_grid_container.dart';
import 'package:inventory/module/home/widget/quick_action_component.dart';
import 'package:inventory/responsive_layout/responsive_tempate.dart';
import 'package:inventory/routes/routes.dart';
import '../../../common_widget/colors.dart';
import '../../../helper/set_format_date.dart';
import '../../../helper/textstyle.dart';
import '../../../routes/route_name.dart';
import '../../reports/widget/report_common_continer.dart';

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
      body: Container(),

      // Obx(
      //   () =>
      //       controller.isListLoading.value
      //           ? CommonProgressBar(color: AppColors.blackColor, size: 50)
      //           : SingleChildScrollView(
      //             child: Column(
      //               crossAxisAlignment: CrossAxisAlignment.start,
      //               children: [
      //                 setHeight(height: 10),
      //                 Container(
      //                   decoration: BoxDecoration(
      //                     color: AppColors.redColor,
      //                     border: Border.all(),
      //                   ),
      //                   child: GridView.builder(
      //                     gridDelegate:
      //                         SliverGridDelegateWithFixedCrossAxisCount(
      //                           crossAxisCount: 3,
      //                           childAspectRatio: 3,
      //                           crossAxisSpacing: 3,
      //                           mainAxisSpacing: 10,
      //                         ),

      //                     itemCount: controller.lis.length,
      //                     itemBuilder: (context, index) {
      //                       return InkWell(
      //                         onTap: () async {
      //                           if (controller.lis[index].routeName == null) {
      //                           } else {
      //                             var res =
      //                                 await AppRoutes.futureNavigationToRoute(
      //                                   routeName:
      //                                       controller.lis[index].routeName!,
      //                                 );
      //                             if (res == true) {
      //                               controller.loadDashboard();
      //                             }
      //                           }
      //                         },
      //                         child: HomeGridContainer(
      //                           customGridModel: controller.lis[index],
      //                         ),
      //                       );
      //                     },
      //                   ),
      //                 ),

      //                 CustomPadding(
      //                   paddingOption: SymmetricPadding(horizontal: 15),
      //                   child: Row(
      //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                     children: [
      //                       Text(
      //                         'Recent Activity',
      //                         style: CustomTextStyle.customOpenSans(
      //                           fontSize: 18,
      //                           fontWeight: FontWeight.w300,
      //                         ),
      //                       ),
      //                       controller.sellsList.isNotEmpty
      //                           ? InkWell(
      //                             onTap: () async {
      //                               var res =
      //                                   await AppRoutes.futureNavigationToRoute(
      //                                     routeName: AppRouteName.sell,
      //                                   );
      //                               if (res == true) {
      //                                 controller.loadDashboard();
      //                               }
      //                             },
      //                             child: Text(
      //                               'see more',
      //                               style: CustomTextStyle.customNato(
      //                                 fontSize: 14,
      //                                 color: Colors.grey.shade500,
      //                               ),
      //                             ),
      //                           )
      //                           : Container(),
      //                     ],
      //                   ),
      //                 ),
      //                 setHeight(height: 10),
      //                 SizedBox(
      //                   height: 400.h,
      //                   child:
      //                       controller.sellsList.isNotEmpty
      //                           ? ListView.builder(
      //                             itemCount:
      //                                 controller.sellsList.length > 6
      //                                     ? 6
      //                                     : controller.sellsList.length,
      //                             itemBuilder: (context, index) {
      //                               var product = controller.sellsList[index];
      //                               return RecentActivitySellingListText(
      //                                 billModel: product,
      //                               );
      //                             },
      //                           )
      //                           : CommonNoDataFound(
      //                             message: 'No Recent Activity found',
      //                           ),
      //                 ),
      //               ],
      //             ),
      //           ),
      // ),
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
      body: Container(),

      // Obx(
      //   () =>
      //       controller.isListLoading.value
      //           ? CommonProgressBar(color: AppColors.blackColor, size: 50)
      //           : SingleChildScrollView(
      //             child: Column(
      //               crossAxisAlignment: CrossAxisAlignment.start,
      //               children: [
      //                 setHeight(height: 10),
      //                 Container(
      //                   margin: SymmetricPadding(horizontal: 10).getPadding(),
      //                   height: 220,
      //                   child: GridView.builder(
      //                     gridDelegate:
      //                         SliverGridDelegateWithFixedCrossAxisCount(
      //                           crossAxisCount: 5,
      //                           childAspectRatio: 3,
      //                           crossAxisSpacing: 5,
      //                           mainAxisSpacing: 10,
      //                         ),
      //                     itemCount: controller.lis.length,
      //                     itemBuilder: (context, index) {
      //                       return InkWell(
      //                         onTap: () async {
      //                           if (controller.lis[index].routeName == null) {
      //                           } else {
      //                             var res =
      //                                 await AppRoutes.futureNavigationToRoute(
      //                                   routeName:
      //                                       controller.lis[index].routeName!,
      //                                 );
      //                             if (res == true) {
      //                               AppLogger.info(('res is $res').toString());
      //                               controller.loadDashboard();
      //                             }
      //                           }
      //                         },
      //                         child: HomeGridContainer(
      //                           customGridModel: controller.lis[index],
      //                         ),
      //                       );
      //                     },
      //                   ),
      //                 ),
      //                 CommonDivider(
      //                   color: AppColors.blackColor,
      //                   endIndent: 25,
      //                   indent: 25,
      //                 ),
      //                 CustomPadding(
      //                   paddingOption: SymmetricPadding(horizontal: 15),
      //                   child: Row(
      //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                     children: [
      //                       Text(
      //                         'Recent Activity',
      //                         style: CustomTextStyle.customOpenSans(
      //                           fontSize: 18,
      //                           fontWeight: FontWeight.w300,
      //                         ),
      //                       ),
      //                       controller.sellsList.isNotEmpty
      //                           ? InkWell(
      //                             onTap: () async {
      //                               var res =
      //                                   await AppRoutes.futureNavigationToRoute(
      //                                     routeName: AppRouteName.sell,
      //                                   );
      //                               if (res == true) {
      //                                 controller.loadDashboard();
      //                               }
      //                             },
      //                             child: Text(
      //                               'see more',
      //                               style: CustomTextStyle.customNato(
      //                                 fontSize: 14,
      //                                 color: Colors.grey.shade500,
      //                               ),
      //                             ),
      //                           )
      //                           : Container(),
      //                     ],
      //                   ),
      //                 ),
      //                 setHeight(height: 10),
      //                 SizedBox(
      //                   height: 400.h,
      //                   child:
      //                       controller.sellsList.isNotEmpty
      //                           ? ListView.builder(
      //                             itemCount:
      //                                 controller.sellsList.length > 6
      //                                     ? 6
      //                                     : controller.sellsList.length,
      //                             itemBuilder: (context, index) {
      //                               var product = controller.sellsList[index];
      //                               return RecentActivitySellingListText(
      //                                 billModel: product,
      //                               );
      //                             },
      //                           )
      //                           : CommonNoDataFound(
      //                             message: 'No Recent Activity found',
      //                           ),
      //                 ),
      //               ],
      //             ),
      //           ),
      // ),
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
      secondActionChild: Row(
        children: [
          InkWell(
            onTap: () {
              AppRoutes.navigateRoutes(
                routeName: AppRouteName.nearExpireProduct,
              );
            },
            child: Obx(
              () =>
                  controller.nearExpiryCount.value > 0
                      ? Badge.count(
                        count: int.parse(
                          controller.nearExpiryCount.value.toString(),
                        ),
                        isLabelVisible: true,
                        backgroundColor: AppColors.redColor,

                        child: Icon(CupertinoIcons.time_solid),
                      )
                      : Icon(CupertinoIcons.time_solid),
            ),
          ),
          Obx(() {
            final count = controller.pendingTransfers.length;
            return Stack(
              children: [
                IconButton(
                  icon: const Icon(CupertinoIcons.bell_fill),
                  onPressed: () {
                    AppRoutes.navigateRoutes(
                      routeName: AppRouteName.notificationView,
                    );
                  },
                ),
                if (count > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: AllPadding(all: 4).getPadding(),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 18.w,
                        minHeight: 18.h,
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
      body: Obx(
        () =>
            controller.isListLoading.value
                ? CommonProgressBar(color: AppColors.blackColor, size: 50)
                : CustomPadding(
                  paddingOption: SymmetricPadding(horizontal: 10.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        setHeight(height: 5),
                        Obx(
                          () => SizedBox(
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
                                      var ress =
                                          await AppRoutes.futureNavigationToRoute(
                                            routeName:
                                                controller
                                                    .lis[index]
                                                    .routeName!,
                                          );
                                      if (ress == true) {
                                        controller.loadDashboard();
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
                                AppRoutes.futureNavigationToRoute(
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
                            ? ReportCommonContainer(
                              height: 310,
                              width: 550,
                              child: NotificationListener<ScrollNotification>(
                                onNotification: (scroll) {
                                  if (scroll.metrics.pixels >=
                                      scroll.metrics.maxScrollExtent - 50) {
                                    controller.loadMoreActivities();
                                  }
                                  return false;
                                },
                                child: ListView.builder(
                                  itemCount: controller.sellsList.length + 1,
                                  itemBuilder: (context, index) {
                                    // Bottom loader
                                    if (index == controller.sellsList.length) {
                                      return Obx(
                                        () =>
                                            controller
                                                    .isLoadingMoreActivities
                                                    .value
                                                ? const Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: 8,
                                                  ),
                                                  child: Center(
                                                    child: CommonProgressBar(
                                                      size: 24,
                                                      color:
                                                          AppColors.blackColor,
                                                    ),
                                                  ),
                                                )
                                                : const SizedBox(height: 8),
                                      );
                                    }
                                    final activity =
                                        controller.sellsList[index];
                                    return InkWell(
                                      // onTap:
                                      //     () => controller.navigateFromActivity(
                                      //       activity,
                                      //     ),
                                      child: ActivityTile(activity: activity),
                                    );
                                  },
                                ),
                              ),
                            )
                            : CommonNoDataFound(
                              message: 'No Recent Activity found',
                            ),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }
}

/// Activity tile — type icon, description, reference, time + navigation arrow
class ActivityTile extends StatelessWidget {
  final RecentActivitiesData activity;
  const ActivityTile({super.key, required this.activity});

  IconData get _icon {
    switch (activity.type) {
      case 'sale':
        return CupertinoIcons.cart_fill;
      case 'grn':
        return CupertinoIcons.arrow_2_circlepath;
      case 'product':
        return CupertinoIcons.cube_box_fill;
      default:
        return CupertinoIcons.clock_fill;
    }
  }

  Color get _color {
    switch (activity.type) {
      case 'sale':
        return Colors.green;
      case 'grn':
        return Colors.orange;
      case 'product':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPadding(
      paddingOption: SymmetricPadding(vertical: 4, horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(_icon, color: _color, size: 20.sp),
          ),
          setWidth(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.description ?? activity.referenceNo ?? '',
                  style: CustomTextStyle.customOpenSans(fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                setHeight(height: 2),
                Row(
                  children: [
                    if ((activity.referenceNo ?? '').isNotEmpty)
                      Text(
                        activity.referenceNo!,
                        style: CustomTextStyle.customOpenSans(
                          fontSize: 11,
                          color: AppColors.greyColor,
                        ),
                      ),
                    const Spacer(),
                    Text(
                      formatDateTime(
                        activity.createdAt ?? '',
                        showDate: true,
                        showTime: false,
                      ),
                      style: CustomTextStyle.customOpenSans(
                        fontSize: 11,
                        color: AppColors.greyColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // if (activity.type == 'sale' || activity.type == 'grn')
          //   Icon(
          //     CupertinoIcons.chevron_right,
          //     size: 14.sp,
          //     color: AppColors.greyColor,
          //   ),
        ],
      ),
    );
  }
}
