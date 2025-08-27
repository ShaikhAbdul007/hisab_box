import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_nodatafound.dart';
import 'package:inventory/common_widget/common_progressbar.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/module/home/controller/home_controller.dart';
import 'package:inventory/module/home/widget/home_grid_container.dart';
import 'package:inventory/routes/routes.dart';
import '../../../common_widget/colors.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../helper/textstyle.dart';
import '../../sell/widget/selling_list_text.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

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
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        height: 220,
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 1.2,
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
                                isTextRequired:
                                    controller.lis[index].isTextRequired ??
                                    false,
                              ),
                            );
                          },
                        ),
                      ),
                      Divider(
                        color: AppColors.blackColor,
                        endIndent: 25,
                        indent: 25,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Activity',
                              style: CustomTextStyle.customUbuntu(fontSize: 18,fontWeight: FontWeight.w300),
                            ),
                            InkWell(
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
                                  decoration: TextDecoration.underline,
                                  fontSize: 15,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      setHeight(height: 10),
                      SizedBox(
                        height: 400,
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
                                      saleModel: product,
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

class SalesPieChart extends StatelessWidget {
  final List<Map<String, dynamic>> chartData;

  const SalesPieChart({super.key, required this.chartData});

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections:
            chartData.asMap().entries.map((entry) {
              int index = entry.key;
              final data = entry.value;

              return PieChartSectionData(
                value: data['value'],
                title: data['label'],
                color: Colors.primaries[index % Colors.primaries.length],
                radius: 60,
                titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            }).toList(),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }
}
