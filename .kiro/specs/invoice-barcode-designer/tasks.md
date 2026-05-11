# Implementation Plan: Invoice + Barcode Label Designer

## Overview

Implement the Invoice + Barcode Label Designer feature for HisabBox following the existing GetX MVC + Repository pattern. Tasks are ordered so each step builds on the previous: data models first, then persistence layer, then controllers, then UI, and finally wiring into existing flows. All existing print flows remain untouched until the final integration step.

## Tasks

- [x] 1. Extend CacheManager keys and add new route names
  - Add `barcodeLayout` and `invoiceConfig` entries to the `Key` enum in `lib/cache_manager/cache_manager.dart`
  - Add `printDesignerHub`, `barcodeLabelDesigner`, and `invoiceDesigner` constants to `AppRouteName` in `lib/routes/route_name.dart`
  - No existing keys or route names may be removed or renamed
  - _Requirements: 7.6, 10.2, 10.5_

- [ ] 2. Create data models with serialization
  - [x] 2.1 Create `BarcodeLayoutModel` and `BarcodeElement` in `lib/module/invoice_barcode_designer/model/`
    - Implement `CanvasSize` enum (`mm58`, `mm80`), `ElementType` enum (`barcode`, `productName`, `price`, `weight`), `FontSizeOption` enum (`small`, `medium`, `large`)
    - Implement `BarcodeElement` with fields: `type`, `x`, `y`, `width`, `height`, `fontSize`, `visible`; add `toJson()`, `fromJson()`, `copyWith()`
    - Implement `BarcodeLayoutModel` with fields: `canvasSize`, `canvasWidth`, `canvasHeight`, `elements`; add `toJson()`, `fromJson()`, `copyWith()`, and `BarcodeLayoutModel.defaultLayout()` factory
    - `defaultLayout()` must produce: `CanvasSize.mm58`, `canvasWidth: 58`, `canvasHeight: 30`, three elements (barcode at x:10/y:5, productName at x:10/y:50, price at x:80/y:50)
    - _Requirements: 6.1, 6.3, 2.1, 9.1_

  - [ ]* 2.2 Write property test for `BarcodeLayoutModel` serialization round-trip
    - **Property 1: BarcodeLayoutModel Serialization Round-Trip**
    - For any valid `BarcodeLayoutModel`, `BarcodeLayoutModel.fromJson(model.toJson())` must equal the original
    - **Validates: Requirements 6.1, 6.3**

  - [x] 2.3 Create `InvoiceConfigModel` and `InvoiceTemplate` in `lib/module/invoice_barcode_designer/model/`
    - Implement `InvoiceConfigModel` with fields: `templateId`, `fontSize`, `showLogo`, `showGST`, `showAddress`, `showMobile`, `footerText`, `headerColor`
    - Default values: `templateId: 'template_1'`, `fontSize: FontSizeOption.medium`, all show flags `true`, `footerText: 'Thank you for shopping!'`, `headerColor: '#000000'`
    - Add `toJson()`, `fromJson()`, `copyWith()`
    - Implement `InvoiceTemplate` with fields: `id`, `name`, `previewAsset`; define 3–4 static template instances
    - _Requirements: 6.2, 4.1, 4.2_

  - [ ]* 2.4 Write property test for `InvoiceConfigModel` serialization round-trip
    - **Property 2: InvoiceConfigModel Serialization Round-Trip**
    - For any valid `InvoiceConfigModel`, `InvoiceConfigModel.fromJson(config.toJson())` must equal the original
    - **Validates: Requirements 6.2, 6.3**

