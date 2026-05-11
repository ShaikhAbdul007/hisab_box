import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/module/invoice_barcode_designer/model/invoice_config_model.dart';

class TemplatePickerWidget extends StatelessWidget {
  final List<InvoiceTemplate> templates;
  final String selectedId;
  final Function(String templateId) onSelected;

  const TemplatePickerWidget({
    super.key,
    required this.templates,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 2.w),
        itemCount: templates.length,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (context, index) {
          final template = templates[index];
          final isSelected = template.id == selectedId;
          return GestureDetector(
            onTap: () => onSelected(template.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 90.w,
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? AppColors.deepPurple.withValues(alpha: 0.08)
                        : AppColors.whiteColor,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color:
                      isSelected ? AppColors.deepPurple : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Template preview icon
                  _TemplatePreviewIcon(
                    templateId: template.id,
                    isSelected: isSelected,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    template.name,
                    style: CustomTextStyle.customRaleway(
                      fontSize: 11,
                      color:
                          isSelected
                              ? AppColors.deepPurple
                              : AppColors.blackColor,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (isSelected) ...[
                    SizedBox(height: 3.h),
                    Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.deepPurple,
                      size: 14.sp,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Simple visual preview icon per template
class _TemplatePreviewIcon extends StatelessWidget {
  final String templateId;
  final bool isSelected;

  const _TemplatePreviewIcon({
    required this.templateId,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.deepPurple : Colors.grey.shade400;
    return SizedBox(
      width: 50.w,
      height: 40.h,
      child: CustomPaint(
        painter: _TemplatePreviewPainter(templateId: templateId, color: color),
      ),
    );
  }
}

class _TemplatePreviewPainter extends CustomPainter {
  final String templateId;
  final Color color;

  _TemplatePreviewPainter({required this.templateId, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    final linePaint =
        Paint()
          ..color = color.withValues(alpha: 0.5)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;

    switch (templateId) {
      case 'template_1': // Classic — header + lines
        canvas.drawRect(Rect.fromLTWH(0, 0, size.width, 8), paint);
        for (int i = 0; i < 3; i++) {
          canvas.drawLine(
            Offset(0, 14.0 + i * 7),
            Offset(size.width, 14.0 + i * 7),
            linePaint,
          );
        }
        break;
      case 'template_2': // Modern — bold header + compact rows
        canvas.drawRect(Rect.fromLTWH(0, 0, size.width, 12), paint);
        for (int i = 0; i < 4; i++) {
          canvas.drawRect(
            Rect.fromLTWH(0, 16.0 + i * 6, size.width * 0.7, 3),
            paint..color = color.withValues(alpha: 0.4),
          );
        }
        break;
      case 'template_3': // Minimal — text only
        for (int i = 0; i < 5; i++) {
          canvas.drawLine(
            Offset(0, 4.0 + i * 8),
            Offset(size.width * (i.isEven ? 1.0 : 0.6), 4.0 + i * 8),
            linePaint,
          );
        }
        break;
      case 'template_4': // Detailed — full info
        canvas.drawRect(Rect.fromLTWH(0, 0, size.width, 6), paint);
        canvas.drawRect(
          Rect.fromLTWH(0, size.height - 6, size.width, 6),
          paint,
        );
        for (int i = 0; i < 3; i++) {
          canvas.drawLine(
            Offset(0, 10.0 + i * 7),
            Offset(size.width, 10.0 + i * 7),
            linePaint,
          );
        }
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _TemplatePreviewPainter oldDelegate) =>
      oldDelegate.templateId != templateId || oldDelegate.color != color;
}
