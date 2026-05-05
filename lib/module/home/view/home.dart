import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_nodatafound.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/common_progressbar.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/module/home/controller/home_controller.dart';
import 'package:inventory/module/home/model/dashboard_model.dart';
import 'package:inventory/module/home/model/grid_model.dart';
import 'package:inventory/responsive_layout/responsive_tempate.dart';
import 'package:inventory/routes/routes.dart';
import '../../../common_widget/colors.dart';
import '../../../helper/set_format_date.dart';
import '../../../helper/textstyle.dart';
import '../../../routes/route_name.dart';

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
      body: const SizedBox.shrink(),
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
      isleadingButtonRequired: false,
      body: const SizedBox.shrink(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MOBILE SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class MobileScreen extends StatelessWidget {
  final HomeController controller;
  const MobileScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      appBarLabel: 'Home',
      isleadingButtonRequired: false,
      secondActionChild: Obx(
        () =>
            controller.shopTypeEnum.config.supportsLooseStock
                ? Row(
                  children: [
                    // Near expiry clock
                    InkWell(
                      onTap:
                          () => AppRoutes.navigateRoutes(
                            routeName: AppRouteName.nearExpireProduct,
                          ),
                      child: Obx(
                        () =>
                            controller.nearExpiryCount.value > 0
                                ? Badge.count(
                                  count: int.parse(
                                    controller.nearExpiryCount.value.toString(),
                                  ),
                                  isLabelVisible: true,
                                  backgroundColor: AppColors.redColor,
                                  child: const Icon(CupertinoIcons.time_solid),
                                )
                                : const Icon(CupertinoIcons.time_solid),
                      ),
                    ),
                    // Notification bell
                    Obx(() {
                      final count = controller.pendingTransfers.length;
                      return Stack(
                        children: [
                          IconButton(
                            icon: const Icon(CupertinoIcons.bell_fill),
                            onPressed:
                                () => AppRoutes.navigateRoutes(
                                  routeName: AppRouteName.notificationView,
                                ),
                          ),
                          if (count > 0)
                            Positioned(
                              right: 6,
                              top: 6,
                              child: Container(
                                padding: const EdgeInsets.all(4),
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
                )
                : const SizedBox.shrink(),
      ),
      body: Obx(
        () =>
            controller.isListLoading.value
                ? const Center(
                  child: CommonProgressBar(
                    color: AppColors.blackColor,
                    size: 50,
                  ),
                )
                : RefreshIndicator.adaptive(
                  onRefresh: () async => controller.loadDashboard(),
                  child: ListView(
                    padding:
                        SymmetricPadding(
                          horizontal: 14,
                          vertical: 12,
                        ).getPadding(),
                    children: [
                      // ── Greeting header ──────────────────────────────
                      _GreetingHeader(controller: controller),
                      setHeight(height: 20),

                      // ── Stats grid ───────────────────────────────────
                      _StatsGrid(
                        items: controller.lis,
                        onTap: (routeName) async {
                          final res = await AppRoutes.futureNavigationToRoute(
                            routeName: routeName,
                          );
                          if (res == true) controller.loadDashboard();
                        },
                      ),
                      setHeight(height: 20),

                      // ── Quick Actions ────────────────────────────────
                      _SectionHeader(title: 'Quick Actions'),
                      setHeight(height: 10),
                      _QuickActionsRow(controller: controller),
                      setHeight(height: 20),

                      // ── Recent Activities ────────────────────────────
                      _SectionHeader(
                        title: 'Recent Activities',
                        trailing:
                            controller.sellsList.isNotEmpty
                                ? Text(
                                  '${controller.sellsList.length} items',
                                  style: CustomTextStyle.customOpenSans(
                                    fontSize: 12,
                                    color: AppColors.greyColor,
                                  ),
                                )
                                : const SizedBox.shrink(),
                      ),
                      setHeight(height: 10),
                      Obx(
                        () =>
                            controller.sellsList.isEmpty
                                ? CommonNoDataFound(
                                  message: 'No recent activity found',
                                )
                                : _ActivitiesCard(controller: controller),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GREETING HEADER
// ─────────────────────────────────────────────────────────────────────────────
class _GreetingHeader extends StatelessWidget {
  final HomeController controller;
  const _GreetingHeader({required this.controller});

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.blackColor,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting,
                  style: CustomTextStyle.customOpenSans(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                setHeight(height: 3),
                Text(
                  'Dashboard',
                  style: CustomTextStyle.customPoppin(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                setHeight(height: 6),
                Text(
                  formatDateTime(
                    DateTime.now().toIso8601String(),
                    showDate: true,
                    showTime: false,
                  ),
                  style: CustomTextStyle.customOpenSans(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 52.w,
            height: 52.h,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14.r),
              child: Image.asset(
                'assets/hisabboxlogo.png',
                width: 52.w,
                height: 52.h,
                fit: BoxFit.contain,
                color: Colors.white,
                errorBuilder:
                    (_, __, ___) => Icon(
                      CupertinoIcons.cube_box_fill,
                      color: Colors.white,
                      size: 26.sp,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STATS GRID
// ─────────────────────────────────────────────────────────────────────────────
class _StatsGrid extends StatelessWidget {
  final List<CustomGridModel> items;
  final void Function(String routeName) onTap;

  const _StatsGrid({required this.items, required this.onTap});

  // Per-card accent colors
  static const List<Color> _colors = [
    Color(0xFF1565C0), // Total Products — blue
    Color(0xFFC62828), // Out of Stock — red
    Color(0xFF2E7D32), // Today Sales — green
    Color(0xFF6A1B9A), // Loose/GR — purple
  ];

  static const List<IconData> _icons = [
    CupertinoIcons.cube_fill,
    CupertinoIcons.cube_box,
    Icons.paid_rounded,
    CupertinoIcons.arrow_2_circlepath,
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.7,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final color = _colors[index % _colors.length];
        final icon = item.icon ?? _icons[index % _icons.length];
        return _StatCard(
          model: item,
          color: color,
          icon: icon,
          onTap: () {
            if (item.routeName != null) onTap(item.routeName!);
          },
        );
      },
    );
  }
}

class _StatCard extends StatefulWidget {
  final CustomGridModel model;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _StatCard({
    required this.model,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _countAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _countAnim = Tween<double>(
      begin: 0,
      end: widget.model.numbers,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(_StatCard old) {
    super.didUpdateWidget(old);
    if (old.model.numbers != widget.model.numbers) {
      _countAnim = Tween<double>(
        begin: old.model.numbers,
        end: widget.model.numbers,
      ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 32.w,
                  height: 32.h,
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 16.sp),
                ),
                Icon(
                  CupertinoIcons.chevron_right,
                  size: 12.sp,
                  color: AppColors.greyColor,
                ),
              ],
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _countAnim,
                    builder: (context, _) {
                      final v = _countAnim.value;
                      final display =
                          v >= 1000
                              ? v.toStringAsFixed(0)
                              : v.toStringAsFixed(
                                widget.model.numbers ==
                                        widget.model.numbers.truncateToDouble()
                                    ? 0
                                    : 1,
                              );
                      return Text(
                        display,
                        style: CustomTextStyle.customPoppin(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.blackColor,
                        ),
                      );
                    },
                  ),
                  setHeight(height: 2),
                  Text(
                    widget.model.label ?? '',
                    style: CustomTextStyle.customOpenSans(
                      fontSize: 11,
                      color: AppColors.greyColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION HEADER
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const _SectionHeader({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: CustomTextStyle.customPoppin(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// QUICK ACTIONS ROW
// ─────────────────────────────────────────────────────────────────────────────
class _QuickActionsRow extends StatelessWidget {
  final HomeController controller;
  const _QuickActionsRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            label: 'Add Product',
            icon: CupertinoIcons.plus_circle_fill,
            color: AppColors.blackColor,
            onTap:
                () => AppRoutes.navigateRoutes(
                  routeName: AppRouteName.inventroyList,
                ),
          ),
        ),
        setWidth(width: 10),
        Expanded(
          child: _QuickActionCard(
            label: 'Scan Product',
            icon: CupertinoIcons.barcode_viewfinder,
            color: const Color(0xFF1565C0),
            onTap:
                () => AppRoutes.futureNavigationToRoute(
                  routeName: AppRouteName.inventoryView,
                  data: {'flag': false},
                ),
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20.sp),
            setWidth(width: 8),
            Text(
              label,
              style: CustomTextStyle.customPoppin(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTIVITIES CARD
// ─────────────────────────────────────────────────────────────────────────────
class _ActivitiesCard extends StatelessWidget {
  final HomeController controller;
  const _ActivitiesCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: SizedBox(
          height: 320.h,
          child: NotificationListener<ScrollNotification>(
            onNotification: (scroll) {
              if (scroll.metrics.pixels >=
                  scroll.metrics.maxScrollExtent - 50) {
                controller.loadMoreActivities();
              }
              return false;
            },
            child: Obx(
              () => ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: controller.sellsList.length + 1,
                separatorBuilder:
                    (_, __) => Divider(
                      height: 1,
                      indent: 62,
                      color: Colors.grey.shade100,
                    ),
                itemBuilder: (context, index) {
                  if (index == controller.sellsList.length) {
                    return Obx(
                      () =>
                          controller.isLoadingMoreActivities.value
                              ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Center(
                                  child: CommonProgressBar(
                                    size: 22,
                                    color: AppColors.blackColor,
                                  ),
                                ),
                              )
                              : const SizedBox(height: 8),
                    );
                  }
                  final activity = controller.sellsList[index];
                  return _ActivityTile(activity: activity, index: index);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTIVITY TILE  (replaces old ActivityTile)
// ─────────────────────────────────────────────────────────────────────────────
class ActivityTile extends StatelessWidget {
  final RecentActivitiesData activity;
  const ActivityTile({super.key, required this.activity});

  @override
  Widget build(BuildContext context) =>
      _ActivityTile(activity: activity, index: 0);
}

class _ActivityTile extends StatefulWidget {
  final RecentActivitiesData activity;
  final int index;
  const _ActivityTile({required this.activity, required this.index});

  @override
  State<_ActivityTile> createState() => _ActivityTileState();
}

class _ActivityTileState extends State<_ActivityTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 350 + widget.index * 40),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0.08, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  IconData get _icon {
    switch (widget.activity.type) {
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
    switch (widget.activity.type) {
      case 'sale':
        return const Color(0xFF2E7D32);
      case 'grn':
        return const Color(0xFFE65100);
      case 'product':
        return const Color(0xFF1565C0);
      default:
        return AppColors.greyColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final activity = widget.activity;
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 38.w,
                height: 38.h,
                decoration: BoxDecoration(
                  color: _color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(_icon, color: _color, size: 18.sp),
              ),
              setWidth(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.description ?? activity.referenceNo ?? '',
                      style: CustomTextStyle.customOpenSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    setHeight(height: 3),
                    Row(
                      children: [
                        if ((activity.referenceNo ?? '').isNotEmpty)
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _color.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                activity.referenceNo!,
                                style: CustomTextStyle.customOpenSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: _color,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        const Spacer(),
                        Icon(
                          CupertinoIcons.calendar,
                          size: 10.sp,
                          color: AppColors.greyColor,
                        ),
                        setWidth(width: 3),
                        Flexible(
                          child: Text(
                            formatDateTime(
                              activity.createdAt ?? '',
                              showDate: true,
                              showTime: false,
                            ),
                            style: CustomTextStyle.customOpenSans(
                              fontSize: 10,
                              color: AppColors.greyColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
