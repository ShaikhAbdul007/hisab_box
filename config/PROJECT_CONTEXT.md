# HisabBox — Complete Project Context

> App Name: **HisabBox** | Package: `inventory` | Version: `1.0.0+1`
> Platform: Flutter (iOS + Android) | State Management: **GetX** | Backend: **REST API** (hisab-box.softwaresnip.com)

---

## 1. TECH STACK

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x (Dart SDK ^3.7.2) |
| State Management | GetX ^4.7.2 |
| Navigation | GetX Named Routes |
| HTTP Client | `http` ^1.2.0 (custom `Networking` singleton) |
| Local Storage | `get_storage` ^2.1.1 (primary cache) |
| Local DB (disabled) | Hive ^2.2.3 (fully commented out) |
| Auth | OTP-based via REST API (email OTP) |
| Push Notifications | Firebase Messaging + flutter_local_notifications |
| Bluetooth Printing | flutter_bluetooth_printer + flutter_blue_plus |
| Barcode Scanning | mobile_scanner ^7.0.1 |
| PDF / Share | pdf + share_plus |
| Charts | fl_chart ^1.0.0 |
| Excel Export | excel ^4.0.6 |
| Image Upload | image_picker ^1.2.1 |
| Responsive UI | flutter_screenutil ^5.9.3 |
| Env Config | flutter_dotenv ^5.1.0 |
| Supabase (disabled) | supabase_flutter ^2.12.0 (code commented out) |
| UPI QR | upi_payment_qrcode_generator |
| Audio | audioplayers ^6.5.1 (beep on scan) |

---

## 2. PROJECT STRUCTURE

```
lib/
├── main.dart                    # App entry point
├── firebase_options.dart        # Firebase config
├── bluetooth/
│   └── bluetooth.dart           # CommonBluetooth mixin (BLE check)
├── cache_manager/
│   ├── cache_manager.dart       # CacheManager mixin (GetStorage)
│   └── cache_model.dart
├── common_widget/               # Reusable UI components
│   ├── colors.dart              # AppColors
│   ├── textfiled.dart
│   ├── common_button.dart
│   ├── common_appbar.dart
│   ├── common_bottom_sheet.dart
│   ├── common_calender.dart
│   ├── common_dialogue.dart
│   ├── common_dropdown.dart
│   ├── common_nodatafound.dart
│   ├── common_progressbar.dart
│   ├── common_radio_button.dart
│   ├── common_switch.dart
│   ├── search.dart
│   └── size.dart
├── helper/
│   ├── app_message.dart         # Error/success message constants
│   ├── helper.dart              # showSnackBar, unfocus, showMessage utils
│   ├── logger.dart              # AppLogger (debug logging)
│   ├── set_format_date.dart     # Date formatting helpers
│   ├── textstyle.dart
│   ├── device_info.dart         # DeviceInfoo mixin
│   ├── label_printer_config.dart
│   └── capitalization_strings.dart
├── keys/
│   └── keys.dart                # GlobalKey<FormState> instances
├── local_db/
│   └── local_db_service.dart    # LocalService mixin (FULLY COMMENTED OUT - Hive)
├── network/
│   ├── api_endpoint.dart        # All API endpoint constants
│   ├── base_client.dart         # Abstract BaseClient
│   └── networking.dart          # Networking singleton (http calls + token)
├── responsive_layout/           # Responsive screen wrappers
├── routes/
│   ├── route_name.dart          # AppRouteName constants
│   └── routes.dart              # AppRoutes (GetPage list + navigation methods)
├── supabase_db/
│   ├── supabase_client.dart     # FULLY COMMENTED OUT
│   ├── storage_service.dart
│   └── supabase_error_handler.dart
└── module/                      # Feature modules (see Section 4)
```

---

## 3. CORE ARCHITECTURE

### 3.1 State Management Pattern (GetX MVC)
Every feature follows this strict pattern:
```
module/
  binding/    → GetX Bindings (lazy dependency injection)
  controller/ → Business logic (extends GetxController)
  model/      → Data models (fromJson/toJson)
  repo/       → API calls (uses Networking singleton)
  view/       → UI screens (Obx/GetBuilder)
  widget/     → Screen-specific widgets
```

### 3.2 Networking Layer
- `Networking` is a **singleton** (`Networking._()` private constructor)
- Extends `BaseClient` + mixes in `CacheManager`
- Every request auto-attaches Bearer token from `GetStorage`
- Methods: `getData`, `postData`, `putData`, `patchData`, `deleteData`, `postMultipartRequestData`
- Base URL: `https://hisab-box.softwaresnip.com/api/v1/`

