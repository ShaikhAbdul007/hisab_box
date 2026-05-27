
You are working on an existing Flutter Inventory Management App.

The current app structure, flows, and UI must NOT be changed. (Home, Product List, Add Product, Sell, Reports, Settings are already implemented and working.)

Your task is to refactor and extend the app to support multiple shop types with dynamic behavior, WITHOUT breaking existing functionality.

---

## CONTEXT (FROM EXISTING APP)

* Dashboard shows product count, out-of-stock, loose stock, sales, etc.
* Product flow: Scan → Add Product → Product Details
* Loose inventory exists
* Settings include category, animal category, printer, etc.

---

## PROBLEM

Currently, logic is hardcoded like:

* `if (shopType == "Pet Shop")`
* `if (shopType == "Clothing Shop")`

This logic is duplicated across:

* Product Add/Edit screens
* Inventory screens
* Settings
* Category management

This must be removed and replaced with a scalable architecture.

---

## GOAL

Create a **configuration-driven architecture** where each shop type defines:

* Product fields
* Category type
* Stock behavior (Loose / GR)
* Settings visibility
* Module enable/disable

---

## SHOP TYPES

### 1. Pet Shop

* Category Type → Animal Category
* Supports Loose Stock → YES
* Supports GR Stock → NO

#### Product Fields:

* product name
* animal category
* weight
* flavour
* selling price
* stock

#### Modules:

* Loose Inventory → ENABLED
* GR Inventory → DISABLED

#### Settings:

* Animal Category → ENABLED
* Color Category → DISABLED

---

### 2. Clothing Shop

* Category Type → Size / Color
* Supports Loose Stock → NO
* Supports GR Stock → YES

#### Product Fields:

* product name
* size
* color
* selling price
* stock

#### Modules:

* Loose Inventory → DISABLED
* GR Inventory → ENABLED

#### Settings:

* Color Category → ENABLED
* Animal Category → DISABLED

---

## IMPLEMENTATION

### 1. Create Enum

```dart
enum ShopType { pet, clothing }
```

---

### 2. Create ShopConfig Model

```dart
class ShopConfig {
  final bool supportsLooseStock;
  final bool supportsGRStock;
  final List<String> productFields;
  final List<String> settingsOptions;
  final String categoryType;
}
```

---

### 3. Create Central Config Map

```dart
final Map<ShopType, ShopConfig> shopConfigs = {
  ShopType.pet: ShopConfig(
    supportsLooseStock: true,
    supportsGRStock: false,
    productFields: ["animal", "weight", "flavour"],
    settingsOptions: ["animal_category"],
    categoryType: "animal",
  ),
  ShopType.clothing: ShopConfig(
    supportsLooseStock: false,
    supportsGRStock: true,
    productFields: ["size", "color"],
    settingsOptions: ["color_category"],
    categoryType: "size",
  ),
};
```

---

### 4. Dynamic UI Rendering

#### Product Add/Edit Screen

* Render fields dynamically using `productFields`

#### Inventory Screen

* Show loose inventory only if `supportsLooseStock == true`

#### Settings Screen

* Show options based on `settingsOptions`

#### Category Screen

* Show category type based on `categoryType`

---

### 5. Replace ALL Hardcoded Conditions

Remove all:

```dart
if (shopType == "Pet Shop")
```

Use:

```dart
final config = shopConfigs[currentShopType];
```

---

### 6. DO NOT BREAK:

* Existing navigation
* Existing API calls
* Existing models (only extend if needed)
* Barcode scanning flow
* Sell product flow

---

## EXPECTED OUTPUT

* Clean architecture
* No duplicated logic
* One source of truth (ShopConfig)
* Dynamic UI based on shop type
* Easily extendable for new shop types

---

## BONUS

* Rename `loosedProduct` → `isLooseProduct`
* Use reusable widgets for form fields
* Keep code GetX compatible

---

IMPORTANT:
This is a refactor, NOT a redesign. Preserve UI, only improve logic and scalability.
