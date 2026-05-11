import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/module/invoice_barcode_designer/controller/invoice_designer_controller.dart';
import 'package:inventory/module/invoice_barcode_designer/model/barcode_layout_model.dart';
import 'package:inventory/module/invoice_barcode_designer/model/invoice_config_model.dart';

class CustomizationPanel extends StatelessWidget {
  final InvoiceConfigModel config;
  final InvoiceDesignerController controller;

  const CustomizationPanel({
    super.key,
    required this.config,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Font Size ──────────────────────────────────────────────────────
          _SectionLabel(label: 'Font Size'),
          SizedBox(height: 8.h),
          _FontSizeSelector(
            current: config.fontSize,
            onChanged: controller.setFontSize,
          ),
          SizedBox(height: 12.h),
          _SectionLabel(label: 'Font Family'),
          SizedBox(height: 8.h),
          _FontFamilySelector(
            current: config.invoiceFontFamily,
            onChanged: controller.setInvoiceFontFamily,
          ),

          SizedBox(height: 16.h),

          // ── Field Visibility ───────────────────────────────────────────────
          _SectionLabel(label: 'Show / Hide Fields'),
          SizedBox(height: 4.h),
          _VisibilityToggle(
            label: 'Logo',
            icon: Icons.store_rounded,
            value: config.showLogo,
            onChanged: (v) => controller.toggleField('showLogo', v),
          ),
          _VisibilityToggle(
            label: 'Address',
            icon: Icons.location_on_rounded,
            value: config.showAddress,
            onChanged: (v) => controller.toggleField('showAddress', v),
          ),
          _VisibilityToggle(
            label: 'Mobile Number',
            icon: Icons.phone_rounded,
            value: config.showMobile,
            onChanged: (v) => controller.toggleField('showMobile', v),
          ),
          if (controller.isPetShop) ...[
            _VisibilityToggle(
              label: 'Flavour',
              icon: Icons.fastfood_rounded,
              value: config.showFlavour,
              onChanged: (v) => controller.toggleField('showFlavour', v),
            ),
            _VisibilityToggle(
              label: 'Weight',
              icon: Icons.scale_rounded,
              value: config.showWeight,
              onChanged: (v) => controller.toggleField('showWeight', v),
            ),
            _VisibilityToggle(
              label: 'Animal Type',
              icon: Icons.pets_rounded,
              value: config.showAnimalType,
              onChanged: (v) => controller.toggleField('showAnimalType', v),
            ),
            _VisibilityToggle(
              label: 'Brand',
              icon: Icons.sell_rounded,
              value: config.showBrand,
              onChanged: (v) => controller.toggleField('showBrand', v),
            ),
          ],
          if (controller.isClothingShop) ...[
            _VisibilityToggle(
              label: 'Color',
              icon: Icons.palette_rounded,
              value: config.showColor,
              onChanged: (v) => controller.toggleField('showColor', v),
            ),
            _VisibilityToggle(
              label: 'Brand',
              icon: Icons.sell_rounded,
              value: config.showBrand,
              onChanged: (v) => controller.toggleField('showBrand', v),
            ),
            _VisibilityToggle(
              label: 'Size',
              icon: Icons.straighten_rounded,
              value: config.showSize,
              onChanged: (v) => controller.toggleField('showSize', v),
            ),
          ],

          SizedBox(height: 16.h),

          // ── Footer Text ────────────────────────────────────────────────────
          _SectionLabel(label: 'Footer Message'),
          SizedBox(height: 8.h),
          TextFormField(
            initialValue: config.footerText,
            onChanged: controller.setFooterText,
            maxLength: 80,
            style: CustomTextStyle.customRaleway(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'e.g. Thank you for shopping!',
              hintStyle: CustomTextStyle.customRaleway(
                fontSize: 12,
                color: Colors.grey.shade400,
              ),
              counterText: '',
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 10.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: AppColors.deepPurple),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          _SectionLabel(label: 'Terms & Conditions'),
          SizedBox(height: 8.h),
          TextFormField(
            initialValue: config.termsAndConditionsText,
            onChanged: controller.setTermsAndConditionsText,
            maxLines: 4,
            minLines: 3,
            maxLength: 300,
            style: CustomTextStyle.customRaleway(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'e.g. 1. Goods once sold...\n2. No refund...\n3. ...',
              hintStyle: CustomTextStyle.customRaleway(
                fontSize: 12,
                color: Colors.grey.shade400,
              ),
              counterText: '',
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 10.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: AppColors.deepPurple),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FontFamilySelector extends StatelessWidget {
  final DesignerFontFamily current;
  final Function(DesignerFontFamily) onChanged;

  const _FontFamilySelector({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children:
          DesignerFontFamily.values.map((family) {
            final isSelected = family == current;
            return GestureDetector(
              onTap: () => onChanged(family),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.deepPurple : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color:
                        isSelected
                            ? AppColors.deepPurple
                            : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  family.label,
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
            );
          }).toList(),
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: CustomTextStyle.customRaleway(
        fontSize: 12,
        color: Colors.grey.shade600,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// ── Font Size Selector ────────────────────────────────────────────────────────

class _FontSizeSelector extends StatelessWidget {
  final FontSizeOption current;
  final Function(FontSizeOption) onChanged;

  const _FontSizeSelector({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children:
          FontSizeOption.values.map((option) {
            final isSelected = current == option;
            return Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: GestureDetector(
                onTap: () => onChanged(option),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 7.h,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? AppColors.deepPurple
                            : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color:
                          isSelected
                              ? AppColors.deepPurple
                              : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    option.name[0].toUpperCase() + option.name.substring(1),
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
            );
          }).toList(),
    );
  }
}

// ── Visibility Toggle Row ─────────────────────────────────────────────────────

class _VisibilityToggle extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool value;
  final Function(bool) onChanged;

  const _VisibilityToggle({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        children: [
          Icon(icon, size: 16.sp, color: Colors.grey.shade500),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              label,
              style: CustomTextStyle.customRaleway(
                fontSize: 13,
                color: AppColors.blackColor,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.deepPurple,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}
