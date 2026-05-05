import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/common_padding.dart';
import '../../../common_widget/colors.dart';
import '../../../common_widget/common_nodatafound.dart';
import '../../../common_widget/common_progressbar.dart';
import '../../../common_widget/size.dart';
import '../../../helper/textstyle.dart';
import '../controller/report_controller.dart';

class ReportOverviewWidget extends StatelessWidget {
  final ReportController controller;
  const ReportOverviewWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: SymmetricPadding(horizontal: 0, vertical: 12).getPadding(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Payment mode stats grid ──────────────────────────────────
          Obx(
            () =>
                controller.isDashBoardOverView.value
                    ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: CommonProgressBar(
                          color: AppColors.blackColor,
                          size: 30,
                        ),
                      ),
                    )
                    : Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _PaymentStatCard(
                                label: 'Cash',
                                value: controller.totalCash.value,
                                icon: CupertinoIcons.money_dollar_circle_fill,
                                color: const Color(0xFF2E7D32),
                              ),
                            ),
                            setWidth(width: 10),
                            Expanded(
                              child: _PaymentStatCard(
                                label: 'UPI',
                                value: controller.totalUpi.value,
                                icon: CupertinoIcons.qrcode,
                                color: const Color(0xFF6A1B9A),
                              ),
                            ),
                          ],
                        ),
                        setHeight(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _PaymentStatCard(
                                label: 'Card',
                                value: controller.totalCard.value,
                                icon: CupertinoIcons.creditcard_fill,
                                color: const Color(0xFF1565C0),
                              ),
                            ),
                            setWidth(width: 10),
                            Expanded(
                              child: _PaymentStatCard(
                                label: 'Credit',
                                value: controller.totalCredit.value,
                                icon:
                                    CupertinoIcons
                                        .person_crop_circle_badge_minus,
                                color: const Color(0xFFC62828),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
          ),
          setHeight(height: 16),

          // ── Sale Trends chart ────────────────────────────────────────
          _SectionCard(
            title: 'Sale Trends',
            subtitle: 'Top selling products by quantity',
            icon: CupertinoIcons.chart_bar_fill,
            iconColor: const Color(0xFF1565C0),
            child: Obx(
              () =>
                  controller.isTopSellingProductsChart.value
                      ? const SizedBox(
                        height: 160,
                        child: Center(
                          child: CommonProgressBar(
                            color: AppColors.blackColor,
                            size: 28,
                          ),
                        ),
                      )
                      : controller.reportTopProductGraph.isEmpty
                      ? SizedBox(
                        height: 120,
                        child: CommonNoDataFound(message: 'No trend data'),
                      )
                      : _AnimatedBarChart(
                        data: controller.reportTopProductGraph,
                      ),
            ),
          ),
          setHeight(height: 16),

          // ── Top Products list ────────────────────────────────────────
          _SectionCard(
            title: 'Top Products',
            subtitle: 'Best sellers ranked by units sold',
            icon: CupertinoIcons.star_fill,
            iconColor: const Color(0xFFE65100),
            child: Obx(
              () =>
                  controller.isTopSellingProducts.value
                      ? const SizedBox(
                        height: 120,
                        child: Center(
                          child: CommonProgressBar(
                            color: AppColors.blackColor,
                            size: 28,
                          ),
                        ),
                      )
                      : controller.reportTopProductList.isEmpty
                      ? SizedBox(
                        height: 100,
                        child: CommonNoDataFound(message: 'No products found'),
                      )
                      : Column(
                        children: [
                          ...List.generate(
                            controller.reportTopProductList.length,
                            (index) => _TopProductRow(
                              rank: index + 1,
                              product: controller.reportTopProductList[index],
                            ),
                          ),
                          // Load more
                          Obx(
                            () =>
                                controller.isLoadingMoreTopProducts.value
                                    ? const Padding(
                                      padding: EdgeInsets.all(8),
                                      child: CommonProgressBar(
                                        color: AppColors.blackColor,
                                        size: 24,
                                      ),
                                    )
                                    : controller.topProductHasMore
                                    ? TextButton(
                                      onPressed:
                                          () =>
                                              controller.loadMoreTopProducts(),
                                      child: Text(
                                        'Load more',
                                        style: CustomTextStyle.customOpenSans(
                                          fontSize: 13,
                                          color: AppColors.blackColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    )
                                    : const SizedBox.shrink(),
                          ),
                        ],
                      ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Payment Stat Card ─────────────────────────────────────────────────────────
class _PaymentStatCard extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;
  final Color color;

  const _PaymentStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          setWidth(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: CustomTextStyle.customOpenSans(
                    fontSize: 12,
                    color: AppColors.greyColor,
                  ),
                ),
                setHeight(height: 2),
                _AnimatedCounter(
                  value: value,
                  style: CustomTextStyle.customPoppin(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.blackColor,
                  ),
                  prefix: '₹',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Card wrapper ──────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              Container(
                width: 36.w,
                height: 36.h,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: iconColor, size: 18.sp),
              ),
              setWidth(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: CustomTextStyle.customPoppin(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: CustomTextStyle.customOpenSans(
                      fontSize: 11,
                      color: AppColors.greyColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          setHeight(height: 14),
          child,
        ],
      ),
    );
  }
}

// ── Animated Bar Chart ────────────────────────────────────────────────────────
class _AnimatedBarChart extends StatefulWidget {
  final List<dynamic> data;
  const _AnimatedBarChart({required this.data});

  @override
  State<_AnimatedBarChart> createState() => _AnimatedBarChartState();
}

class _AnimatedBarChartState extends State<_AnimatedBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _anim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxQty = widget.data
        .map((e) => (e.qty ?? 0).toDouble())
        .fold<double>(0, (a, b) => a > b ? a : b);

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        return SizedBox(
          height: 180.h,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: (maxQty + maxQty * 0.2).clamp(1, double.infinity),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  tooltipBorderRadius: BorderRadius.circular(8.r),
                  tooltipPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final d = widget.data[groupIndex];
                    return BarTooltipItem(
                      '${d.productName}\n',
                      CustomTextStyle.customPoppin(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      children: [
                        TextSpan(
                          text: 'Qty: ${d.qty}',
                          style: CustomTextStyle.customOpenSans(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: (maxQty / 4).clamp(1, double.infinity),
                getDrawingHorizontalLine:
                    (value) =>
                        FlLine(color: Colors.grey.shade100, strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget:
                        (value, meta) => Text(
                          value.toInt().toString(),
                          style: CustomTextStyle.customOpenSans(
                            fontSize: 10,
                            color: AppColors.greyColor,
                          ),
                        ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx >= widget.data.length) {
                        return const SizedBox.shrink();
                      }
                      final name = widget.data[idx].productName ?? '';
                      final short =
                          name.length > 6 ? '${name.substring(0, 6)}…' : name;
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          short,
                          style: CustomTextStyle.customOpenSans(
                            fontSize: 9,
                            color: AppColors.greyColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: List.generate(widget.data.length, (index) {
                final item = widget.data[index];
                final qty =
                    (double.tryParse(item.qty.toString()) ?? 0) * _anim.value;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: qty,
                      width: 18,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF1565C0),
                          const Color(0xFF42A5F5),
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      borderRadius: BorderRadius.circular(6.r),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: (maxQty + maxQty * 0.2).clamp(1, double.infinity),
                        color: Colors.grey.shade100,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        );
      },
    );
  }
}

// ── Top Product Row ───────────────────────────────────────────────────────────
class _TopProductRow extends StatelessWidget {
  final int rank;
  final dynamic product;

  const _TopProductRow({required this.rank, required this.product});

  @override
  Widget build(BuildContext context) {
    final Color rankColor =
        rank == 1
            ? const Color(0xFFFFB300)
            : rank == 2
            ? const Color(0xFF90A4AE)
            : rank == 3
            ? const Color(0xFFBF8970)
            : AppColors.greyColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color:
            rank <= 3 ? rankColor.withValues(alpha: 0.06) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color:
              rank <= 3
                  ? rankColor.withValues(alpha: 0.2)
                  : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 30.w,
            height: 30.h,
            decoration: BoxDecoration(
              color: rankColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: CustomTextStyle.customPoppin(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: rankColor,
                ),
              ),
            ),
          ),
          setWidth(width: 10),

          // Product name
          Expanded(
            child: Text(
              product.productName ?? '',
              style: CustomTextStyle.customPoppin(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Qty badge
          _AnimatedCounter(
            value: (product.qty ?? 0).toDouble(),
            style: CustomTextStyle.customPoppin(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.blackColor,
            ),
            suffix: ' sold',
            suffixStyle: CustomTextStyle.customOpenSans(
              fontSize: 11,
              color: AppColors.greyColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Animated Counter ──────────────────────────────────────────────────────────
class _AnimatedCounter extends StatefulWidget {
  final double value;
  final TextStyle style;
  final String prefix;
  final String suffix;
  final TextStyle? suffixStyle;

  const _AnimatedCounter({
    required this.value,
    required this.style,
    this.prefix = '',
    this.suffix = '',
    this.suffixStyle,
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
      duration: const Duration(milliseconds: 800),
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
        final display =
            _anim.value >= 1000
                ? _anim.value.toStringAsFixed(0)
                : _anim.value.toStringAsFixed(
                  widget.value == widget.value.truncateToDouble() ? 0 : 2,
                );
        return RichText(
          text: TextSpan(
            text: '${widget.prefix}$display',
            style: widget.style,
            children:
                widget.suffix.isNotEmpty
                    ? [
                      TextSpan(
                        text: widget.suffix,
                        style: widget.suffixStyle ?? widget.style,
                      ),
                    ]
                    : [],
          ),
        );
      },
    );
  }
}

// ── ReportOverViewContainer (kept for backward compat in sale tab) ────────────
class ReportOverViewContainer extends StatelessWidget {
  final String label;
  final String labelValue;
  final double width;
  final double height;

  const ReportOverViewContainer({
    super.key,
    required this.label,
    required this.labelValue,
    this.height = 80,
    this.width = 170,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: SymmetricPadding(horizontal: 2, vertical: 5).getPadding(),
      padding: SymmetricPadding(horizontal: 14, vertical: 14).getPadding(),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: CustomTextStyle.customOpenSans(
              fontSize: 12,
              color: AppColors.greyColor,
            ),
          ),
          setHeight(height: 6),
          _AnimatedCounter(
            value: double.tryParse(labelValue) ?? 0,
            prefix: '₹ ',
            style: CustomTextStyle.customPoppin(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
