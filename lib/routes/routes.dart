import 'package:get/get.dart';
import 'package:inventory/module/invoice/binding/invoice_binding.dart';
import 'package:inventory/module/invoice/view/barcode.dart';
import 'package:inventory/module/invoice/view/invoice.dart';
import 'package:inventory/module/order_complete/binding/order_binding.dart';
import 'package:inventory/module/order_complete/view/order_view.dart';
import 'package:inventory/module/revenue/view/revenue_detail_view.dart';
import 'package:inventory/module/security/privacy_policy.dart';
import 'package:inventory/module/security/term_and_condition.dart';
import 'package:inventory/product_details/binding/product_details_binding.dart';
import 'package:inventory/product_details/view/product_detail_view.dart';
import '../module/app_settings/binding/app_setting_binding.dart';
import '../module/app_settings/view/app_setting_view.dart';
import '../module/auth/login/binding/login_binding.dart';
import '../module/auth/login/view/login_view.dart';
import '../module/auth/signup/binding/signup_binding.dart';
import '../module/auth/signup/view/signup_view.dart';
import '../module/auth/splash/binding/splash_bindings.dart';
import '../module/auth/splash/view/splash.dart';
import '../module/category/binding/animal_type_binding.dart';
import '../module/category/binding/category_binding.dart';
import '../module/category/view/animal_category.dart';
import '../module/category/view/category.dart';
import '../module/expense/binding/expense_binding.dart';
import '../module/expense/view/expense.dart';
import '../module/generate_barcode/view/generate_barcode.dart';
import '../module/inventory/binding/inventory_binding.dart';
import '../module/inventory/view/inventory.dart';
import '../module/inventorylist/binding/inventorylist_binding.dart';
import '../module/inventorylist/view/inventroy_list.dart';
import '../module/invoice/binding/barcode_binding.dart';
import '../module/loose_sell/binding/loose_binding.dart';
import '../module/loose_sell/view/loose_sell.dart';
import '../module/out_of_stock/binding/out_of_stock_binding.dart';
import '../module/out_of_stock/view/out_of_stock_view.dart';
import '../module/reports/binding/report_binding.dart';
import '../module/reports/view/report.dart';
import '../module/revenue/binding/revenue_binding.dart';
import '../module/revenue/view/revenue_view.dart';
import '../module/sell/binding/sell_binding.dart';
import '../module/sell/view/sell.dart';
import '../module/sell/view/sell_list_After_scan.dart';
import '../module/setting/binding/setting_binding.dart';
import '../module/setting/view/setting.dart';
import '../module/unknown/view/nointernate_connection.dart';
import '../module/user_profile/binding/user_profile_bindings.dart';
import '../product_details/binding/product_binding.dart';
import '../product_details/view/product_view.dart';
import '../module/bottom_navigation/binding/bottom_navigation_binding.dart';
import '../module/bottom_navigation/view/bottom_navigation.dart';
import '../module/discount/binding/discount_binding.dart';
import '../module/discount/view/discount.dart';
import '../module/generate_barcode/binding/generate_barcode_binding.dart';
import '../module/home/binding/home_binding.dart';
import '../module/home/view/home.dart';
import '../module/loose_category/binding/loose_category_binding.dart';
import '../module/loose_category/view/loose_category.dart';
import '../module/sell/binding/sell_list_after_scan_binding.dart';
import '../module/unknown/view/unknown_route.dart';
import '../module/user_profile/view/user_profile_view.dart';
import 'route_name.dart';

