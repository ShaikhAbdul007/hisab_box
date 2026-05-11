import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/module/invoice_barcode_designer/model/barcode_layout_model.dart';

class ElementPropertiesPanel extends StatelessWidget {
  final BarcodeElement? selectedElement;
  final Function(double fontSize) onFontSizeChanged;
  final Function(bool visible) onVisibilityChanged;

  const ElementPropertiesPanel({
    super.key,
    required this.selectedElement,
    required this.onFontSizeChanged,
    required this.onVisibilityChanged,
  });

  static const _fontSizes = [
    (label: 'S', value: 7.0),
    (label: 'M', value: 9.0),
    (label: 'L', value: 12.0),
    (label: 'XL', value: 14.0),
  ];

  @override
  Widget build(BuildContext context) {
    if (selectedElement == null) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(
              Icons.touch_app_outlined,
              color: Colors.grey.shade400,
              size: 18.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              'Tap an element on the canvas to edit it',
              style: CustomTextStyle.customRaleway(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    final element = selectedElement!;
    final isTextElement = element.type != ElementType.barcode;
    final currentFontSize = element.fontSize ?? 9.0;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.deepPurple.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AppColors.deepPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  element.type.label,
                  style: CustomTextStyle.customRaleway(
                    fontSize: 12,
                    color: AppColors.deepPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              // Visibility toggle
              Row(
                children: [
                  Text(
                    'Visible',
                    style: CustomTextStyle.customRaleway(
                      fontSize: 12,
                      color: AppColors.blackColor,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Switch.adaptive(
                    value: element.visible,
                    onChanged: onVisibilityChanged,
                    activeColor: AppColors.deepPurple,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
            ],
          ),

          // Font size selector (text elements only)
          if (isTextElement) ...[
            SizedBox(height: 10.h),
            Text(
              'Font Size',
              style: CustomTextStyle.customRaleway(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 6.h),
            Row(
              children:
                  _fontSizes.map((fs) {
                    final isSelected = (currentFontSize - fs.value).abs() < 0.5;
                    return Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: GestureDetector(
                        onTap: () => onFontSizeChanged(fs.value),
                        child: Container(
                          width: 36.w,
                          height: 32.h,
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? AppColors.deepPurple
                                    : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(
                              color:
                                  isSelected
                                      ? AppColors.deepPurple
                                      : Colors.grey.shade300,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              fs.label,
                              style: CustomTextStyle.customRaleway(
                                fontSize: 12,
                                color:
                                    isSelected
                                        ? AppColors.whiteColor
                                        : AppColors.blackColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
