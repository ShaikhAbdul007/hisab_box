import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/common_progressbar.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/textstyle.dart';
import '../../../common_widget/colors.dart';
import '../../../common_widget/common_nodatafound.dart';
import '../../revenue/widget/revenue_list_text.dart';
import '../controller/report_controller.dart';

class ReportSaleWidget extends StatelessWidget {
  final ReportController controller;
  const ReportSaleWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Total Revenue card ───────────────────────────────────────
        Obx(() => _TotalRevenueCard(value: controller.totalRevenue.value)),
        setHeight(height: 12),

        // ── Recent Transactions ──────────────────────────────────────
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Row(
                    children: [
                      Container(
                        width: 36.w,
                        height: 36.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          CupertinoIcons.cart_fill,
                          color: const Color(0xFF2E7D32),
                          size: 18.sp,
                        ),
                      ),
                      setWidth(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recent Transactions',
                            style: CustomTextStyle.customPoppin(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Obx(
                            () => Text(
                              '${controller.sellsList.length} records',
                              style: CustomTextStyle.customOpenSans(
                                fontSize: 11,
                                color: AppColors.greyColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                setHeight(height: 10),
                Divider(height: 1, color: Colors.grey.shade100),

                // List
                Expanded(
                  child: Obx(() {
                    if (controller.isSalesLoading.value) {
                      return const Center(
                        child: CommonProgressBar(
                          color: AppColors.blackColor,
                          size: 30,
                        ),
                      );
                    }
                    if (controller.sellsList.isEmpty) {
                      return CommonNoDataFound(message: 'No sales found');
                    }
                    return ListView.builder(
                      padding:
                          SymmetricPadding(
                            horizontal: 0,
                            vertical: 6,
                          ).getPadding(),
                      itemCount: controller.sellsList.length,
                      itemBuilder:
                          (context, index) => RevenueListText(
                            sellItemData: controller.sellsList[index],
                          ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Total Revenue Card ────────────────────────────────────────────────────────
class _TotalRevenueCard extends StatelessWidget {
  final double value;
  const _TotalRevenueCard({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.blackColor,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46.w,
            height: 46.h,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              CupertinoIcons.chart_bar_alt_fill,
              color: Colors.white,
              size: 22.sp,
            ),
          ),
          setWidth(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Revenue',
                style: CustomTextStyle.customOpenSans(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.65),
                ),
              ),
              setHeight(height: 4),
              _AnimatedCounter(
                value: value,
                prefix: '₹ ',
                style: CustomTextStyle.customPoppin(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Animated Counter (local copy — same as overview widget) ───────────────────
class _AnimatedCounter extends StatefulWidget {
  final double value;
  final TextStyle style;
  final String prefix;

  const _AnimatedCounter({
    required this.value,
    required this.style,
    this.prefix = '',
  });

  @override
  State<_AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<_AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  double _prevValue = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _anim = Tween<double>(
      begin: 0,
      end: widget.value,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
    _prevValue = widget.value;
  }

  @override
  void didUpdateWidget(_AnimatedCounter old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _anim = Tween<double>(
        begin: _prevValue,
        end: widget.value,
      ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
      _ctrl
        ..reset()
        ..forward();
      _prevValue = widget.value;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        final v = _anim.value;
        final display =
            v >= 1000
                ? v.toStringAsFixed(0)
                : v.toStringAsFixed(
                  widget.value == widget.value.truncateToDouble() ? 0 : 2,
                );
        return Text('${widget.prefix}$display', style: widget.style);
      },
    );
  }
}