### 3.3 Cache Layer (GetStorage)
`CacheManager` mixin is used by controllers and repos.
Key storage keys (enum `Key`):
| Key | Value Stored |
|---|---|
| `tokenKey` | JWT Bearer token |
| `userLoginIn` | bool (is logged in) |
| `userModels` | UserModel JSON |
| `bankModels` | BankDetailsModel JSON |
| `billNo` | int (last bill number) |
| `printerAddress` | Bluetooth printer MAC |
| `cartProduct` | List<InventoryItem> JSON (active cart) |
| `categoryValue` | List<CategoryModelListData> JSON |
| `animalCategoryValue` | List<CategoryModelListData> JSON |
| `customerListKey` | List<CustomerDetails> JSON |
| `inventoryScan` | bool (scan mode toggle) |

### 3.4 Hive / Supabase Status
- **Hive** (`local_db_service.dart`) — entire file is commented out. Was planned for offline caching of products, sales, revenue, discounts.
- **Supabase** (`supabase_client.dart`, `gobal_controller.dart`) — entire implementation commented out. Was a real-time sync layer for products, sales, loose stock. Currently app is 100% REST API based.
- **GlobalStore** (`gobal_controller.dart`) — fully commented out. Was a permanent GetX controller for in-memory product/sales cache with Supabase realtime subscriptions.

### 3.5 App Initialization (main.dart)
```
1. dotenv.load(.env)
2. ScreenUtil.ensureScreenSize()
3. GetStorage.init()
4. SystemChrome.setPreferredOrientations([portrait])
5. Firebase.initializeApp()
6. FirebaseMessaging.onBackgroundMessage(handler)
7. runApp(MyApp)
   → NotificationServices.init()
   → GetMaterialApp with AppRoutes
   → ScreenUtilInit (designSize: 375x812)
   → textScaler fixed at 1.0
```

---

## 4. ALL MODULES — SCREEN BY SCREEN

### 4.1 AUTH MODULE (`lib/module/auth/`)

#### Splash (`auth/splash/`)
- **Screen**: `SplashView`
- **Controller**: `SplashController`
- **Flow**: 2 second delay → check `retrieveIsLoggedIn()` from GetStorage
  - `true` → navigate to `/bottomNavigation`
  - `false` → navigate to `/login`

#### Login (`auth/login/`)
- **Screen**: `LoginView`
- **Controller**: `LoginController`
- **Models**: (uses inline response parsing)
- **Repo**: `LoginRepo`
- **Flow**:
  1. User enters email → `sendOtp()` → POST `auth/send-otp`
  2. User enters OTP → `verifyOtp()` → POST `auth/verify-otp`
  3. On success: `saveToken(token)`, `saveUserLoggedIn(true)` → navigate to `/bottomNavigation`
- **State**: `loginLoading`, `verifyLoading`, `obscureTextValue`

#### Signup (`auth/signup/`)
- **Screen**: `SignupView`
- **Controller**: `SignupController`
- **Repo**: `SignupRepo`
- **Flow**:
  1. Fill shop details (name, email, mobile, address, city, state, pincode, shopType)
  2. Optional profile image via `ImagePicker`
  3. POST `auth/registeruser` (multipart form)
  4. Default permissions JSON sent with signup (all `true` for admin)
  5. On success → navigate to `/login`
- **State**: `signUpLoading`, `isShopDetailFilled`, `profileImage`

---

### 4.2 BOTTOM NAVIGATION (`lib/module/bottom_navigation/`)
- **Screen**: `BottomNavigation`
- **Controller**: `BottomNavigationController`
- **Tabs**: Home, Credits, Customer, Reports, Settings (5 tabs)
- **Bindings loaded at route**: `HomeBinding`, `SettingBinding`, `CreditBinding`, `CustomerBinding`, `ReportBinding`
- **Connectivity**: Listens to `connectivity_plus` stream → redirects to `/nointernateConnection` if no internet
- **State**: `index` (current tab)

---

### 4.3 HOME MODULE (`lib/module/home/`)
- **Screen**: `HomeView`
- **Controller**: `HomeController`
- **Repo**: `HomeRepo` → GET `shop/dashboard`
- **Model**: `DashboardModel`, `GridModel`
- **Data Displayed**:
  - Total Products count
  - Out of Stock count
  - Today's Sales (revenue)
  - Loose Stock count
  - Recent Activities list (`RecentActivitiesData`)
- **Grid Cards** (4 tiles, each navigates):
  | Label | Route |
  |---|---|
  | Total Products | `/inventroyList` |
  | Out Of Stock | `/outOfStock` |
  | Today Sales | `/revenueView` |
  | Loose Stock | `/looseSell` |
- **State**: `isListLoading`, `totalBusRevenue`, `stock`, `outOfStock`, `looseStock`, `sellsList`

---

### 4.4 SELL MODULE (`lib/module/sell/`)

#### Sell View (`sell/view/sell.dart`)
- **Screen**: `SellView`
- **Controller**: `SellController`
- **Repo**: `SellRepo` → GET `sales?date=YYYY-MM-DD`
- **Model**: `SellModel` → `SellData` → `SellItemData`
- **Flow**: Shows today's sales list with date picker to change date
- **State**: `isSellListLoading`, `sellsList`, `dayDates`