- [ ] 3. Checkpoint — Ensure all model tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 4. Implement `DesignerRepo`
  - [x] 4.1 Create `lib/module/invoice_barcode_designer/repo/designer_repo.dart`
    - Extend `CacheManager` mixin (same pattern as `BardcodeController` and `InvoicePrinterView`)
    - Implement `saveBarcodeLayout(BarcodeLayoutModel)`: serialize to JSON, write to `Key.barcodeLayout` via `box.write()`; on success fire-and-forget `syncToSupabase()`
    - Implement `getBarcodeLayout()`: read `Key.barcodeLayout` from `box.read()`; if null or parse error return `BarcodeLayoutModel.defaultLayout()`; if null and user session exists attempt Supabase fetch first
    - Implement `saveInvoiceConfig(InvoiceConfigModel)`: serialize to JSON, write to `Key.invoiceConfig`; on success fire-and-forget `syncToSupabase()`
    - Implement `getInvoiceConfig()`: read `Key.invoiceConfig`; if null or parse error return `InvoiceConfigModel()` defaults; if null and user session exists attempt Supabase fetch first
    - Implement `syncToSupabase(userId, configType, configData)`: upsert `designer_configs` table with `(user_id, config_type)` unique key; catch all errors and log via `AppLogger.info()` — never rethrow
    - Use `retrieveUserDetail().data?.id` for user id; skip sync if null
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 8.1, 8.3, 8.4, 8.5_

  - [ ]* 4.2 Write property test for `DesignerRepo` default fallback guarantee
    - **Property 7: Default Fallback Guarantee**
    - For any GetStorage state (empty, valid, corrupted), `getBarcodeLayout()` and `getInvoiceConfig()` must return a non-null valid model and never throw
    - **Validates: Requirements 7.2, 7.3, 7.5, 2.1, 3.1**

  - [ ]* 4.3 Write property test for offline-first save guarantee
    - **Property 8: Offline-First Save Guarantee**
    - For any network state, `saveBarcodeLayout()` and `saveInvoiceConfig()` must persist to GetStorage and return success regardless of Supabase result
    - **Validates: Requirements 3.4, 3.5, 5.4, 5.5**

  - [ ]* 4.4 Write property test for idempotent save
    - **Property 9: Idempotent Save**
    - Calling save twice with the same model must produce identical GetStorage state after both calls
    - **Validates: Requirements 3.6, 5.6**

- [ ] 5. Implement `BarcodeLabelDesignerController`
  - [x] 5.1 Create `lib/module/invoice_barcode_designer/controller/barcode_label_designer_controller.dart`
    - Extend `GetxController with CacheManager`
    - Declare `Rx<BarcodeLayoutModel> barcodeLayout`, `RxBool isSaving`, `RxBool isLoading`
    - Implement `onReady()`: call `loadLayout()`
    - Implement `loadLayout()`: call `DesignerRepo().getBarcodeLayout()`, assign to `barcodeLayout.value`
    - Implement `updateElementPosition(String elementType, double x, double y)`: find element by type, clamp x/y to canvas bounds using `MAX(0, MIN(newX, canvasWidth - elementWidth))`, rebuild `barcodeLayout.value` via `copyWith()` — only target element changes
    - Implement `updateElementFontSize(String elementType, double fontSize)`: update only matching element's `fontSize`, all others unchanged
    - Implement `setCanvasSize(CanvasSize size)`: update `barcodeLayout.value.canvasSize` and recalculate `canvasWidth`
    - Implement `saveLayout()`: set `isSaving = true`, call `DesignerRepo().saveBarcodeLayout()`, show success snackbar on success or error snackbar on failure, set `isSaving = false` in finally
    - Implement `resetToDefault()`: assign `BarcodeLayoutModel.defaultLayout()` to `barcodeLayout.value`
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 3.1, 3.2, 3.3_

  - [ ]* 5.2 Write property test for canvas bounds clamping invariant
    - **Property 3: Canvas Bounds Clamping Invariant**
    - For any drag delta applied to any element, resulting position must satisfy `e.x >= 0`, `e.x + effectiveWidth <= canvasWidth`, `e.y >= 0`, `e.y + effectiveHeight <= canvasHeight`
    - **Validates: Requirements 2.3**

  - [ ]* 5.3 Write property test for element font size isolation
    - **Property 4: Element Font Size Isolation**
    - Calling `updateElementFontSize(elementType, fontSize)` must update only the matching element; all other elements remain byte-for-byte identical
    - **Validates: Requirements 2.4**

  - [ ]* 5.4 Write property test for barcode layout save round-trip
    - **Property 5: Barcode Layout Save Round-Trip**
    - For any valid `BarcodeLayoutModel`, `saveLayout()` followed by `getBarcodeLayout()` must return an equivalent model
    - **Validates: Requirements 3.1, 7.2**

