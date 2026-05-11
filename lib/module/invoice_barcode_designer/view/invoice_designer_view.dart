import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_button.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/module/invoice_barcode_designer/controller/invoice_designer_controller.dart';
import 'package:inventory/module/invoice_barcode_designer/widget/customization_panel.dart';
import 'package:inventory/module/invoice_barcode_designer/widget/invoice_preview_widget.dart';
import 'package:inventory/module/invoice_barcode_designer/widget/template_picker_widget.dart';

class InvoiceDesignerView extends GetView<InvoiceDesignerController> {
  const InvoiceDesignerView({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      appBarLabel: 'Invoice Designer',
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Template Picker ──────────────────────────────────────────
              _SectionLabel(label: 'Choose Template'),
              setHeight(height: 10),
              Obx(
                () => TemplatePickerWidget(
                  templates: controller.availableTemplates,
                  selectedId: controller.invoiceConfig.value.templateId,
                  onSelected: controller.selectTemplate,
                ),
              ),

              setHeight(height: 20),

              // ── Live Preview ─────────────────────────────────────────────
              _SectionLabel(label: 'Preview'),
              setHeight(height: 8),
              Obx(
                () => InvoicePreviewWidget(
                  config: controller.invoiceConfig.value,
                  template: controller.selectedTemplate,
                  shopType: controller.currentShopType,
                ),
              ),

              setHeight(height: 20),

              // ── Customization Panel ──────────────────────────────────────
              _SectionLabel(label: 'Customize'),
              setHeight(height: 8),
              Obx(
                () => CustomizationPanel(
                  config: controller.invoiceConfig.value,
                  controller: controller,
                ),
              ),

              setHeight(height: 24),

              // ── Save Button ──────────────────────────────────────────────
              Obx(
                () => CommonButton(
                  label: 'Save Design',
                  isLoading: controller.isSaving.value,
                  onTap: controller.saveInvoiceConfig,
                  width: double.infinity,
                  height: 46,
                ),
              ),

              setHeight(height: 20),
            ],
          ),
        );
      }),
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
      style: CustomTextStyle.customNato(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.blackColor,
      ),
    );
  }
}
