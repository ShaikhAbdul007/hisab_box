# Requirements Document

## Introduction

This document defines the requirements for the **Invoice + Barcode Label Designer** feature in the HisabBox Flutter app. The feature gives shop owners a visual designer to customize their barcode labels and invoice printouts. It consists of two sub-features:

1. **Barcode Label Designer** — a drag-and-drop canvas (58mm/80mm thermal paper) where the user positions elements (barcode image, product name, price, weight) and sets per-element font sizes. The layout is saved as JSON.
2. **Invoice Designer** — 3–4 pre-made templates with per-template customization (font size, field visibility, footer text). Header color is fixed black. The configuration is saved as JSON.

Both designers persist data locally via GetStorage (offline-first) and sync to Supabase for cross-device consistency. The feature is accessed from Settings → "Print Designer" tile. Existing barcode and invoice print flows are not broken; a default fallback is used when no custom layout/config is saved.

---

## Glossary

- **App**: The HisabBox Flutter application.
- **Designer**: The Invoice + Barcode Label Designer feature as a whole.
- **BarcodeLabelDesigner**: The sub-feature for designing barcode label layouts on a thermal canvas.
- **InvoiceDesigner**: The sub-feature for selecting and customizing invoice print templates.
- **PrintDesignerHub**: The hub screen that provides entry points to BarcodeLabelDesigner and InvoiceDesigner.
- **BarcodeLabelDesignerController**: The GetX controller managing barcode canvas state.
- **InvoiceDesignerController**: The GetX controller managing invoice template and customization state.
- **DesignerRepo**: The repository class responsible for reading and writing designer configs to GetStorage and Supabase.
- **BarcodeLayoutModel**: The data model representing a barcode label canvas layout (canvas size, element positions, font sizes).
- **BarcodeElement**: A single positionable element on the barcode canvas (barcode image, product name, price, or weight).
- **InvoiceConfigModel**: The data model representing an invoice design configuration (template ID, font size, field visibility, header color, footer text).
- **InvoiceTemplate**: A pre-made invoice template definition (id, name, preview asset).
- **DraggableCanvas**: The Flutter widget rendering the thermal paper canvas with draggable elements.
- **ElementPropertiesPanel**: The Flutter widget for editing a selected element's font size and visibility.
- **TemplatePickerWidget**: The Flutter widget displaying available invoice template thumbnails.
- **CustomizationPanel**: The Flutter widget for per-template invoice customization controls.
- **InvoicePreviewWidget**: The Flutter widget rendering a live preview of the current invoice config.
- **GetStorage**: The local key-value storage library used for offline-first persistence.
- **Supabase**: The remote backend used for cross-device config sync.
- **CacheManager**: The existing GetStorage mixin used across the app for local persistence.
- **BardcodeController**: The existing controller for ESC/POS barcode label printing (must not be broken).
- **InvoicePrinterView**: The existing widget for thermal invoice printing (must not be broken).
- **CanvasSize**: An enum with two values — `mm58` (58mm wide) and `mm80` (80mm wide).
- **FontSizeOption**: An enum with three values — `small`, `medium`, `large`.
- **ElementType**: An enum with four values — `barcode`, `productName`, `price`, `weight`.
- **designer_configs**: The Supabase table storing serialized designer configs per user.

---

## Requirements

### Requirement 1: Entry Point — Settings Screen Integration

**User Story:** As a shop owner, I want to access the Print Designer from the Settings screen, so that I can reach the designer without disrupting my normal workflow.

#### Acceptance Criteria

1. THE App SHALL display a "Print Designer" tile in the Settings screen under a "Print" section.
2. WHEN the user taps the "Print Designer" tile, THE App SHALL navigate to PrintDesignerHubView.
3. THE PrintDesignerHubView SHALL display two clearly labelled options: one for BarcodeLabelDesigner and one for InvoiceDesigner.
4. WHEN the user selects the Barcode Label Designer option from PrintDesignerHubView, THE App SHALL navigate to BarcodeLabelDesignerView.
5. WHEN the user selects the Invoice Designer option from PrintDesignerHubView, THE App SHALL navigate to InvoiceDesignerView.

---

### Requirement 2: Barcode Label Designer — Canvas and Element Interaction

**User Story:** As a shop owner, I want to drag and position barcode label elements on a thermal paper canvas, so that I can create a custom label layout that fits my printer paper.

#### Acceptance Criteria

