# HisabBox — Project Audit & Architecture Reference

> Generated: April 30, 2026  
> App: `inventory` (HisabBox — Inventory Management System)  
> Flutter SDK: `^3.7.2` | State Management: GetX `^4.7.2`

---

## 1. Project Overview

HisabBox is a Flutter-based inventory and POS (Point of Sale) management app for retail shops. It supports product management, sales, reporting, barcode scanning, Bluetooth printing, and real-time sync across devices.

**Architecture:** GetX MVC + Repository Pattern  
**Primary Backend:** REST API (`https://hisab-box.softwaresnip.com/api/v1/`) + Supabase (PostgreSQL + Realtime)  
**Local Storage:** Hive (offline cache) + GetStorage (preferences/session)  
**Push Notifications:** Firebase Messaging  

---

## 2. App Entry Point

**File:** `lib/main.dart`

Initialization order:
1. `dotenv.load(.env)` — loads Supabase URL, anon key
2. `SupabaseConfig.init()` — initializes Supabase client
3. `LocalService.initHive()` — opens Hive box
4. `GetStorage.init()` — initializes key-value store
5. `Get.put(GlobalStore(), permanent: true)` — registers global state
6. Firebase Core + Messaging setup
7. `GetMaterialApp` with `initialRoute: /splash`

---

## 3. Folder Structure (`lib/`)

```
lib/
├── bluetooth/              # Bluetooth printer integration
├── cache_manager/          # GetStorage mixin (session/preferences)
├── common_widget/          # Shared UI components, colors, themes
├── helper/                 # Logger, date formatter, device info, helpers
├── keys/                   # App-wide constants and enum keys
├── local_db/               # Hive offline cache service
├── module/                 # 33 feature modules (see Section 5)
├── network/                # HTTP client, base client, API endpoints
├── responsive_layout/      # Screen size utilities
├── routes/                 # GetX route definitions and names
├── supabase_db/            # Supabase client, error handler, storage service
├── firebase_options.dart   # Firebase config (auto-generated)
└── main.dart               # App entry point
```

---

## 4. Module List (33 Modules)

| Module | Purpose |
|---|---|
| `add_user` | Employee/staff management |
| `app_settings` | App configuration screen |
| `auth` | Login (OTP), Signup, Splash |
| `bank_details` | Bank account management |
| `bottom_navigation` | Main app shell / tab navigation |
| `category` | Product category CRUD |
| `credits_amount` | Credit sales tracking |
| `customer` | Customer management |
| `customfirebase` | Custom Firebase utilities |
| `discount` | Discount management |
| `expense` | Expense tracking |
| `generate_barcode` | Barcode generation & printing |
| `gobal_module` | Global state (GlobalStore) |
| `home` | Dashboard / stats overview |
| `inventory` | Inventory management |
| `inventorylist` | Inventory list view |
| `invoice` | Invoice generation & printing |
| `loose_category` | Loose product categories |
| `loose_sell` | Loose product sales |
| `near_expire_product` | Near-expiry stock tracking |
| `notification` | Notification placeholder (empty) |
| `order_complete` | Order completion flow |
| `out_of_stock` | Out-of-stock tracking |
| `product_details` | Product CRUD + godown transfer |
| `push_notification` | Firebase push notification handler |
| `reports` | Sales analytics, Excel export |
| `revenue` | Revenue tracking |
| `security` | Privacy policy, T&C screens |
| `sell` | Sales / POS transactions |
| `setting` | User settings |
| `stock_transfer` | Godown-to-shop stock transfers |
| `unknown` | 404 / no-internet screens |
| `user_profile` | User profile management |

Each module follows this internal structure:
```
module_name/
├── binding/        # GetX dependency injection
├── controller/     # Business logic + Rx state
├── model/          # Data classes (fromJson/toJson)
├── repo/           # API/DB calls
├── view/           # UI screens
└── widget/         # Module-specific widgets
```

---

## 5. State Management

### GlobalStore (`lib/module/gobal_module/gobal_controller.dart`)
Permanent singleton registered at app start. Owns all shared app state.

**Observables:**
```dart
RxList<ProductModel> allProducts
RxList<LooseInvetoryModel> allLooseProducts
RxList<SellsModel> allSalesList
RxMap<String, ProductModel> barcodeToProductMap
RxBool isInitialDataLoaded
RxDouble cashTotal, upiTotal, creditTotal, cardTotal
```

