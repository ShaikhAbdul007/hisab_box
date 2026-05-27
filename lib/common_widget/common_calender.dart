import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/helper/textstyle.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Public API — same signature as before, drop-in replacement
// ─────────────────────────────────────────────────────────────────────────────
Future<String> customDatePicker({
  required BuildContext context,
  required DateTime selectedDate,
  required RxString controller,
  DateTime? firstDate,
  String dateFormat = 'dd-MM-yyyy',
  void Function()? onDatePicked,
  final String? puchinout,
  DateTime? lastDate,
}) async {
  // Resolve initial date
  DateTime initial;
  try {
    if (controller.value.isNotEmpty) {
      final parsed = DateFormat(dateFormat).parse(controller.value);
      final limit = firstDate ?? DateTime(1990);
      initial = parsed.isBefore(limit) ? selectedDate : parsed;
    } else {
      initial = selectedDate;
    }
  } catch (_) {
    initial = selectedDate;
  }

  final DateTime effectiveLast = lastDate ?? DateTime(2100);
  if (initial.isAfter(effectiveLast)) initial = effectiveLast;
  final DateTime effectiveFirst = firstDate ?? DateTime(1990);

  final DateTime? picked = await showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder:
        (_) => _CalendarSheet(
          initialDate: initial,
          firstDate: effectiveFirst,
          lastDate: effectiveLast,
        ),
  );

  if (picked != null) {
    final formatted = DateFormat(dateFormat).format(picked);
    controller.value = formatted;
    onDatePicked?.call();
    return formatted;
  }
  return '';
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom-sheet calendar widget
// ─────────────────────────────────────────────────────────────────────────────
class _CalendarSheet extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const _CalendarSheet({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<_CalendarSheet> createState() => _CalendarSheetState();
}

class _CalendarSheetState extends State<_CalendarSheet> {
  late DateTime _viewing; // month currently shown
  late DateTime _selected; // highlighted date

  static const List<String> _weekDays = [
    'Mo',
    'Tu',
    'We',
    'Th',
    'Fr',
    'Sa',
    'Su',
  ];

  @override
  void initState() {
    super.initState();
    _selected = widget.initialDate;
    _viewing = DateTime(widget.initialDate.year, widget.initialDate.month);
  }

  // ── Navigation ─────────────────────────────────────────────────────────────
  void _prevMonth() {
    final prev = DateTime(_viewing.year, _viewing.month - 1);
    if (!prev.isBefore(
      DateTime(widget.firstDate.year, widget.firstDate.month),
    )) {
      setState(() => _viewing = prev);
    }
  }

  void _nextMonth() {
    final next = DateTime(_viewing.year, _viewing.month + 1);
    if (!next.isAfter(DateTime(widget.lastDate.year, widget.lastDate.month))) {
      setState(() => _viewing = next);
    }
  }

  bool _canGoPrev() {
    final prev = DateTime(_viewing.year, _viewing.month - 1);
    return !prev.isBefore(
      DateTime(widget.firstDate.year, widget.firstDate.month),
    );
  }

  bool _canGoNext() {
    final next = DateTime(_viewing.year, _viewing.month + 1);
    return !next.isAfter(DateTime(widget.lastDate.year, widget.lastDate.month));
  }

  // ── Build calendar days ────────────────────────────────────────────────────
  List<DateTime?> _buildDays() {
    final firstOfMonth = DateTime(_viewing.year, _viewing.month, 1);
    // Monday = 1 … Sunday = 7  →  offset so Mon is col 0
    final startOffset = (firstOfMonth.weekday - 1) % 7;
    final daysInMonth = DateTime(_viewing.year, _viewing.month + 1, 0).day;

    final cells = <DateTime?>[];
    for (int i = 0; i < startOffset; i++) {
      cells.add(null);
    }

    for (int d = 1; d <= daysInMonth; d++) {
      cells.add(DateTime(_viewing.year, _viewing.month, d));
    }
    // Pad to full rows
    while (cells.length % 7 != 0) {
      cells.add(null);
    }
    return cells;
  }

  bool _isDisabled(DateTime d) =>
      d.isBefore(widget.firstDate) || d.isAfter(widget.lastDate);

  bool _isSelected(DateTime d) =>
      d.year == _selected.year &&
      d.month == _selected.month &&
      d.day == _selected.day;

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final days = _buildDays();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 28.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ──────────────────────────────────────────────
          Center(
            child: Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 18.h),

          // ── Month / Year header ──────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Prev arrow
              _NavButton(
                icon: CupertinoIcons.chevron_left,
                enabled: _canGoPrev(),
                onTap: _prevMonth,
              ),

              // Month + Year label
              GestureDetector(
                onTap: _showYearPicker,
                child: Row(
                  children: [
                    Text(
                      DateFormat('MMMM yyyy').format(_viewing),
                      style: CustomTextStyle.customPoppin(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.blackColor,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      CupertinoIcons.chevron_down,
                      size: 14.sp,
                      color: AppColors.greyColor,
                    ),
                  ],
                ),
              ),

              // Next arrow
              _NavButton(
                icon: CupertinoIcons.chevron_right,
                enabled: _canGoNext(),
                onTap: _nextMonth,
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // ── Weekday labels ───────────────────────────────────────────
          Row(
            children:
                _weekDays.map((d) {
                  return Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: CustomTextStyle.customNato(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),

          SizedBox(height: 8.h),

          // ── Calendar grid ────────────────────────────────────────────
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: days.length,
            itemBuilder: (_, i) {
              final day = days[i];
              if (day == null) return const SizedBox.shrink();

              final disabled = _isDisabled(day);
              final selected = _isSelected(day);
              final today = _isToday(day);

              return GestureDetector(
                onTap: disabled ? null : () => setState(() => _selected = day),
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 36.w,
                    height: 36.h,
                    decoration: BoxDecoration(
                      color:
                          selected
                              ? AppColors.blackColor
                              : today
                              ? Colors.grey.shade100
                              : Colors.transparent,
                      shape: BoxShape.circle,
                      border:
                          today && !selected
                              ? Border.all(
                                color: Colors.grey.shade400,
                                width: 1,
                              )
                              : null,
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: CustomTextStyle.customPoppin(
                          fontSize: 13,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w400,
                          color:
                              selected
                                  ? Colors.white
                                  : disabled
                                  ? Colors.grey.shade300
                                  : AppColors.blackColor,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          SizedBox(height: 16.h),
          Divider(height: 1, color: Colors.grey.shade100),
          SizedBox(height: 14.h),

          // ── Action buttons ───────────────────────────────────────────
          Row(
            children: [
              // Cancel
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 46.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: Text(
                        'Cancel',
                        style: CustomTextStyle.customPoppin(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.greyColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              // Confirm
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context, _selected),
                  child: Container(
                    height: 46.h,
                    decoration: BoxDecoration(
                      color: AppColors.blackColor,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: Text(
                        'Confirm  ${DateFormat('dd MMM yyyy').format(_selected)}',
                        style: CustomTextStyle.customPoppin(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Year picker dialog ─────────────────────────────────────────────────────
  void _showYearPicker() {
    final years = List.generate(
      widget.lastDate.year - widget.firstDate.year + 1,
      (i) => widget.firstDate.year + i,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (_) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 28.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 36.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Select Year',
                  style: CustomTextStyle.customPoppin(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  height: 220.h,
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 1.8,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount: years.length,
                    itemBuilder: (_, i) {
                      final y = years[i];
                      final isCurrent = y == _viewing.year;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _viewing = DateTime(y, _viewing.month);
                          });
                          Navigator.pop(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                isCurrent
                                    ? AppColors.blackColor
                                    : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Center(
                            child: Text(
                              '$y',
                              style: CustomTextStyle.customPoppin(
                                fontSize: 13,
                                fontWeight:
                                    isCurrent
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                color:
                                    isCurrent
                                        ? Colors.white
                                        : AppColors.blackColor,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Nav arrow button
// ─────────────────────────────────────────────────────────────────────────────
class _NavButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 36.w,
        height: 36.h,
        decoration: BoxDecoration(
          color: enabled ? Colors.grey.shade100 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(
          icon,
          size: 16.sp,
          color: enabled ? AppColors.blackColor : Colors.grey.shade300,
        ),
      ),
    );
  }
}