#### Sell List After Scan (`sell/view/sell_list_after_scan.dart`)
- **Screen**: `SellListAfterScan`
- **Controller**: `SellListAfterScanController`
- **Repo**: `SellRepo` → POST `shop/sell`
- **Models**: `InventoryItem` (cart), `DiscountModel`, `PrintInvoiceModel`
- **Flow** (complete sale flow):
  1. Load cart from GetStorage (`retrieveCartProductList`)
  2. Show product list with qty +/- controls
  3. Per-product discount input
  4. Open payment dialog (`openPaymentDialog`)
  5. Split payment: Cash / UPI / Card / Credit / RoundOff
  6. `saleConfirmed()` → POST `shop/sell` with items + payments
  7. On success → clear cart → navigate to `/orderView`
- **State**: `productList`, `totalAmount`, `finalTotal`, `cashPaid`, `upiPaid`, `cardPaid`, `creditPaid`, `remainingAmount`, `isSaveLoading`

---

### 4.5 INVENTORY MODULE (`lib/module/inventory/`)
- **Screen**: `InventoryView` (barcode scanner screen)
- **Controller**: `InventroyController`
- **Repo**: `InventoryScanRepo` → GET `shop/products/barcode/{barcode}?stocktype=`
- **Model**: `ProductModel`, `BarcodeExistingModel`, `InventoryItem`
- **Flow**:
  1. Camera opens via `MobileScannerController`
  2. Barcode scanned → `handleScan()` → fetch product by barcode
  3. Check location == 'shop', check qty > 0
  4. Add to cart (GetStorage `cartProduct`)
  5. Navigate to `/sellListAfterScan`
- **Audio**: `AudioPlayer` plays beep on scan
- **State**: `scannedProductDetails`, `barcodeValue`, `isCameraStop`, `isScannedQtyOutOfStock`

---

### 4.6 INVENTORY LIST MODULE (`lib/module/inventorylist/`)
- **Screen**: `InventroyList`
- **Controller**: `InventoryListController`
- **Repo**: `InventoryRepo` → GET `shop/products?search={shop|godown}`
- **Model**: `InventoryModel` → `InventoryItem`
- **Flow**:
  - 2 tabs: Shop | Godown
  - Tab switch triggers `fetchInventoryByTab('shop'|'godown')`
  - Search filter (local, `searchText`)
  - Tap product → navigate to `/productDetailView`
  - Update product popup (qty, price, etc.)
- **State**: `shopProductList`, `goDownProductList`, `isDataLoading`, `searchText`, `tabController`

---

### 4.7 PRODUCT DETAILS MODULE (`lib/module/product_details/`)
- **Screen**: `ProductDetailView`
- **Controller**: `ProductDetailsController`
- **Repo**: `ProductRepo` → PUT `shop/products` (update packet), PUT `shop/products/loose-stock` (update loose)
- **Models**: `InventoryItem`, `LooseInvetoryModel`
- **Flow**:
  - Receives product data via `Get.arguments['product']`
  - Pre-fills all fields (name, barcode, qty, price, category, animal type, etc.)
  - Edit mode toggle (`readOnly`)
  - `updateProductQuantity()` → PUT packet product
  - `updateLoosedProductQuantity()` → PUT loose product
  - Stock transfer (godown→shop) — UI present, Supabase RPC commented out
- **State**: `isSaveLoading`, `readOnly`, `selectedCategoryId`, `selectedAnimalTypeId`

#### Product View (`product_details/view/product_view.dart`)
- **Controller**: `controller.dart` (ProductController)
- **Repo**: `ProductRepo` → POST `shop/products/add`
- Add new product form

---

### 4.8 GENERATE BARCODE MODULE (`lib/module/generate_barcode/`)
- **Screen**: `GenerateBarcode`
- **Controller**: `GenerateBarcodeController`
- **Repo**: `ProductRepo` → POST `shop/products/add`
- **Flow**:
  1. Auto-generates barcode: `HB{timestamp_last8}{random2digit}`
  2. Fill product details (name, category, animal type, price, qty, etc.)
  3. Categories loaded from GetStorage cache
  4. `saveNewProduct()` → POST `shop/products/add`
  5. On success → `Get.back(result: true)`
- **State**: `isSaveLoading`, `categoryList`, `animalTypeList`

---

### 4.9 REVENUE MODULE (`lib/module/revenue/`)

#### Revenue View (`revenue/view/revenue_view.dart`)
- **Screen**: `RevenueView`
- **Controller**: `RevenueController`
- **Repo**: `RevenueRepo` → GET `sales?date=`
- **Model**: `SellModel` → `SellItemData`
- **Flow**: Shows today's sales list + grand total. Date picker to change date.
- **State**: `isRevenueListLoading`, `sellsList`, `sellTotalAmount`, `dayDate`