**Key Methods:**
| Method | Description |
|---|---|
| `loadInitialData()` | Fetches products, loose stock, today's sales from Supabase |
| `startRealtimeSync()` | Subscribes to Supabase Postgres change events |
| `fetchSalesByDate(date)` | Fetches sales for a specific date |
| `markOptimisticBill(billNo)` | Marks a bill as pending (optimistic update) |
| `updateBarcodeMapFromList(products)` | Rebuilds barcode lookup map |
| `_loadFromHive()` | Loads cached data on cold start |
| `_bindAuthSync()` | Listens to auth state changes, reloads on sign-in |

**Realtime Subscriptions (Supabase):**
| Table | Event | Action |
|---|---|---|
| `sales` | INSERT | Fetch new sale, upsert in memory |
| `sales` | UPDATE/DELETE | Full reload via `loadInitialData()` |
| `sale_payments` | ALL | Reload if sale belongs to current user |
| `product_stock` | UPDATE | Update quantity in-memory + Hive |
| `loose_stocks` | UPDATE | Update quantity in-memory + Hive |
| `products` | ALL | Full reload |

### CacheManager (`lib/cache_manager/cache_manager.dart`)
Mixin used by controllers for GetStorage access.

**Stored Keys:**
| Key | Type | Purpose |
|---|---|---|
| `userLoginIn` | bool | Login status |
| `tokenKey` | String | Auth bearer token |
| `billNo` | int | Current bill number |
| `userModels` | UserModel | Logged-in user profile |
| `bankModels` | BankDetailsModel | Bank details |
| `printerAddress` | String | Bluetooth printer MAC |
| `inventoryScan` | bool | Scan mode toggle |
| `cartProduct` | List | Cart items |
| `categoryValue` | List | Cached categories |
| `animalCategoryValue` | List | Cached animal types |
| `customerListKey` | List | Cached customers |

---

## 6. Network Layer

### HTTP Client (`lib/network/networking.dart`)
Singleton class. All REST API calls go through this.

**Methods:**
| Method | HTTP Verb | Usage |
|---|---|---|
| `getData(url, body?)` | GET | Fetch data with query params |
| `postData(url, body)` | POST | Create/submit data |
| `putData(url, body)` | PUT | Full update |
| `patchData(url, body)` | PATCH | Partial update |
| `deleteData(url, body?)` | DELETE | Remove data |
| `postMultipartRequestData(...)` | POST multipart | File/image upload |

All requests automatically attach `Authorization: Bearer <token>` from CacheManager.

### API Endpoints (`lib/network/api_endpoint.dart`)
Base URL: `https://hisab-box.softwaresnip.com/api/v1/`

| Group | Endpoint | Method |
|---|---|---|
| **Auth** | `auth/registeruser` | POST |
| | `auth/send-otp` | POST |
| | `auth/verify-otp` | POST |
| | `auth/profile` | GET / PUT |
| | `auth/logout` | POST |
| **Dashboard** | `shop/dashboard` | GET |
| **Categories** | `shop/categories` | GET / POST / DELETE |
| | `shop/animal-categories` | GET / POST / DELETE |
| **Products** | `shop/products` | GET |
| | `shop/products/add` | POST |
| | `shop/products/convert-packet-to-loose` | POST |
| | `shop/products/barcode/{barcode}` | GET |
| **Sales** | `shop/sell` | POST |
| | `sales` | GET |
| **Inventory** | `shop/transfer-godown-to-shop` | POST |
| **Stock** | `shop/stock/near-expiry` | GET |
| | `shop/stock/out-of-stock` | GET |
| **Reports** | `shop/reports/sales` | GET |
| | `reports/daily-overview` | GET |
| | `reports/top-products/graph` | GET |
| | `reports/top-products/list` | GET |
| **Customers** | `customer/customers` | GET / POST |
| | `customer/customers/mobile/{mobile}` | GET |
| **Employees** | `employees/add` | POST |
| | `employees` | GET |
| | `permissions` | PUT |
| **Bank** | `shop/bank-details` | GET / POST |
| **Roles** | `roles` | GET / POST / PUT / DELETE |