- [ ] 6. Implement `InvoiceDesignerController`
  - [x] 6.1 Create `lib/module/invoice_barcode_designer/controller/invoice_designer_controller.dart`
    - Extend `GetxController with CacheManager`
    - Declare `Rx<InvoiceConfigModel> invoiceConfig`, `RxBool isSaving`, `RxBool isLoading`, `RxList<InvoiceTemplate> availableTemplates`
    - Implement `onReady()`: populate `availableTemplates` with 3–4 static `InvoiceTemplate` instances, call `loadInvoiceConfig()`
    - Implement `loadInvoiceConfig()`: call `DesignerRepo().getInvoiceConfig()`, assign to `invoiceConfig.value`
    - Implement `selectTemplate(String templateId)`: update only `invoiceConfig.value.templateId` via `copyWith()` — no other field changes
    - Implement `setFontSize(FontSizeOption size)`: update only `invoiceConfig.value.fontSize`
    - Implement `toggleField(String fieldKey, bool value)`: switch on `fieldKey` (`showLogo`, `showGST`, `showAddress`, `showMobile`), update only that field via `copyWith()`
    - Header color is fixed `#000000` (black) — no `setHeaderColor()` method needed
    - Implement `setFooterText(String text)`: update `invoiceConfig.value.footerText`
    - Implement `saveInvoiceConfig()`: set `isSaving = true`, call `DesignerRepo().saveInvoiceConfig()`, show success/error snackbar, set `isSaving = false` in finally
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.8, 5.1, 5.2, 5.3_

  - [ ]* 6.2 Write property test for template selection isolation
    - **Property 10: Template Selection Isolation**
    - Calling `selectTemplate(templateId)` must update only `invoiceConfig.templateId`; all other fields remain unchanged
    - **Validates: Requirements 4.3**

  - [ ]* 6.3 Write property test for field visibility isolation
    - **Property 11: Field Visibility Isolation**
    - Calling `toggleField(fieldKey, value)` must update only the targeted field; all other fields remain unchanged
    - **Validates: Requirements 4.4**

  - [ ]* 6.4 Write property test for invoice config save round-trip
    - **Property 6: Invoice Config Save Round-Trip**
    - For any valid `InvoiceConfigModel`, `saveInvoiceConfig()` followed by `getInvoiceConfig()` must return an equivalent model
    - **Validates: Requirements 5.1, 7.2**

- [ ] 7. Checkpoint — Ensure all controller tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 8. Create bindings
  - [x] 8.1 Create `lib/module/invoice_barcode_designer/binding/barcode_label_designer_binding.dart`
    - Implement `BarcodeLabelDesignerBinding extends Bindings`; `dependencies()` must call `Get.lazyPut(() => BarcodeLabelDesignerController())`
    - _Requirements: 10.3_

  - [x] 8.2 Create `lib/module/invoice_barcode_designer/binding/invoice_designer_binding.dart`
    - Implement `InvoiceDesignerBinding extends Bindings`; `dependencies()` must call `Get.lazyPut(() => InvoiceDesignerController())`
    - _Requirements: 10.3_

  - [x] 8.3 Create `lib/module/invoice_barcode_designer/binding/print_designer_hub_binding.dart`
    - Implement `PrintDesignerHubBinding extends Bindings`; no controller needed for the hub — binding can be empty or omitted; follow existing pattern
    - _Requirements: 10.3_