#### Revenue Detail View (`revenue/view/revenue_detail_view.dart`)
- **Screen**: `RevenueDetailView`
- **Controller**: `DetailsRevenueController`
- **Repos**: `RevenueRepo` → GET `sales/{saleId}`, `InvoiceRepo` → GET invoice
- **Model**: `SellDetailsModel` → `SellDetailsData` → `SellDetailsItems`, `SellDetailsPayments`
- **Flow**:
  - Receives `SellItemData` via `Get.arguments` (has `saleId`, `billNo`)
  - `fetchSales(saleId)` → GET `sales/{saleId}`
  - Shows itemized bill: product name, qty, rate, discount, total
  - Shows payment breakdown
  - `fetchInvoice()` for print/share
- **State**: `isRevenueListLoading`, `sellDataList`, `date`

---

### 4.10 REPORTS MODULE (`lib/module/reports/`)
- **Screen**: `ReportView`
- **Controller**: `ReportController`
- **Repo**: `ReportDashboardOverview`
  - GET `reports/daily-overview` → `ReportOverviewModel`
  - GET `reports/top-products/graph` → `ReportTopProductModel`
  - GET `reports/top-products/list` → `ReportTopProductModel`
- **Models**: `ReportOverviewModel`, `ReportTopProductModel`, `ProductReportModel`
- **Features**:
  - 2 tabs (TabController)
  - Payment mode stats (cash/upi/card/credit totals)
  - Top selling products chart (fl_chart)
  - Top selling products list
  - Excel export (4 report types):
    1. Product Stock In
    2. Product Stock Out
    3. Selling with Payment
    4. Credit Amount
  - Date range: Today / Week / Month / Custom
- **State**: `reportOverViewStats`, `reportTopProductGraph`, `reportTopProductList`, `isExporting`, `isDashBoardOverView`

---

### 4.11 CUSTOMER MODULE (`lib/module/customer/`)
- **Screen**: `CustomerView`
- **Controller**: `CustomerController`
- **Repo**: `CustomerRepo`
  - GET `customer/customers` → `AllCustomerModel`
  - POST `customer/customers` → add customer
  - GET `customer/customers/mobile/{number}` → `AddCustomerModel`
- **Models**: `AddCustomerModel`, `AllCustomerModel` → `CustomerItem`
- **Flow**:
  - List all customers with search
  - Add customer (name, mobile, address, description)
  - Auto-fill by mobile number lookup
- **State**: `customerList`, `customDataLoading`, `isAddCustomerLoading`

---

### 4.12 CREDITS AMOUNT MODULE (`lib/module/credits_amount/`)
- **Screen**: `CreditView`
- **Controller**: `CredtiController`
- **Status**: Partially implemented — `fetchCreditReports()` only sets loading flag, no actual API call yet
- **Planned**: Show customers with pending credit amounts
- **State**: `customerDetailList`, `customDataLoading`

---

### 4.13 LOOSE SELL MODULE (`lib/module/loose_sell/`)
- **Screen**: `LooseSell`
- **Controller**: `LooseController`
- **Repo**: `LoosedProductRepo` → GET loose products
- **Model**: `LooseModel` → `InventoryItem`
- **Flow**: List loose inventory products with search filter
- **State**: `looseCategoryModelList`, `isDataLoading`, `searchText`

---

### 4.14 LOOSE CATEGORY MODULE (`lib/module/loose_category/`)
- **Screen**: `LooseCategory`
- **Controller**: `LooseCategoryController`
- **Model**: `LooseCategoryModel`
- Manage loose product categories

---

### 4.15 CATEGORY MODULE (`lib/module/category/`)
- **Screens**: `Category`, `AnimalCategory`
- **Controllers**: `CategoryController`, `AnimalTypeController`
- **Repos**: `CategoryRepo`, `AnimalCategoryRepo`
  - GET `shop/categories`
  - POST `shop/categories`
  - DELETE `shop/categories/{id}`
  - Same pattern for animal categories
- **Model**: `CategoryModel` → `CategoryModelListData`
- **Cache**: On fetch, saves to GetStorage (`categoryValue`, `animalCategoryValue`)

---

### 4.16 DISCOUNT MODULE (`lib/module/discount/`)
- **Screen**: `Discount`
- **Controller**: `DiscountController`
- **Model**: `DiscountModel`
- Manage discount presets used during selling

---

### 4.17 EXPENSE MODULE (`lib/module/expense/`)
- **Screen**: `Expense`
- **Controller**: `ExpenseController`
- **Model**: `ExpenseModel`
- Track business expenses

---

### 4.18 OUT OF STOCK MODULE (`lib/module/out_of_stock/`)
- **Screen**: `OutOfStockView`
- **Controller**: `OutOfStockController`
- **Repo**: `OutOfStockRepo` → GET `shop/stock/out-of-stock`
- **Model**: `NeaExpiryItemData` (shared with near expiry)
- **Flow**: List products with 0 quantity, search filter
- **State**: `productList`, `isDataLoading`, `searchText`