### Supabase Client (`lib/supabase_db/supabase_client.dart`)
Initialized from `.env` variables: `SUPABASE_URL`, `SUPABASE_ANON_KEY`.  
Custom HTTP client with 20s timeout. Realtime: 10 events/second.

**Supabase Tables Used:**
| Table | Purpose |
|---|---|
| `products` | Product master data |
| `product_stock` | Stock levels per location |
| `loose_stocks` | Loose product inventory |
| `sales` | Transaction records |
| `sale_items` | Line items per sale |
| `sale_payments` | Payment breakdown per sale |
| `customers` | Customer records |
| `employees` | Staff records |
| `categories` | Product categories |
| `animal_categories` | Animal type categories |
| `stock_batches` | Batch tracking (purchase/expiry dates) |
| `product_barcodes` | Barcode-to-product mapping |

---

## 7. Controllers → Repo → API/DB → Model Mapping

### Auth Module
| Controller | Repo | API Endpoint | Model |
|---|---|---|---|
| `LoginController` | `LoginRepo` | `auth/send-otp` (POST) | `SentOtpModel` |
| | | `auth/verify-otp` (POST) | `LoginModel` |
| `SignupController` | `SignupRepo` | `auth/registeruser` (POST) | `SignupModel` |

**LoginController key methods:**
- `sendOtp()` → `loginRepo.sendOpt(body)` → shows snackbar, returns bool
- `verifyOtp(otp)` → `loginRepo.verifyOtp(body)` → saves token + user, navigates to home

---

### Home / Dashboard
| Controller | Repo | API Endpoint | Model |
|---|---|---|---|
| `HomeController` | `HomeRepo` | `shop/dashboard` (GET) | `DashboardModel` |

**HomeController key state:**
```dart
RxNum totalBusRevenue, stock, goDownStock, sellStock
RxNum totalExpense, looseStock, outOfStock, nearExpiryCount
RxList<RecentActivitiesData> sellsList
RxList<LooseInvetoryModel> looseInventoryList
RxList<GoDownStockTransferToShopModel> pendingTransfers
```

**Key methods:**
- `loadDashboard()` → calls `homeRepo.getDashBoardData()` → populates all stats

---

### Sell / POS
| Controller | Repo | API Endpoint | Model |
|---|---|---|---|
| `SellController` | `SellRepo` | `sales` (GET) | `SellItemData` |

**SellController key state:**
```dart
RxBool isSellListLoading
RxList<SellItemData> sellsList
RxString dayDates
```

**Key methods:**
- `fetchSales(todaysDate?)` → `sellRepo.fetchSell(date)` → populates `sellsList`

> Note: Actual sale creation goes through Supabase directly (GlobalStore handles realtime insert confirmation).

---

### Reports
| Controller | Repo | API Endpoint | Model |
|---|---|---|---|
| `ReportController` | `ReportDashboardOverview` | `reports/daily-overview` (GET) | `ReportOverviewModel` |
| | | `reports/top-products/graph` (GET) | `ReportTopProductModel` |
| | | `reports/top-products/list` (GET) | `ReportTopProductModel` |

**ReportController key state:**
```dart
RxDouble totalRevenue, totalProfit, totalCash, totalUpi, totalCard, totalCredit
RxList<ReportTopProductData> reportTopProductGraph, reportTopProductList
RxList<ProductReportModel> productStockInList
Rx<ReportOverviewData> reportOverViewStats
```

**Key methods:**
- `fetchModeOfPaymentStats()` → daily overview stats
- `fetchTopSellingProductsChart()` → chart data
- `fetchTopSellingProducts()` → list data
- `exportProductInReport(...)` → generates Excel file, opens it

---

### Inventory / Products
| Controller | Repo | API/DB | Model |
|---|---|---|---|
| `InventoryController` | `InventoryRepo` | Supabase `product_stock` + REST | `ProductModel` |
| `ProductDetailsController` | `ProductDetailsRepo` | `shop/products/add` (POST) | `ProductModel` |

**ProductModel key fields:**
```dart
id, barcode, name, category, animalType, quantity, purchasePrice,
sellingPrice, weight, flavour, location, stockType, isLooseCategory,
expireDate, purchaseDate, discount, isActive, userId
```

---