1. WHEN BarcodeLabelDesignerView loads, THE BarcodeLabelDesignerController SHALL load the saved BarcodeLayoutModel from GetStorage, or fall back to `BarcodeLayoutModel.defaultLayout()` if no saved layout exists.
2. THE DraggableCanvas SHALL render all BarcodeElement items at their stored `x` and `y` positions within the canvas area.
3. WHEN a user drags a BarcodeElement on the DraggableCanvas, THE BarcodeLabelDesignerController SHALL update that element's `x` and `y` values and clamp them so the element remains within the canvas bounds.
4. WHEN a user changes the font size of a BarcodeElement via ElementPropertiesPanel, THE BarcodeLabelDesignerController SHALL update only that element's `fontSize`, leaving all other elements unchanged.
5. THE BarcodeLabelDesignerController SHALL support two canvas sizes: `CanvasSize.mm58` (58mm wide) and `CanvasSize.mm80` (80mm wide).
6. WHEN the user selects a canvas size, THE BarcodeLabelDesignerController SHALL update `barcodeLayout.canvasSize` and recalculate the canvas display dimensions.
7. WHEN the user taps "Reset to Default", THE BarcodeLabelDesignerController SHALL replace `barcodeLayout` with `BarcodeLayoutModel.defaultLayout()`.

---

### Requirement 3: Barcode Label Designer — Save and Load

**User Story:** As a shop owner, I want my barcode label layout to be saved and reloaded automatically, so that I do not have to redesign it every time I open the app.

#### Acceptance Criteria

1. WHEN the user taps "Save Layout", THE BarcodeLabelDesignerController SHALL persist the current BarcodeLayoutModel to GetStorage via DesignerRepo.
2. WHEN the user taps "Save Layout" and the save succeeds, THE App SHALL display a success message to the user.
3. IF GetStorage write fails during saveLayout(), THEN THE App SHALL display an error message and not report success.
4. WHEN saveLayout() completes a successful local save, THE DesignerRepo SHALL attempt to sync the layout to Supabase without blocking the UI.
5. IF Supabase sync fails during saveLayout(), THEN THE App SHALL retain the locally saved layout and not display an error to the user for the sync failure.
6. WHEN saveLayout() is called with the same BarcodeLayoutModel more than once, THE stored state in GetStorage SHALL be identical after each call.

---

### Requirement 4: Invoice Designer — Template Selection and Customization

**User Story:** As a shop owner, I want to choose from pre-made invoice templates and customize them, so that my printed invoices match my shop's branding.

#### Acceptance Criteria

1. WHEN InvoiceDesignerView loads, THE InvoiceDesignerController SHALL load the saved InvoiceConfigModel from GetStorage, or fall back to `InvoiceConfigModel` defaults if no saved config exists.
2. THE InvoiceDesignerView SHALL display between 3 and 4 pre-made InvoiceTemplate thumbnails for the user to select from.
3. WHEN the user selects an InvoiceTemplate, THE InvoiceDesignerController SHALL update `invoiceConfig.templateId` to the selected template's id and trigger a live preview rebuild, without mutating any other field of InvoiceConfigModel.
4. WHEN the user toggles a field visibility control (showLogo, showGST, showAddress, or showMobile), THE InvoiceDesignerController SHALL update only that field's value in InvoiceConfigModel, leaving all other fields unchanged.
5. WHEN the user selects a font size option (small, medium, or large), THE InvoiceDesignerController SHALL update `invoiceConfig.fontSize` to the selected FontSizeOption.
6. THE invoice header color SHALL always be fixed black (`#000000`) — no color picker is provided to the user.
7. WHEN the user enters footer text, THE InvoiceDesignerController SHALL update `invoiceConfig.footerText` to the entered string.
8. THE InvoicePreviewWidget SHALL re-render whenever InvoiceConfigModel changes, reflecting the current template, font size, field visibility, and footer text.

---

### Requirement 5: Invoice Designer — Save and Load

**User Story:** As a shop owner, I want my invoice design configuration to be saved and reloaded automatically, so that my customizations persist across app sessions.

#### Acceptance Criteria

1. WHEN the user taps "Save Design", THE InvoiceDesignerController SHALL persist the current InvoiceConfigModel to GetStorage via DesignerRepo.
2. WHEN the user taps "Save Design" and the save succeeds, THE App SHALL display a success message to the user.
3. IF GetStorage write fails during saveInvoiceConfig(), THEN THE App SHALL display an error message and not report success.
4. WHEN saveInvoiceConfig() completes a successful local save, THE DesignerRepo SHALL attempt to sync the config to Supabase without blocking the UI.
5. IF Supabase sync fails during saveInvoiceConfig(), THEN THE App SHALL retain the locally saved config and not display an error to the user for the sync failure.
6. WHEN saveInvoiceConfig() is called with the same InvoiceConfigModel more than once, THE stored state in GetStorage SHALL be identical after each call.

---

### Requirement 6: Data Models — Serialization

**User Story:** As a developer, I want BarcodeLayoutModel and InvoiceConfigModel to serialize and deserialize correctly, so that saved configs can be reliably stored and retrieved.

#### Acceptance Criteria

