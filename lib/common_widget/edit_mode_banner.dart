import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/textstyle.dart';

/// Drop-in banner that reacts to a [RxBool] readOnly observable.
/// - readOnly = true  → blue info banner  ("Tap edit to make changes")
/// - readOnly = false → orange edit banner ("You are in edit mode")
///
/// Logic / conditions are NOT touched — this is purely a UI widget.
class EditModeBanner extends StatelessWidget {
  final RxBool readOnly;

  /// Optional custom messages
  final String? readOnlyMessage;
  final String? editingMessage;

  const EditModeBanner({
    super.key,
    required this.readOnly,
    this.readOnlyMessage,
    this.editingMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isReadOnly = readOnly.value;
      final Color bg = isReadOnly ? Colors.blue.shade50 : Colors.orange.shade50;
      final Color border =
          isReadOnly ? Colors.blue.shade100 : Colors.orange.shade200;
      final Color iconColor =
          isReadOnly ? Colors.blue.shade600 : Colors.orange.shade700;
      final Color textColor =
          isReadOnly ? Colors.blue.shade700 : Colors.orange.shade800;
      final IconData icon =
          isReadOnly
              ? CupertinoIcons.info_circle_fill
              : CupertinoIcons.pencil_circle_fill;
      final String message =
          isReadOnly
              ? (readOnlyMessage ??
                  'Tap the edit icon (top right) to make changes.')
              : (editingMessage ??
                  'You are in edit mode. Make your changes and tap Save.');

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20.sp),
            setWidth(width: 10),
            Expanded(
              child: Text(
                message,
                style: CustomTextStyle.customOpenSans(
                  fontSize: 12,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