### Category
| Controller | Repo | API Endpoint | Model |
|---|---|---|---|
| `CategoryController` | `CategoryRepo` | `shop/categories` (GET/POST/DELETE) | `CategoryModel` |
| `AnimalCategoryController` | `AnimalCategoryRepo` | `shop/animal-categories` (GET/POST/DELETE) | `CategoryModel` |

---

### Customer
| Controller | Repo | API Endpoint | Model |
|---|---|---|---|
| `CustomerController` | `CustomerRepo` | `customer/customers` (GET/POST) | `CustomerDetailsModel` |
| | | `customer/customers/mobile/{mobile}` (GET) | `CustomerDetailsModel` |

---

### Expense
| Controller | Repo | API Endpoint | Model |
|---|---|---|---|
| `ExpenseController` | `ExpenseRepo` | (expense endpoints) | `ExpenseModel` |

---

### Revenue
| Controller | Repo | API Endpoint | Model |
|---|---|---|---|
| `RevenueController` | `RevenueRepo` | (revenue endpoints) | `RevenueModel` |

**RevenueModel key fields:**
```dart
date, totalSales, cashAmount, upiAmount, cardAmount, creditAmount
```

---

### Add User / Employees
| Controller | Repo | API Endpoint | Model |
|---|---|---|---|
| `AddUserController` | `AddUserRepo` | `employees/add` (POST) | `EmployeeModel` |
| `AllUserController` | `AllUserRepo` | `employees` (GET) | `EmployeeModel` |
| `UserRoleController` | `UserRoleRepo` | `roles` (GET/POST/PUT/DELETE) | `RoleModel` |

---

### Bank Details
| Controller | Repo | API Endpoint | Model |
|---|---|---|---|
| `BankDetailsController` | `BankDetailsRepo` | `shop/bank-details` (GET/POST) | `BankDetailsModel` |

---

### Stock Transfer
| Controller | Repo | API Endpoint | Model |
|---|---|---|---|
| `StockTransferController` | (repo) | `shop/transfer-godown-to-shop` (POST) | `GoDownStockTransferToShopModel` |

---

### Out of Stock / Near Expiry
| Controller | Repo | API Endpoint | Model |
|---|---|---|---|
| `OutOfStockController` | `OutOfStockRepo` | `shop/stock/out-of-stock` (GET) | `ProductModel` |
| `NearExpiryController` | `NearExpiryRepo` | `shop/stock/near-expiry` (GET) | `ProductModel` |

---

### Discount
| Controller | Repo | API Endpoint | Model |
|---|---|---|---|
| `DiscountController` | `DiscountRepo` | (discount endpoints) | `DiscountModel` |

**DiscountModel key fields:**
```dart
id, name, percentage, description, isActive, userId
```

---

### User Profile / Settings
| Controller | Repo | API Endpoint | Model |
|---|---|---|---|
| `UserProfileController` | `UserRepo` | `auth/profile` (GET/PUT) | `UserModel` |
| `SettingController` | `SettingRepo` | (settings endpoints) | `UserModel` |

---

## 8. Local Database (Hive)

**Service:** `lib/local_db/local_db_service.dart`  
**Box:** `inventory_Box`

| Cache Key | Type | Purpose |
|---|---|---|
| `cached_products` | `List<ProductModel>` | All products offline |
| `cached_loose_products` | `List<LooseInvetoryModel>` | Loose stock offline |
| `cached_expiry_products` | `List` | Near-expiry products |
| `cached_out_of_stock` | `List` | Out-of-stock products |
| `cached_categories` | `List<CategoryModel>` | Categories |
| `cached_animal_types` | `List<CategoryModel>` | Animal categories |
| `daily_sales_{date}` | `List<SellModel>` | Sales by date |
| `revenue_{date}` | `List` | Revenue by date |
| `pending_stock_transfers` | `List<GoDownStockTransferToShopModel>` | Pending transfers |
| `daily_report_stats` | `Map` | Daily report stats |
| `cached_top_products` | `List` | Top selling products |

**Key Methods:**
```dart
LocalService.saveProducts(List<ProductModel>)
LocalService.getCachedProducts() → List<ProductModel>
LocalService.saveLooseProducts(List<LooseInvetoryModel>)
LocalService.getCachedLooseProducts() → List<LooseInvetoryModel>
LocalService.saveTodaySales(date, List<SellModel>)
LocalService.getTodaySales(date) → List<SellModel>
LocalService.savePendingTransfers(List<GoDownStockTransferToShopModel>)
LocalService.getPendingTransfers() → List<GoDownStockTransferToShopModel>
LocalService.clearAllCache()
```