- [ ] 9. Build UI widgets
  - [x] 9.1 Create `DraggableCanvas` in `lib/module/invoice_barcode_designer/widget/draggable_canvas.dart`
    - Accept `BarcodeLayoutModel layout`, `Function(String, double, double) onElementMoved`, `Function(String) onElementSelected`, `String? selectedElementType`
    - Render a `Container` sized to canvas dimensions (convert mm to px: `mm * 96 / 25.4`); wrap in `RepaintBoundary`
    - For each `BarcodeElement` where `visible == true`: render a `Positioned` + `GestureDetector(onPanUpdate:)` widget; call `onElementMoved` with clamped coordinates on each pan update
    - Highlight the selected element with a colored border
    - _Requirements: 2.2, 2.3_

  - [x] 9.2 Create `ElementPropertiesPanel` in `lib/module/invoice_barcode_designer/widget/element_properties_panel.dart`
    - Accept `BarcodeElement? selectedElement`, `Function(double) onFontSizeChanged`, `Function(bool) onVisibilityChanged`
    - Show font size selector (small/medium/large mapped to pt values) and a visibility toggle
    - Show empty state when `selectedElement` is null
    - _Requirements: 2.4_

  - [x] 9.3 Create `TemplatePickerWidget` in `lib/module/invoice_barcode_designer/widget/template_picker_widget.dart`
    - Accept `List<InvoiceTemplate> templates`, `String selectedId`, `Function(String) onSelected`
    - Render 3–4 template thumbnails in a horizontal scroll; highlight the selected template
    - _Requirements: 4.2, 4.3_

  - [x] 9.4 Create `CustomizationPanel` in `lib/module/invoice_barcode_designer/widget/customization_panel.dart`
    - Accept `InvoiceConfigModel config`, `InvoiceDesignerController controller`
    - Render font size selector (small/medium/large), four visibility toggles (`showLogo`, `showGST`, `showAddress`, `showMobile`), and a footer text field that calls `controller.setFooterText()`
    - Header color is fixed black (`#000000`) — no color picker UI needed
    - _Requirements: 4.4, 4.5, 4.8_

  - [x] 9.5 Create `InvoicePreviewWidget` in `lib/module/invoice_barcode_designer/widget/invoice_preview_widget.dart`
    - Accept `InvoiceConfigModel config`, `InvoiceTemplate template`
    - Render a scaled-down invoice preview reflecting `templateId`, `fontSize`, field visibility flags, `headerColor`, and `footerText`
    - Widget must be wrapped in `Obx` at the call site so it rebuilds on every `invoiceConfig` change
    - _Requirements: 4.9_

- [ ] 10. Build view screens
  - [x] 10.1 Create `PrintDesignerHubView` in `lib/module/invoice_barcode_designer/view/print_designer_hub_view.dart`
    - Use `CommonAppbar` with label `'Print Designer'`
    - Display two clearly labelled cards/tiles: "Barcode Label Designer" and "Invoice Designer"
    - Tapping Barcode tile calls `AppRoutes.navigateRoutes(routeName: AppRouteName.barcodeLabelDesigner)`
    - Tapping Invoice tile calls `AppRoutes.navigateRoutes(routeName: AppRouteName.invoiceDesigner)`
    - _Requirements: 1.3, 1.4, 1.5_

  - [x] 10.2 Create `BarcodeLabelDesignerView` in `lib/module/invoice_barcode_designer/view/barcode_label_designer_view.dart`
    - Use `GetView<BarcodeLabelDesignerController>`
    - Use `CommonAppbar` with label `'Barcode Label Designer'`
    - Render canvas size selector (58mm / 80mm) that calls `controller.setCanvasSize()`
    - Render `DraggableCanvas` wrapped in `Obx`, passing `controller.barcodeLayout.value` and callbacks to `controller.updateElementPosition()` and a local selected-element state
    - Render `ElementPropertiesPanel` for the currently selected element, calling `controller.updateElementFontSize()` and element visibility toggle
    - Render "Reset to Default" button calling `controller.resetToDefault()`
    - Render "Save Layout" button wrapped in `Obx` showing `CommonButton` with `isLoading: controller.isSaving.value`, calling `controller.saveLayout()`
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 3.1, 3.2_

  - [x] 10.3 Create `InvoiceDesignerView` in `lib/module/invoice_barcode_designer/view/invoice_designer_view.dart`
    - Use `GetView<InvoiceDesignerController>`
    - Use `CommonAppbar` with label `'Invoice Designer'`
    - Render `TemplatePickerWidget` wrapped in `Obx`
    - Render `CustomizationPanel` wrapped in `Obx`
    - Render `InvoicePreviewWidget` wrapped in `Obx`
    - Render "Save Design" button wrapped in `Obx` showing `CommonButton` with `isLoading: controller.isSaving.value`, calling `controller.saveInvoiceConfig()`
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7, 4.8, 4.9, 5.1, 5.2_

