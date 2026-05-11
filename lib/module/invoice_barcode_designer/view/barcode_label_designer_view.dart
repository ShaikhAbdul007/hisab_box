import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_button.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/module/invoice_barcode_designer/controller/barcode_label_designer_controller.dart';
import 'package:inventory/module/invoice_barcode_designer/model/barcode_layout_model.dart';
import 'package:inventory/module/invoice_barcode_designer/widget/draggable_canvas.dart';
import 'package:inventory/module/invoice_barcode_designer/widget/element_properties_panel.dart';

class BarcodeLabelDesignerView extends GetView<BarcodeLabelDesignerController> {
  const BarcodeLabelDesignerView({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      appBarLabel: 'Barcode Label Designer',
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Canvas Size Selector ─────────────────────────────────────
              _SectionLabel(label: 'Paper Size'),
              setHeight(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.straighten_rounded, size: 16.sp),
                    SizedBox(width: 8.w),
                    Text(
                      '58mm (Fixed)',
                      style: CustomTextStyle.customRaleway(
                        fontSize: 13,
                        color: AppColors.blackColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              setHeight(height: 12),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.currency_rupee_rounded, size: 16.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Fixed Price Label',
                        style: CustomTextStyle.customRaleway(
                          fontSize: 13,
                          color: AppColors.blackColor,
                        ),
                      ),
                    ),
                    Switch.adaptive(
                      value: controller.barcodeLayout.value.fixedPriceLabel,
                      onChanged: controller.setFixedPriceLabel,
                      activeColor: AppColors.blackColor,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
              ),
              setHeight(height: 12),
              _SectionLabel(label: 'Font Family'),
              setHeight(height: 8),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children:
                    DesignerFontFamily.values.map((family) {
                      final isSelected =
                          controller.barcodeLayout.value.textFontFamily ==
                          family;
                      return GestureDetector(
                        onTap: () => controller.setTextFontFamily(family),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 7.h,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? AppColors.blackColor
                                    : AppColors.whiteColor,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color:
                                  isSelected
                                      ? AppColors.blackColor
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
              ),

              setHeight(height: 20),

              // ── Canvas ───────────────────────────────────────────────────
              _SectionLabel(label: 'Label Canvas'),
              Text(
                'Drag elements to reposition them',
                style: CustomTextStyle.customRaleway(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
              setHeight(height: 10),
              Center(
                child: DraggableCanvas(
                  layout: controller.barcodeLayout.value,
                  selectedElementType: controller.selectedElementType.value,
                  onElementSelected: controller.selectElement,
                  onElementMoved: controller.updateElementPosition,
                ),
              ),

              setHeight(height: 20),

              // ── Element Properties ───────────────────────────────────────
              _SectionLabel(label: 'Element Properties'),
              setHeight(height: 8),
              ElementPropertiesPanel(
                selectedElement: controller.selectedElement,
                onFontSizeChanged: (size) {
                  final type = controller.selectedElementType.value;
                  if (type != null) {
                    controller.updateElementFontSize(type, size);
                  }
                },
                onVisibilityChanged: (visible) {
                  final type = controller.selectedElementType.value;
                  if (type != null) {
                    controller.updateElementVisibility(type, visible);
                  }
                },
              ),

              setHeight(height: 20),

              // ── Elements List (quick toggle) ─────────────────────────────
              _SectionLabel(label: 'Elements'),
              setHeight(height: 8),
              _ElementsQuickList(controller: controller),

              setHeight(height: 24),

              // ── Action Buttons ───────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.dialog(
                          AlertDialog(
                            title: const Text('Reset to Default?'),
                            content: const Text(
                              'This will reset the layout to the default position.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: Get.back,
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Get.back();
                                  controller.resetToDefault();
                                },
                                child: const Text(
                                  'Reset',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: Text(
                        'Reset to Default',
                        style: CustomTextStyle.customRaleway(
                          fontSize: 13,
                          color: AppColors.blackColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Obx(
                      () => CommonButton(
                        label: 'Save Layout',
                        isLoading: controller.isSaving.value,
                        onTap: controller.saveLayout,
                        height: 44,
                      ),
                    ),
                  ),
                ],
              ),

              setHeight(height: 20),
            ],
          ),
        );
      }),
    );
  }
}

// ── Elements Quick List ───────────────────────────────────────────────────────

class _ElementsQuickList extends StatelessWidget {
  final BarcodeLabelDesignerController controller;

  const _ElementsQuickList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children:
            controller.barcodeLayout.value.elements.asMap().entries.map((
              entry,
            ) {
              final index = entry.key;
              final element = entry.value;
              final isLast =
                  index == controller.barcodeLayout.value.elements.length - 1;
              return Column(
                children: [
                  ListTile(
                    dense: true,
                    leading: Icon(
                      _iconForType(element.type),
                      size: 18.sp,
                      color:
                          element.visible
                              ? AppColors.blackColor
                              : Colors.grey.shade400,
                    ),
                    title: Text(
                      element.type.label,
                      style: CustomTextStyle.customRaleway(
                        fontSize: 13,
                        color:
                            element.visible
                                ? AppColors.blackColor
                                : Colors.grey.shade400,
                      ),
                    ),
                    trailing: Switch.adaptive(
                      value: element.visible,
                      onChanged:
                          (v) => controller.updateElementVisibility(
                            element.type.name,
                            v,
                          ),
                      activeColor: AppColors.blackColor,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onTap: () => controller.selectElement(element.type.name),
                  ),
                  if (!isLast) Divider(height: 1, color: Colors.grey.shade100),
                ],
              );
            }).toList(),
      ),
    );
  }

  IconData _iconForType(ElementType type) {
    switch (type) {
      case ElementType.barcode:
        return Icons.qr_code_2_rounded;
      case ElementType.productName:
        return Icons.label_rounded;
      case ElementType.price:
        return Icons.currency_rupee_rounded;
      case ElementType.weight:
        return Icons.scale_rounded;
      case ElementType.shopName:
        return Icons.storefront_rounded;
      case ElementType.flavour:
        return Icons.restaurant_rounded;
      case ElementType.animalType:
        return Icons.pets_rounded;
      case ElementType.color:
        return Icons.palette_rounded;
      case ElementType.brand:
        return Icons.branding_watermark_rounded;
      case ElementType.category:
        return Icons.category_rounded;
      case ElementType.expiry:
        return Icons.event_rounded;
    }
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
      style: CustomTextStyle.customNato(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.blackColor,
      ),
    );
  }
}