---

### 4.19 NEAR EXPIRE PRODUCT MODULE (`lib/module/near_expire_product/`)
- **Screen**: `NearExpireProductView`
- **Controller**: `NearExpireProductController`
- **Repo**: `NearExpiryRepo` → GET `shop/stock/near-expiry`
- **Model**: `NearExpiryModel` → `NeaExpiryItemData`
- **Flow**: List products nearing expiry date
- **State**: `nearExpProductList`, `isDataloading`

---

### 4.20 INVOICE MODULE (`lib/module/invoice/`)
- **Screen**: `InvoicePrint`, `BarcodeView`, `OptimizedBarcodeView`
- **Controller**: `InvoiceController`, `BarcodeController`
- **Repo**: `InvoiceRepo` → GET `sales/invoice`
- **Model**: `InvoiceModel`
- **Flow (Invoice)**:
  1. Receives sale data via `Get.arguments`
  2. Renders receipt widget via `ReceiptController` (flutter_bluetooth_printer)
  3. `shareReceiptAsPDF()` → converts receipt to PDF → shares via `share_plus`
  4. Bluetooth print via `flutter_bluetooth_printer`
- **Bluetooth Check**: `CommonBluetooth` mixin → `FlutterBluePlus.adapterState`
- **State**: `isPrintingLoading`, `isShareReceiptLoading`, `receiptController`

---

### 4.21 ORDER COMPLETE MODULE (`lib/module/order_complete/`)
- **Screen**: `OrderView`
- **Controller**: `OrderController`
- **Model**: `CustomerDetailsModel`
- **Flow**: Post-sale confirmation screen. Shows bill summary, print/share options.
- Navigated to after successful `saleConfirmed()` in `SellListAfterScanController`

---

### 4.22 ADD USER MODULE (`lib/module/add_user/`)
- **Screens**: `AddUserView`, `AllUserView`, `AllUserDetailView`, `UserRoleView`
- **Controllers**: `AddUserController`, `AllUserController`, `AllUserDetailController`, `UserRoleController`
- **Repos**: `AddUserRepo`, `AllUserViewRepo`, `UserRoleRepo`
  - POST `employees/add`
  - GET `employees`
  - GET/POST/PUT/DELETE `roles`
  - PUT `permissions`
- **Models**: `EmployeeModel`, `AddEmployeeModel`, `UpdateEmployeeModel`, `AddUserRoleModel`, `AllUserRoleModel`
- **Features**: Add staff, view all staff, manage roles & permissions
- **Widget**: `PermissionWidgets` — granular permission toggles

---

### 4.23 BANK DETAILS MODULE (`lib/module/bank_details/`)
- **Screen**: `BankdetailsView`
- **Controller**: `BankdetailsController`
- **Repo**: `BankRepo` → GET/POST `shop/bank-details`
- **Model**: `BankDetailsModel`
- **Cache**: Saved to GetStorage `bankModels`

---

### 4.24 USER PROFILE MODULE (`lib/module/user_profile/`)
- **Screen**: `UserProfileView`
- **Controller**: `UserProfileController`
- **Repo**: `UserProfileRepo` → GET/PUT `auth/profile`
- **Model**: `UserModel` (from setting module)
- **Flow**:
  - Load from GetStorage first, fallback to API
  - Edit mode toggle
  - Update profile → PUT `auth/profile`
  - Image picker (local only, upload not wired)
- **State**: `isLoading`, `readOnly`, `profileImage`

---

### 4.25 SETTING MODULE (`lib/module/setting/`)
- **Screen**: `SettingView`
- **Controller**: `SettingController`
- **Repos**: `LogoutRepo` → POST `auth/logout`, `UserProfileRepo`
- **Model**: `UserModel`
- **Features**:
  - Show shop name + email
  - Logout → clears GetStorage → navigate to `/login`
  - Customer support (email + phone launcher via `url_launcher`)
  - Navigate to: User Profile, Bank Details, Add User, App Settings, Privacy Policy, Terms
- **State**: `storeName`, `email`, `isUserlogout`

---

### 4.26 APP SETTINGS MODULE (`lib/module/app_settings/`)
- **Screen**: `AppSettingView`
- **Controller**: `AppSettingController`
- App-level settings (inventory scan toggle, printer config, etc.)

---

### 4.27 STOCK TRANSFER / NOTIFICATION MODULE (`lib/module/stock_transfer/`)
- **Screen**: `NotificationView`
- **Controller**: `NotificationController`
- **Note**: Named "stock_transfer" in folder but shows notifications
- Godown → Shop transfer requests (Supabase RPC was planned, currently stub)

---

### 4.28 SECURITY MODULE (`lib/module/security/`)
- **Screens**: `PrivacyPolicy`, `TermAndCondition`
- Static content screens

---