- [ ] 11. Register routes and wire Settings entry point
  - [x] 11.1 Register the three new `GetPage` entries in `lib/routes/routes.dart`
    - Add imports for the three new views and bindings
    - Add `GetPage(name: AppRouteName.printDesignerHub, page: () => PrintDesignerHubView(), binding: PrintDesignerHubBinding())`
    - Add `GetPage(name: AppRouteName.barcodeLabelDesigner, page: () => BarcodeLabelDesignerView(), binding: BarcodeLabelDesignerBinding())`
    - Add `GetPage(name: AppRouteName.invoiceDesigner, page: () => InvoiceDesignerView(), binding: InvoiceDesignerBinding())`
    - _Requirements: 10.2, 10.3_

  - [x] 11.2 Add the three new route cases to `AppRoutes.navigateRoutes()` in `lib/routes/routes.dart`
    - Add `case AppRouteName.printDesignerHub: Get.toNamed(...)`
    - Add `case AppRouteName.barcodeLabelDesigner: Get.toNamed(...)`
    - Add `case AppRouteName.invoiceDesigner: Get.toNamed(...)`
    - _Requirements: 10.4_

  - [x] 11.3 Add "Print Designer" tile to `SettingView` in `lib/module/setting/view/setting.dart`
    - Insert a new `_SectionLabel(label: 'Print')` section after the existing "App" section
    - Add a `_SettingsGroup` containing one `_SettingTile` with `icon: Icons.design_services_rounded`, `iconColor: const Color(0xFF00838F)`, `label: 'Print Designer'`, `subtitle: 'Customize barcode labels & invoices'`, `isLast: true`
    - `onTap` calls `AppRoutes.navigateRoutes(routeName: AppRouteName.printDesignerHub)`
    - _Requirements: 1.1, 1.2_

- [ ] 12. Checkpoint — Ensure all routes and navigation work
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 13. Integrate saved layout into existing print flows (additive only)
  - [x] 13.1 Add `DesignerRepo` read to `BardcodeController.buildLabelBytes()` in `lib/module/invoice/controller/bardcode_controller.dart`
    - At the top of `buildLabelBytes()`, add: `final layout = await DesignerRepo().getBarcodeLayout();`
    - Use `layout.elements` to drive element positioning and font sizes in the ESC/POS byte generation
    - When no layout is saved, `getBarcodeLayout()` returns `defaultLayout()` — output must be identical to pre-feature behavior
    - No existing logic in `buildLabelBytes()` may be removed; this is an additive change only
    - _Requirements: 9.1, 9.3_

  - [x] 13.2 Add `DesignerRepo` read to `InvoicePrinterView.build()` in `lib/module/invoice/widget/invoice_printer.dart`
    - Add `final invoiceConfig = DesignerRepo().getInvoiceConfigSync();` (or load via controller) at the start of `build()`
    - Use `invoiceConfig` to conditionally show/hide `showLogo`, `showGST`, `showAddress`, `showMobile` sections, apply `fontSize`, `headerColor`, and `footerText`
    - When no config is saved, `getInvoiceConfig()` returns defaults — render must be identical to pre-feature behavior
    - No existing logic in `InvoicePrinterView` may be removed; this is an additive change only
    - _Requirements: 9.2, 9.4_

- [x] 14. Final checkpoint — Full regression and integration validation
  - Ensure all tests pass, ask the user if questions arise.
  - Verify existing barcode print flow (`BardcodeController.buildLabelBytes()`) produces correct output with no saved layout
  - Verify existing invoice print flow (`InvoicePrinterView`) renders correctly with no saved config
  - Verify Settings screen shows "Print Designer" tile and navigates to hub
  - Verify hub navigates to both designers
  - Verify save → reload round-trip for both designers

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP delivery
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation at logical boundaries
- Property tests validate universal correctness properties (serialization, bounds, isolation, offline-first)
- Unit tests validate specific examples and edge cases
- The `flutter_colorpicker` package is NOT needed — header color is fixed black (`#000000`)
- All new code lives under `lib/module/invoice_barcode_designer/` — no other module folders are modified except the additive changes in tasks 1, 11, and 13
- `DesignerRepo` is instantiated directly (not via GetX injection) so it can be used from both the new controllers and the existing `BardcodeController` / `InvoicePrinterView` without binding changes