class AppRoutes {
  static final String initialRoute = AppRouteName.splash;
  static List<GetPage> getPage = [
    GetPage(
      name: AppRouteName.splash,
      page: () => SplashView(),
      binding: SplashBindings(),
    ),
    GetPage(name: AppRouteName.unknwonroute, page: () => UnknownRoute()),
    GetPage(name: AppRouteName.privacypolicy, page: () => PrivacyPolicy()),
    GetPage(name: AppRouteName.termandcodition, page: () => TermAndCondition()),
    GetPage(
      name: AppRouteName.orderView,
      page: () => OrderView(),
      binding: OrderBinding(),
    ),
    GetPage(
      name: AppRouteName.bottomNavigation,
      page: () => BottomNavigation(),
      binding: BottomNavigationBinding(),
      bindings: [HomeBinding(), SettingBinding(), ReportBinding()],
    ),
    GetPage(name: AppRouteName.home, page: () => HomeView()),
    GetPage(
      name: AppRouteName.inventoryView,
      page: () => InventoryView(),
      binding: InventoryBinding(),
    ),
    GetPage(
      name: AppRouteName.inventoryViewFormSell,
      page: () => InventoryView(),
      binding: InventoryBinding(),
    ),
    GetPage(
      name: AppRouteName.inventroyList,
      page: () => InventroyList(),
      binding: InventorylistBinding(),
    ),
    GetPage(
      name: AppRouteName.sellListAfterScan,
      page: () => SellListAfterScan(),
      binding: SellListAfterScanBinding(),
    ),
    GetPage(
      name: AppRouteName.sell,
      page: () => SellView(),
      binding: SellBinding(),
    ),
    GetPage(
      name: AppRouteName.reports,
      page: () => ReportView(),
      binding: ReportBinding(),
    ),
    GetPage(
      name: AppRouteName.setting,
      page: () => SettingView(),
      binding: SettingBinding(),
    ),
    GetPage(
      name: AppRouteName.login,
      page: () => LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRouteName.userProfile,
      page: () => UserProfileView(),
      binding: UserProfileBindings(),
    ),
    GetPage(
      name: AppRouteName.productView,
      page: () => ProductView(),
      binding: ProductBinding(),
    ),
    GetPage(
      name: AppRouteName.signup,
      page: () => SignupView(),
      binding: SignupBinding(),
    ),
    GetPage(
      name: AppRouteName.expense,
      page: () => Expense(),
      binding: ExpenseBinding(),
    ),
    GetPage(
      name: AppRouteName.invoicePrintView,
      page: () => InvoicePrint(),
      binding: InvoiceBinding(),
    ),
    GetPage(
      name: AppRouteName.barcodePrintView,
      page: () => BarcodeView(),
      binding: BarcodeBinding(),
    ),
    GetPage(
      name: AppRouteName.nointernateConnection,
      page: () => NointernateConnection(),
    ),
    GetPage(
      name: AppRouteName.discount,
      page: () => Discount(),
      binding: DiscountBinding(),
    ),
    GetPage(
      name: AppRouteName.category,
      page: () => Category(),
      binding: CategoryBinding(),
    ),
    GetPage(
      name: AppRouteName.animalCategory,
      page: () => AnimalCategory(),
      binding: AnimalTypeBinding(),
    ),
    GetPage(
      name: AppRouteName.looseSell,
      page: () => LooseSell(),
      binding: LooseBinding(),
    ),
    GetPage(
      name: AppRouteName.revenueView,
      page: () => RevenueView(),
      binding: RevenueBinding(),
    ),
    GetPage(
      name: AppRouteName.revenueView,
      page: () => RevenueView(),
      binding: RevenueBinding(),
    ),
    GetPage(
      name: AppRouteName.revenueDetailView,
      page: () => RevenueDetailView(),
      //binding: RevenueBinding(),
    ),
    GetPage(
      name: AppRouteName.looseCategory,
      page: () => LooseCategory(),
      binding: LooseCategoryBinding(),
    ),
    GetPage(
      name: AppRouteName.appsetting,
      page: () => AppSettingView(),
      binding: AppSettingBinding(),
    ),
    GetPage(
      name: AppRouteName.outOfStock,
      page: () => OutOfStockView(),
      binding: OutOfStockBinding(),
    ),
    GetPage(
      name: AppRouteName.generateBarcode,
      page: () => GenerateBarcode(),
      binding: GenerateBarcodeBinding(),
    ),
    GetPage(
      name: AppRouteName.productDetailView,
      page: () => ProductDetailView(),
      binding: ProductDetailsBinding(),
    ),
  ];