### 4.29 PUSH NOTIFICATION MODULE (`lib/module/push_notification/`)
- **Service**: `NotificationServices` (local_notification_service.dart)
- Firebase Messaging integration
- `getDeviceToken()`, `notificationPermission()`, `forgroundIosMessege()`
- `handlePayload(topic, id)` for deep linking (partially implemented)

---

### 4.30 UNKNOWN / ERROR SCREENS (`lib/module/unknown/`)
- `UnknownRoute` — 404 screen
- `NointernateConnection` — No internet screen

---

## 5. API ENDPOINTS — COMPLETE LIST

Base URL: `https://hisab-box.softwaresnip.com/api/v1/`

### Auth
| Method | Endpoint | Used In |
|---|---|---|
| POST | `auth/registeruser` | SignupRepo |
| POST | `auth/send-otp` | LoginRepo |
| POST | `auth/verify-otp` | LoginRepo |
| GET | `auth/profile` | UserProfileRepo, SettingController |
| PUT | `auth/profile` | UserProfileRepo |
| POST | `auth/logout` | LogoutRepo |

### Dashboard
| Method | Endpoint | Used In |
|---|---|---|
| GET | `shop/dashboard` | HomeRepo |

### Products
| Method | Endpoint | Used In |
|---|---|---|
| GET | `shop/products?search={shop\|godown}` | InventoryRepo (InventoryList) |
| POST | `shop/products/add` | ProductRepo (GenerateBarcode, ProductView) |
| GET | `shop/products/barcode/{barcode}?stocktype=` | InventoryScanRepo |
| PUT | `shop/products/{id}` | ProductRepo (ProductDetails) |
| POST | `shop/products/convert-packet-to-loose` | ProductRepo |
| PUT | `shop/products/loose-stock` | ProductRepo |

### Sales
| Method | Endpoint | Used In |
|---|---|---|
| GET | `sales?date=YYYY-MM-DD` | SellRepo, RevenueRepo |
| GET | `sales/{saleId}` | RevenueRepo (detail) |
| POST | `shop/sell` | SellRepo (checkout) |
| GET | `sales/invoice` | InvoiceRepo |

### Categories
| Method | Endpoint | Used In |
|---|---|---|
| GET | `shop/categories` | CategoryRepo |
| POST | `shop/categories` | CategoryRepo |
| DELETE | `shop/categories/{id}` | CategoryRepo |
| GET | `shop/animal-categories` | AnimalCategoryRepo |
| POST | `shop/animal-categories` | AnimalCategoryRepo |
| DELETE | `shop/animal-categories/{id}` | AnimalCategoryRepo |

### Stock
| Method | Endpoint | Used In |
|---|---|---|
| GET | `shop/stock/near-expiry` | NearExpiryRepo |
| GET | `shop/stock/out-of-stock` | OutOfStockRepo |
| POST | `shop/transfer-godown-to-shop` | (planned) |

### Reports
| Method | Endpoint | Used In |
|---|---|---|
| GET | `reports/daily-overview` | ReportDashboardOverview |
| GET | `reports/top-products/graph` | ReportDashboardOverview |
| GET | `reports/top-products/list` | ReportDashboardOverview |

### Customers
| Method | Endpoint | Used In |
|---|---|---|
| GET | `customer/customers` | CustomerRepo |
| POST | `customer/customers` | CustomerRepo |
| GET | `customer/customers/mobile/{number}` | CustomerRepo |

### Employees & Roles
| Method | Endpoint | Used In |
|---|---|---|
| POST | `employees/add` | AddUserRepo |
| GET | `employees` | AllUserViewRepo |
| GET/POST/PUT/DELETE | `roles` | UserRoleRepo |
| PUT | `permissions` | UserRoleRepo |

### Bank
| Method | Endpoint | Used In |
|---|---|---|
| GET | `shop/bank-details` | BankRepo |
| POST | `shop/bank-details` | BankRepo |

---

## 6. DATA FLOW — KEY FLOWS

### 6.1 Login Flow
```
LoginView
  → email input → sendOtp() → POST auth/send-otp
  → OTP input → verifyOtp() → POST auth/verify-otp
  → saveToken(jwt) + saveUserLoggedIn(true) [GetStorage]
  → navigate /bottomNavigation
```

### 6.2 Sell / Checkout Flow
```
HomeView (Quick Action)
  → /inventoryView (InventoryView + MobileScanner)
  → Scan barcode → GET shop/products/barcode/{barcode}
  → Add to cart (GetStorage cartProduct)
  → /sellListAfterScan (SellListAfterScan)
  → Adjust qty, apply per-product discount
  → Open payment dialog → split: cash/upi/card/credit/roundoff
  → saleConfirmed() → POST shop/sell {items[], payments[]}
  → On success → clear cart → /orderView
  → OrderView → print/share invoice
```