---

## 9. Navigation & Routing

**Files:** `lib/routes/routes.dart`, `lib/routes/route_name.dart`  
**Initial Route:** `/splash`

Key routes:
| Route Name | View | Binding |
|---|---|---|
| `/splash` | `SplashView` | `SplashBindings` |
| `/login` | `LoginView` | `LoginBinding` |
| `/signup` | `SignupView` | `SignupBinding` |
| `/bottomNavigation` | `BottomNavigation` | `BottomNavigationBinding` |
| `/home` | `HomeView` | `HomeBinding` |
| `/inventoryView` | `InventoryView` | `InventoryBinding` |
| `/sell` | `SellView` | `SellBinding` |
| `/reports` | `ReportView` | `ReportBinding` |
| `/setting` | `SettingView` | `SettingBinding` |
| `/userProfile` | `UserProfileView` | `UserProfileBindings` |
| `/productView` | `ProductView` | `ProductBinding` |
| `/productDetailView` | `ProductDetailView` | `ProductDetailsBinding` |
| `/invoicePrintView` | `InvoiceView` | `InvoiceBinding` |
| `/barcodePrintView` | `BarcodeView` | `BarcodeBinding` |
| `/stockTransfer` | `NotificationView` | `NotificationBinding` |
| `/outOfStock` | `OutOfStockView` | `OutOfStockBinding` |
| `/nearExpiry` | `NearExpiryProductView` | `NearExpiryProductBinding` |
| `/revenue` | `RevenueView` | `RevenueBinding` |
| `/expense` | `ExpenseView` | `ExpenseBinding` |
| `/discount` | `DiscountView` | `DiscountBinding` |
| `/category` | `CategoryView` | `CategoryBinding` |
| `/bankDetails` | `BankDetailsView` | `BankDetailsBinding` |
| `/addUser` | `AddUserView` | `AddUserBinding` |
| `/allUsers` | `AllUserView` | `AllUserBindings` |
| `/userRole` | `UserRoleView` | `UserRoleBinding` |
| `/orderView` | `OrderView` | `OrderBinding` |
| `/creditAmount` | (credit view) | `CreditBinding` |

---

## 10. Key Dependencies

| Package | Version | Purpose |
|---|---|---|
| `get` | ^4.7.2 | State management, routing, DI |
| `get_storage` | ^2.1.1 | Key-value persistent storage |
| `supabase_flutter` | ^2.12.0 | Supabase client + realtime |
| `hive` / `hive_flutter` | ^2.2.3 / ^1.1.0 | Local offline database |
| `http` | ^1.2.0 | REST API HTTP client |
| `firebase_core` | ^4.2.0 | Firebase initialization |
| `firebase_messaging` | ^16.1.0 | Push notifications |
| `firebase_auth` | ^6.1.1 | Firebase auth (secondary) |
| `cloud_firestore` | ^6.0.3 | Firestore (optional use) |
| `flutter_dotenv` | ^5.1.0 | Environment variables |
| `flutter_screenutil` | ^5.9.3 | Responsive sizing |
| `mobile_scanner` | ^7.0.1 | Barcode/QR scanning |
| `flutter_blue_plus` | ^2.0.0 | Bluetooth connectivity |
| `flutter_bluetooth_printer` | ^2.20.0 | Bluetooth thermal printing |
| `esc_pos_utils_plus` | ^2.0.4 | ESC/POS printer commands |
| `barcode_widget` | ^2.0.4 | Barcode display widget |
| `pdf` | ^3.11.3 | PDF generation |
| `excel` | ^4.0.6 | Excel export |
| `fl_chart` | ^1.0.0 | Charts and graphs |
| `intl` | ^0.20.2 | Date/number formatting |
| `connectivity_plus` | ^7.0.0 | Network connectivity check |
| `image_picker` | ^1.2.1 | Profile image selection |
| `permission_handler` | ^12.0.1 | Runtime permissions |
| `share_plus` | ^12.0.1 | Share files/content |
| `open_file` | ^3.5.10 | Open downloaded files |
| `audioplayers` | ^6.5.1 | Beep sound on scan |
| `flutter_local_notifications` | ^19.4.0 | Local notification display |
| `pinput` | ^6.0.2 | OTP PIN input widget |
| `upgrader` | ^11.3.1 | In-app update prompts |
| `upi_payment_qrcode_generator` | ^1.6.0 | UPI QR code generation |
| `google_fonts` | ^7.1.0 | Custom fonts |
| `animated_custom_dropdown` | 3.1.1 | Dropdown widget |
| `url_launcher` | ^6.3.2 | Open URLs |
| `device_info_plus` | ^12.3.0 | Device information |
| `path_provider` | ^2.1.5 | File system paths |

