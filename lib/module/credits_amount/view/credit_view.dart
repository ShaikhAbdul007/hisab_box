import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_nodatafound.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/common_progressbar.dart';
import 'package:inventory/common_widget/search.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/helper/textstyle.dart';
import '../../../helper/helper.dart';
import '../controller/credit_controller.dart';

class CreditView extends GetView<CredtiController> {
  const CreditView({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      isleadingButtonRequired: false,
      appBarLabel: "Credits",
      body: CustomPadding(
        paddingOption: SymmetricPadding(horizontal: 8.0),
        child: RefreshIndicator.adaptive(
          onRefresh: () => controller.fetchCreditReports(),
          child: Column(
            children: [
              setHeight(height: 10),
              Expanded(
                flex: 2,
                child: CommonSearch(
                  icon: Obx(
                    () =>
                        controller.searchText.value.isNotEmpty
                            ? InkWell(
                              onTap: () {
                                controller.clear();
                                unfocus();
                              },
                              child: Icon(
                                CupertinoIcons.clear_circled_solid,
                                size: 20.sp,
                                color: AppColors.blackColor,
                              ),
                            )
                            : const SizedBox.shrink(),
                  ),
                  label: 'Search',
                  hintText: 'search credit',
                  controller: controller.searchController,
                  onChanged: (val) => controller.searchProduct(val),
                ),
              ),
              setHeight(height: 10),
              Expanded(
                flex: 20,
                child: Obx(
                  () =>
                      controller.customDataLoading.value
                          ? CommonProgressBar(color: AppColors.blackColor)
                          : controller.customerDetailList.isEmpty
                          ? CommonNoDataFound(message: 'No credit found')
                          : ListView.builder(
                            itemCount: controller.customerDetailList.length,
                            itemBuilder: (context, index) {
                              var customerData =
                                  controller.customerDetailList[index];
                              final totalCredit = controller
                                  .calculateTotalCredit(customerData);
                              return Obx(
                                () =>
                                    customerData.customer!.name!
                                            .toLowerCase()
                                            .contains(
                                              controller.searchText.value,
                                            )
                                        ? _CreditCard(
                                          date:
                                              customerData.dateOfCredit ??
                                              'N/A',
                                          mobile:
                                              customerData.customer!.mobileNo ??
                                              '',
                                          name:
                                              customerData.customer!.name ?? '',
                                          address:
                                              customerData.customer!.address ??
                                              '',
                                          remainingAmount:
                                              customerData.remainingAmount ??
                                              '0.0',
                                        )
                                        : Container(),
                              );
                            },
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreditCard extends StatelessWidget {
  final String name;
  final String mobile;
  final String address;
  final String remainingAmount;
  final String date; // Placeholder

  const _CreditCard({
    required this.name,
    required this.mobile,
    required this.address,
    this.remainingAmount = '0.0',
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    // Initials from name
    final parts = name.trim().split(' ');
    final initials =
        parts.length >= 2
            ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
            : name.isNotEmpty
            ? name[0].toUpperCase()
            : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar circle with initials
          Container(
            width: 46.w,
            height: 46.h,
            decoration: BoxDecoration(
              color: AppColors.blackColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: CustomTextStyle.customPoppin(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          setWidth(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: CustomTextStyle.customPoppin(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (address.isNotEmpty) ...[
                  setHeight(height: 2),
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.map_pin,
                        size: 11.sp,
                        color: AppColors.greyColor,
                      ),
                      setWidth(width: 3),
                      Expanded(
                        child: Text(
                          address,
                          style: CustomTextStyle.customOpenSans(
                            fontSize: 12,
                            color: AppColors.greyColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.calendar,
                        size: 11.sp,
                        color: AppColors.greyColor,
                      ),
                      setWidth(width: 3),
                      Expanded(
                        child: Text(
                          formatDateTime(date),
                          style: CustomTextStyle.customOpenSans(
                            fontSize: 12,
                            color: AppColors.greyColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.redColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  remainingAmount.isNotEmpty ? '₹ $remainingAmount' : '₹ 0.0',
                  style: CustomTextStyle.customOpenSans(
                    fontSize: 12,
                    color: AppColors.redColor,
                  ),
                ),
              ),
              setHeight(height: 6),
              if (mobile.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.blackColor.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.phone_fill,
                        size: 11.sp,
                        color: AppColors.blackColor,
                      ),
                      setWidth(width: 4),
                      Text(
                        mobile,
                        style: CustomTextStyle.customOpenSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.blackColor,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