### 6.3 Revenue Detail Flow
```
RevenueView (list of today's sales)
  → tap SellItemData (has saleId, billNo)
  → /revenueDetailView (Get.arguments = SellItemData)
  → DetailsRevenueController.fetchSales(saleId)
  → GET sales/{saleId}
  → Show itemized bill + payment breakdown
  → fetchInvoice() for print
```

### 6.4 Product Add Flow
```
/generateBarcode (GenerateBarcode)
  → Auto-generate barcode (HB + timestamp + random)
  → Fill form (name, category, animal, price, qty, expiry)
  → Categories from GetStorage cache
  → saveNewProduct() → POST shop/products/add
  → Get.back(result: true) → parent refreshes list
```

### 6.5 Inventory List → Product Detail Flow
```
/inventroyList (InventroyList)
  → Tab: Shop | Godown
  → GET shop/products?search=shop (or godown)
  → Tap product → /productDetailView
  → Get.arguments = {product: InventoryItem, ...}
  → ProductDetailsController.setData() pre-fills form
  → Edit → updateProductQuantity() → PUT shop/products/{id}
```

---

## 7. NAVIGATION MAP

```
/splash
  ├── /login
  │     └── /signup
  └── /bottomNavigation  [Home | Credits | Customer | Reports | Settings]
        ├── /home
        │     ├── /inventoryView → /sellListAfterScan → /orderView → /invoicePrintView
        │     ├── /inventroyList → /productDetailView
        │     ├── /revenueView → /revenueDetailView
        │     ├── /outOfStock
        │     ├── /looseSell
        │     ├── /nearExpireProduct
        │     ├── /generateBarcode
        │     ├── /reports
        │     └── /notificationView
        ├── /setting
        │     ├── /userProfile
        │     ├── /bankDetails
        │     ├── /allUser → /addUser, /allUserDetail, /userRoleView
        │     ├── /appsetting
        │     ├── /privacypolicy
        │     └── /termandcodition
        ├── /expense
        ├── /discount
        ├── /category
        ├── /animalCategory
        ├── /looseCategory
        └── /barcodePrintView
```

---

## 8. MODELS REFERENCE

| Model | File | Fields |
|---|---|---|
| `SellModel` | sell/model/sell_model.dart | success, msg, data(SellData) |
| `SellData` | sell/model/sell_model.dart | grandTotal, totalBills, data[SellItemData] |
| `SellItemData` | sell/model/sell_model.dart | saleId, billNo, customerName, amount, paymentType, paymentMode, date |
| `SellDetailsModel` | sell/model/sell_details_model.dart | success, msg, data(SellDetailsData) |
| `SellDetailsData` | sell/model/sell_details_model.dart | saleId, billNo, customerName, customerMobile, dateTime, paymentType, totalAmount, roundOff, finalTotal, items[], payments[] |
| `SellDetailsItems` | sell/model/sell_details_model.dart | productName, qty, rate, discount, total |
| `SellDetailsPayments` | sell/model/sell_details_model.dart | mode, amount |
| `InventoryItem` | inventorylist/model/inventory_model.dart | id, name, barcode, quantity, sellingPrice, purchasePrice, discount, stockType, location, categoryName, animalTypeName, flavour, weight, rack, level, isloosed, isflavorRequired, purchaseDate, expireDate |
| `ProductModel` | inventory/model/product_model.dart | Full product with barcode, stock info |
| `BarcodeExistingModel` | inventory/model/product_model.dart | success, msg, data(BarcodeExistingData) |
| `DashboardModel` | home/model/dashboard_model.dart | success, stats(totalProducts, todaySales, outOfStock, looseStock), recentActivities |
| `UserModel` | setting/model/user_model.dart | success, msg, data(UserData: name, email, mobileNo, address, city, state, pincode, alternateMobileNo) |
| `BankDetailsModel` | bank_details/model/bank_model.dart | bank account details |
| `CategoryModel` | category/model/category_model.dart | id, name, list[CategoryModelListData] |
| `DiscountModel` | discount/model/discount_model.dart | discount presets |
| `LooseModel` | loose_sell/model/loose_model.dart | loose inventory items |
| `NearExpiryModel` | near_expire_product/model/near_expiry_model.dart | data[NeaExpiryItemData] |
| `ReportOverviewModel` | reports/model/report_over_view_model.dart | payment mode totals |
| `ReportTopProductModel` | reports/model/report_top_product_model.dart | top selling products |
| `InvoiceModel` | invoice/model/invoice_model.dart | invoice data for printing |
| `PrintInvoiceModel` | sell/model/print_model.dart | data passed to order/invoice screen |
| `AllCustomerModel` | customer/model/all_customer_model.dart | customers[] |
| `AddCustomerModel` | customer/model/add_customer_model.dart | single customer data |
| `CustomerDetails` | order_complete/model/customer_details_model.dart | customer + totalCredit |

---

## 9. KNOWN ISSUES & TECHNICAL DEBT