---

## 11. Services

### Push Notification Service (`lib/module/push_notification/local_notification_service.dart`)
- Handles Firebase background + foreground messages
- Routes payloads by `topic` field
- Displays local notifications via `flutter_local_notifications`

### Storage Service (`lib/supabase_db/storage_service.dart`)
- Uploads profile images to Supabase Storage
- Returns public URL with cache-busting timestamp

### Error Handler (`lib/supabase_db/supabase_error_handler.dart`)
- Maps Supabase/auth/network errors to user-friendly messages
- Used by GlobalStore and controllers

### Logger (`lib/helper/logger.dart`)
- Structured logging: `AppLogger.info()`, `AppLogger.error()`
- Should replace all raw `print()` calls

### Bluetooth (`lib/bluetooth/bluetooth.dart`)
- Manages Bluetooth printer connection
- Sends ESC/POS formatted receipts

---

## 12. Data Flow Summary

```
View (UI)
  ↓ user action
Controller (GetxController)
  ├─ updates loading Rx state
  ├─ calls Repo method
  └─ updates data Rx state → UI rebuilds
  ↓
Repository
  ├─ calls Networking.getData/postData (REST)
  │   └─ attaches Bearer token from CacheManager
  └─ OR calls SupabaseConfig.client.from(table) (Supabase)
  ↓
Response
  └─ parsed into Model via fromJson()
  ↓
Controller
  ├─ saves to Hive (offline cache) if needed
  └─ saves to GetStorage (session) if needed

GlobalStore (permanent)
  ├─ owns shared data (products, sales, loose)
  ├─ syncs with Supabase Realtime on changes
  └─ loads from Hive on cold start (offline-first)
```

---

## 13. Audit Findings

### Strengths
- Clean MVC + Repository separation across all 33 modules
- Offline-first: Hive loads data before network, Supabase syncs after
- Realtime sync with optimistic updates for sales
- Centralized error handling via `SupabaseErrorHandler`
- User-scoped data with Row-Level Security on Supabase
- Modular feature structure makes adding new modules straightforward

### Issues Found
| Severity | Issue | Location |
|---|---|---|
| ⚠️ Medium | `print()` statements in production code | `main.dart`, various controllers |
| ⚠️ Medium | Token stored in plain GetStorage (not encrypted) | `cache_manager/cache_manager.dart` |
| ⚠️ Medium | `notification` module is empty (placeholder) | `lib/module/notification/` |
| ⚠️ Low | `isDashBoardOverView.value = true` set in `finally` even on success path (should be `false`) | `report_controller.dart` |
| ⚠️ Low | `resolveUserId()` in SupabaseConfig always returns empty string | `supabase_client.dart` |
| ⚠️ Low | Some controllers have unused imports | Various |
| ℹ️ Info | `.env` file is in assets — ensure it's in `.gitignore` | `.gitignore` |
| ℹ️ Info | `cloud_firestore` dependency present but usage is minimal | `pubspec.yaml` |

### Recommendations
1. Replace all `print()` with `AppLogger.info/error()`
2. Use `flutter_secure_storage` for token storage instead of GetStorage
3. Fix `isDashBoardOverView` loading flag logic in `ReportController`
4. Fix `resolveUserId()` in `SupabaseConfig` — it always returns empty string
5. Remove or implement the empty `notification` module
6. Consider removing `cloud_firestore` if not actively used (reduces app size)
7. Add `http_parser` explicitly to `pubspec.yaml` (used in `networking.dart` for multipart)

---

## 14. Environment Variables Required (`.env`)

```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

> Never commit `.env` to version control. Verify it's in `.gitignore`.