1. THE BarcodeLayoutModel SHALL implement `toJson()` and `fromJson()` such that for any valid BarcodeLayoutModel instance, `BarcodeLayoutModel.fromJson(model.toJson())` produces an equivalent instance.
2. THE InvoiceConfigModel SHALL implement `toJson()` and `fromJson()` such that for any valid InvoiceConfigModel instance, `InvoiceConfigModel.fromJson(config.toJson())` produces an equivalent instance.
3. THE BarcodeElement SHALL implement `toJson()` and `fromJson()` such that for any valid BarcodeElement instance, `BarcodeElement.fromJson(element.toJson())` produces an equivalent instance.
4. IF a stored JSON value is malformed or missing required fields, THEN THE DesignerRepo SHALL catch the parse error and return the appropriate default model without throwing.

---

### Requirement 7: Persistence Layer — DesignerRepo

**User Story:** As a developer, I want a single DesignerRepo to handle all designer config reads and writes, so that persistence logic is not duplicated across controllers.

#### Acceptance Criteria

1. THE DesignerRepo SHALL extend the existing CacheManager pattern and use GetStorage for all local reads and writes.
2. THE DesignerRepo.getBarcodeLayout() SHALL always return a valid BarcodeLayoutModel and SHALL never throw, regardless of the state of GetStorage.
3. THE DesignerRepo.getInvoiceConfig() SHALL always return a valid InvoiceConfigModel and SHALL never throw, regardless of the state of GetStorage.
4. WHEN local GetStorage contains no config and a valid user session exists, THE DesignerRepo SHALL attempt to fetch the config from the Supabase `designer_configs` table and cache the result in GetStorage.
5. IF the Supabase fetch fails during load, THEN THE DesignerRepo SHALL return the appropriate default model without throwing.
6. THE DesignerRepo SHALL use the `Key.barcodeLayout` and `Key.invoiceConfig` keys (added to the existing `Key` enum in `cache_manager.dart`) for GetStorage reads and writes.

---

### Requirement 8: Persistence Layer — Supabase Sync

**User Story:** As a shop owner, I want my designer configs to sync across devices, so that my label and invoice designs are available on any device I log in to.

#### Acceptance Criteria

1. THE Supabase `designer_configs` table SHALL store one row per user per config type, using an upsert strategy keyed on `(user_id, config_type)`.
2. THE `designer_configs` table SHALL enforce Row Level Security so that each user can only read and write their own rows.
3. WHEN syncing to Supabase, THE DesignerRepo SHALL use the authenticated user's id from the existing `retrieveUserDetail()` method.
4. IF no authenticated user id is available, THEN THE DesignerRepo SHALL skip the Supabase sync without throwing.
5. THE Supabase sync SHALL be performed asynchronously and SHALL NOT block the local save or the UI.

---

### Requirement 9: Non-Breaking Integration with Existing Print Flows

**User Story:** As a developer, I want the existing barcode and invoice print flows to remain unchanged, so that current users are not affected by the new designer feature.

#### Acceptance Criteria

1. WHEN BardcodeController.buildLabelBytes() is called and no custom BarcodeLayoutModel is saved, THE BardcodeController SHALL use `BarcodeLayoutModel.defaultLayout()` and produce output identical to the pre-feature behavior.
2. WHEN InvoicePrinterView.build() is called and no custom InvoiceConfigModel is saved, THE InvoicePrinterView SHALL use InvoiceConfigModel defaults and render identically to the pre-feature behavior.
3. THE BardcodeController SHALL read the BarcodeLayoutModel from DesignerRepo as an additive change only; no existing logic in BardcodeController SHALL be removed or altered.
4. THE InvoicePrinterView SHALL read the InvoiceConfigModel from DesignerRepo as an additive change only; no existing logic in InvoicePrinterView SHALL be removed or altered.

---

### Requirement 10: Module Structure and Navigation

**User Story:** As a developer, I want the new designer module to follow the existing folder structure and routing conventions, so that the codebase remains consistent and maintainable.

#### Acceptance Criteria

1. THE Designer module SHALL be placed at `lib/module/invoice_barcode_designer/` with sub-folders: `binding/`, `controller/`, `model/`, `repo/`, `view/`, and `widget/`.
2. THE App SHALL register three new named routes: `printDesignerHub`, `barcodeLabelDesigner`, and `invoiceDesigner` in `AppRouteName` and `AppRoutes`.
3. THE new routes SHALL follow the existing `GetPage` + `Binding` pattern used throughout `routes.dart`.
4. THE `navigateRoutes()` method in `AppRoutes` SHALL handle the three new route names.
5. THE `Key` enum in `cache_manager.dart` SHALL be extended with `barcodeLayout` and `invoiceConfig` entries; no existing keys SHALL be removed or renamed.