### Dead Code (Commented Out)
- `lib/local_db/local_db_service.dart` — entire Hive service commented out
- `lib/supabase_db/supabase_client.dart` — entire Supabase client commented out
- `lib/module/gobal_module/gobal_controller.dart` — GlobalStore (realtime sync) commented out
- `lib/module/gobal_module/gobal_binding.dart` — binding empty (Get.put commented)
- `main.dart` — `LocalService.initHive()` commented, Supabase init commented

### Unused Imports (Warnings)
Many controllers import `local_db_service.dart`, `supabase_client.dart`, `gobal_controller.dart` but don't use them. These are leftover from Supabase migration.

### Bugs
- `BottomNavigationController`: `results.first == ConnectivityResult.none` type mismatch (List vs single)
- `DetailsRevenueController`: uses `print()` instead of `AppLogger`
- `SellListAfterScanController`: `updateQuantity()` — `availableQty` hardcoded to `0.0` (stock check broken)
- `CredtiController.fetchCreditReports()` — only sets loading flag, no actual data fetch

### Incomplete Features
- Credits module — no API call wired
- Stock Transfer (godown→shop) — UI exists, Supabase RPC commented out
- Notification deep linking — `handlePayload` partially implemented
- Profile image upload — picker works but upload not wired to API

---

## 10. COMMON WIDGET REFERENCE

| Widget | File | Purpose |
|---|---|---|
| `AppColors` | colors.dart | Color constants |
| `CommonAppBar` | common_appbar.dart | Reusable AppBar |
| `CommonBottomSheet` | common_bottom_sheet.dart | Bottom sheet wrapper |
| `CommonButton` | common_button.dart | Primary button |
| `CommonCalender` | common_calender.dart | Date picker |
| `CommonContainer` | common_container.dart | Styled container |
| `CommonDialogue` | common_dialogue.dart | Alert dialog |
| `CommonDivider` | common_divider.dart | Divider |
| `CommonDropdown` | common_dropdown.dart | Dropdown selector |
| `CommonNoDataFound` | common_nodatafound.dart | Empty state |
| `CommonProgressBar` | common_progressbar.dart | Loading indicator |
| `CommonRadioButton` | common_radio_button.dart | Radio button |
| `CommonSwitch` | common_switch.dart | Toggle switch |
| `Search` | search.dart | Search input |
| `TextFiled` | textfiled.dart | Custom text field |

---

## 11. HELPER FUNCTIONS

| Function | File | Purpose |
|---|---|---|
| `showSnackBar(error, isError)` | helper.dart | GetX snackbar |
| `showMessage(message, isActionRequired, onPressed)` | helper.dart | Info message |
| `unfocus()` | helper.dart | Dismiss keyboard |
| `customMessageOrErrorPrint(message)` | helper.dart | Debug print |
| `setFormateDate()` | set_format_date.dart | Returns today as `dd-MM-yyyy` |
| `getFormattedDate(date)` | set_format_date.dart | Format conversion |
| `AppLogger.info(msg)` | logger.dart | Debug log |
| `AppLogger.error(msg, e, tag)` | logger.dart | Error log |

---

## 12. ENVIRONMENT CONFIG (.env)

File loaded via `flutter_dotenv`. Expected keys:
- `SUPABASE_URL` (currently unused — Supabase commented out)
- `SUPABASE_ANON_KEY` (currently unused)

---

## 13. ASSETS

```
assets/
├── beepsound.mp3          # Barcode scan beep
├── card.png               # Payment method icon
├── cash.png               # Payment method icon
├── connection.png         # No internet screen
├── creditamount.png       # Credit icon
├── goldenpets logo.png    # App logo variant
├── goldenpets_logo_optimized.jpg
├── hisabboxlogo.png       # Main app logo
├── roundoff.png           # Round off icon
├── unknwon_route.png      # 404 screen
├── upiPayment.png         # UPI icon
└── verify.png             # Verification icon
```

---

## 14. FUTURE DEVELOPMENT NOTES

1. **Re-enable Hive**: Uncomment `LocalService.initHive()` in main.dart and `local_db_service.dart` for offline support
2. **Credits Module**: Wire `CredtiController.fetchCreditReports()` to a real API endpoint
3. **Stock Transfer**: Implement REST API for godown→shop transfer (replace Supabase RPC)
4. **Fix stock check in sell**: `SellListAfterScanController.updateQuantity()` — fetch real available qty
5. **Notification deep linking**: Complete `handlePayload` routing
6. **Profile image upload**: Wire `UserProfileController.pickImage()` to multipart PUT `auth/profile`
7. **Connectivity bug**: Fix `BottomNavigationController` — `results.first` is `List<ConnectivityResult>` not single
8. **Clean unused imports**: Remove all dead `local_db_service`, `supabase_client`, `gobal_controller` imports
9. **GlobalStore**: If realtime sync needed again, uncomment and wire `GlobalStore` with new REST polling or Supabase
10. **Barcode print**: `OptimizedBarcodeView` and `BarcodeView` — verify print flow end-to-end
