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
import 'package:inventory/routes/route_name.dart';
import 'package:inventory/routes/routes.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../../helper/helper.dart';
import '../../../cache_manager/cache_manager.dart';
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
                                          billNo: customerData.billNo ?? '',
                                          remainingAmount:
                                              customerData.remainingAmount ??
                                              '0.0',
                                          onTap: () async {
                                            var res =
                                                await AppRoutes.futureNavigationToRoute(
                                                  routeName:
                                                      AppRouteName
                                                          .creditPaymentView,
                                                  data: customerData,
                                                );
                                            if (res == true) {
                                              controller.fetchCreditReports();
                                            }
                                          },
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

class _CreditCard extends StatelessWidget with CacheManager {
  final String name;
  final String mobile;
  final String address;
  final String remainingAmount;
  final String billNo;
  final String date; // Placeholder
  final VoidCallback? onTap;

  _CreditCard({
    required this.name,
    required this.mobile,
    required this.address,
    this.remainingAmount = '0.0',
    this.billNo = '',
    required this.date,
    this.onTap,
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

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
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
                    setHeight(height: 3),
                    if (mobile.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.phone_fill,
                            size: 11.sp,
                            color: AppColors.greyColor,
                          ),
                          setWidth(width: 4),
                          Text(
                            mobile,
                            style: CustomTextStyle.customOpenSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.greyColor,
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
                setHeight(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // WhatsApp Button
                    _buildActionButton(
                      icon: CupertinoIcons.chat_bubble_2_fill,
                      color: Color(0xFF25D366),
                      onTap:
                          () => _shareViaWhatsApp(
                            name,
                            mobile,
                            billNo,
                            remainingAmount,
                          ),
                    ),
                    setWidth(width: 6),
                    // Share Button
                    _buildActionButton(
                      icon: CupertinoIcons.share,
                      color: AppColors.blackColor,
                      onTap:
                          () => _shareCredit(
                            name,
                            mobile,
                            billNo,
                            remainingAmount,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        width: 36.w,
        height: 36.h,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Center(child: Icon(icon, size: 16.sp, color: color)),
      ),
    );
  }

  Future<void> _shareViaWhatsApp(
    String name,
    String mobile,
    String billNo,
    String amount,
  ) async {
    if (mobile.isEmpty) {
      showSnackBar(error: 'Phone number not available');
      return;
    }

    // Get shop name from cache
    final user = retrieveUserDetail();
    final shopName = user.data?.name ?? 'Hisab Box';

    final message =
        'Credit Payment Reminder from $shopName\n\n'
        'Dear $name,\n\n'
        'This is a gentle reminder regarding your outstanding credit:\n\n'
        '📱 Bill No: $billNo\n'
        '💰 Outstanding Amount: ₹$amount\n\n'
        'We kindly request you to settle this payment at your earliest convenience.\n'
        'Please feel free to contact us if you have any questions.\n\n'
        'Powered by Hisab Box';

    // WhatsApp URL - format: https://wa.me/{phonenumber}?text={urlencodedtext}
    final cleanMobile = mobile.replaceAll(RegExp(r'[^0-9]'), '');
    final whatsappUrl = Uri.parse(
      'whatsapp://send?phone=91$cleanMobile&text=${Uri.encodeComponent(message)}',
    );

    try {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } catch (e) {
      showSnackBar(error: 'Could not open WhatsApp: ${e.toString()}');
    }
  }

  Future<void> _shareCredit(
    String name,
    String mobile,
    String billNo,
    String amount,
  ) async {
    try {
      // Get shop name from cache
      final user = retrieveUserDetail();
      final shopName = user.data?.name ?? 'Hisab Box';

      final shareText =
          'Credit Payment Reminder\n\n'
          'Dear $name,\n\n'
          'This is a gentle reminder regarding your outstanding credit from $shopName:\n\n'
          '📱 Bill No: $billNo\n'
          '💰 Outstanding Amount: ₹$amount\n\n'
          'We kindly request you to settle this payment at your earliest convenience.\n'
          'Please feel free to contact us if you have any questions.\n\n'
          'Powered by Hisab Box';

      await Share.share(
        shareText,
        subject: 'Credit Payment Reminder - $shopName',
      );
    } catch (e) {
      showSnackBar(error: 'Could not share: ${e.toString()}');
    }
  }
}