  static Future<dynamic> futureNavigationToRoute({
    required String routeName,
    dynamic data,
  }) async {
    return await Get.toNamed(routeName, arguments: data);
  }

  static void navigateRoutes({required String routeName, dynamic data}) {
    switch (routeName) {
      case AppRouteName.sell:
        Get.toNamed(AppRouteName.sell, arguments: data);
        break;
      case AppRouteName.inventoryView:
        Get.toNamed(AppRouteName.inventoryView, arguments: data);
        break;
      case AppRouteName.invoicePrintView:
        Get.toNamed(AppRouteName.invoicePrintView, arguments: data);
        break;
      case AppRouteName.inventoryViewFormSell:
        Get.offNamed(AppRouteName.inventoryViewFormSell, arguments: data);
        break;
      case AppRouteName.bottomNavigation:
        Get.offAllNamed(AppRouteName.bottomNavigation, arguments: data);
        break;
      case AppRouteName.barcodePrintView:
        Get.toNamed(AppRouteName.barcodePrintView, arguments: data);
        break;
      case AppRouteName.splash:
        Get.toNamed(AppRouteName.splash, arguments: data);
        break;
      case AppRouteName.inventroyList:
        Get.toNamed(AppRouteName.inventroyList, arguments: data);
        break;
      case AppRouteName.reports:
        Get.toNamed(AppRouteName.reports, arguments: data);
        break;
      case AppRouteName.productView:
        Get.toNamed(AppRouteName.productView, arguments: data);
        break;
      case AppRouteName.login:
        Get.offAllNamed(AppRouteName.login, arguments: data);
        break;
      case AppRouteName.sellListAfterScan:
        Get.offNamed(AppRouteName.sellListAfterScan, arguments: data);
        break;
      case AppRouteName.signup:
        Get.toNamed(AppRouteName.signup, arguments: data);
        break;
      case AppRouteName.nointernateConnection:
        Get.toNamed(AppRouteName.nointernateConnection, arguments: data);
        break;
      case AppRouteName.expense:
        Get.toNamed(AppRouteName.expense, arguments: data);
        break;
      case AppRouteName.discount:
        Get.toNamed(AppRouteName.discount, arguments: data);
        break;
      case AppRouteName.category:
        Get.toNamed(AppRouteName.category, arguments: data);
        break;
      case AppRouteName.animalCategory:
        Get.toNamed(AppRouteName.animalCategory, arguments: data);
      case AppRouteName.looseSell:
        Get.toNamed(AppRouteName.looseSell, arguments: data);
        break;
      case AppRouteName.revenueView:
        Get.toNamed(AppRouteName.revenueView, arguments: data);
        break;
      case AppRouteName.looseCategory:
        Get.toNamed(AppRouteName.looseCategory, arguments: data);
        break;
      case AppRouteName.appsetting:
        Get.toNamed(AppRouteName.appsetting, arguments: data);
        break;
      case AppRouteName.outOfStock:
        Get.toNamed(AppRouteName.outOfStock, arguments: data);
      case AppRouteName.generateBarcode:
        Get.toNamed(AppRouteName.generateBarcode, arguments: data);
        break;
      case AppRouteName.privacypolicy:
        Get.toNamed(AppRouteName.privacypolicy, arguments: data);
        break;
      case AppRouteName.termandcodition:
        Get.toNamed(AppRouteName.termandcodition, arguments: data);
        break;
      case AppRouteName.userProfile:
        Get.toNamed(AppRouteName.userProfile, arguments: data);
        break;
      case AppRouteName.productDetailView:
        Get.toNamed(AppRouteName.productDetailView, arguments: data);
        break;
      case AppRouteName.revenueDetailView:
        Get.toNamed(AppRouteName.revenueDetailView, arguments: data);
        break;
      case AppRouteName.orderView:
        Get.offAllNamed(AppRouteName.orderView, arguments: data);
        break;
      default:
        Get.toNamed(AppRouteName.unknwonroute);
    }
  }
}
