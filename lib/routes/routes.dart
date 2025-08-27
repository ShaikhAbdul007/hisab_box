import 'package:get/get.dart';
import 'package:inventory/module/app_settings/binding/app_setting_binding.dart';
import 'package:inventory/module/app_settings/view/app_setting_view.dart';
import 'package:inventory/module/auth/login/binding/login_binding.dart';
import 'package:inventory/module/auth/login/view/login_view.dart';
import 'package:inventory/module/auth/signup/binding/signup_binding.dart';
import 'package:inventory/module/auth/signup/view/signup_view.dart';
import 'package:inventory/module/auth/splash/binding/splash_bindings.dart';
import 'package:inventory/module/auth/splash/view/splash.dart';
import 'package:inventory/module/category/binding/animal_type_binding.dart';
import 'package:inventory/module/category/binding/category_binding.dart';
import 'package:inventory/module/category/view/animal_category.dart';
import 'package:inventory/module/category/view/category.dart';
import 'package:inventory/module/expense/binding/expense_binding.dart';
import 'package:inventory/module/expense/view/expense.dart';
import 'package:inventory/module/inventory/binding/inventory_binding.dart';
import 'package:inventory/module/inventory/view/inventory.dart';
import 'package:inventory/module/inventorylist/binding/inventorylist_binding.dart';
import 'package:inventory/module/inventorylist/view/inventroy_list.dart';
import 'package:inventory/module/loose_sell/binding/loose_binding.dart';
import 'package:inventory/module/loose_sell/view/loose_sell.dart';
import 'package:inventory/module/out_of_stock/binding/out_of_stock_binding.dart';
import 'package:inventory/module/out_of_stock/view/out_of_stock_view.dart';
import 'package:inventory/module/reports/binding/report_binding.dart';
import 'package:inventory/module/reports/view/report.dart';
import 'package:inventory/module/revenue/binding/revenue_binding.dart';
import 'package:inventory/module/revenue/view/revenue_view.dart';
import 'package:inventory/module/sell/binding/sell_binding.dart';
import 'package:inventory/module/sell/view/sell.dart';
import 'package:inventory/module/sell/view/sell_list_After_scan.dart';
import 'package:inventory/module/setting/binding/setting_binding.dart';
import 'package:inventory/module/setting/view/setting.dart';
import 'package:inventory/module/unknown/view/nointernate_connection.dart';
import '../module/bottom_navigation/binding/bottom_navigation_binding.dart';
import '../module/bottom_navigation/view/bottom_navigation.dart';
import '../module/discount/binding/discount_binding.dart';
import '../module/discount/view/discount.dart';
import '../module/home/binding/home_binding.dart';
import '../module/home/view/home.dart';
import '../module/loose_category/binding/loose_category_binding.dart';
import '../module/loose_category/view/loose_category.dart';
import '../module/sell/binding/sell_list_after_scan_binding.dart';
import '../module/unknown/view/unknown_route.dart';

class AppRoutes {
  static final String initialRoute = AppRouteName.splash;
  static List<GetPage> getPage = [
    GetPage(
      name: AppRouteName.splash,
      page: () => SplashView(),
      binding: SplashBindings(),
    ),
    GetPage(name: AppRouteName.unknwonroute, page: () => UnknownRoute()),
    GetPage(
      name: AppRouteName.bottomNavigation,
      page: () => BottomNavigation(),
      binding: BottomNavigationBinding(),
      bindings: [HomeBinding(), SettingBinding()],
    ),
    GetPage(name: AppRouteName.home, page: () => HomeView()),
    GetPage(
      name: AppRouteName.inventoryView,
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
  ];

  static Future<dynamic> futureNavigationToRoute({
    required String routeName,
    dynamic data,
  }) async {
    return await Get.toNamed(routeName, arguments: data);
  }

  static navigateRoutes({required String routeName, dynamic data}) {
    switch (routeName) {
      case AppRouteName.sell:
        Get.toNamed(AppRouteName.sell, arguments: data);
        break;
      case AppRouteName.inventoryView:
        Get.toNamed(AppRouteName.inventoryView, arguments: data);
        break;
      case AppRouteName.bottomNavigation:
        Get.offAllNamed(AppRouteName.bottomNavigation, arguments: data);
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
        break;
      default:
        Get.toNamed(AppRouteName.unknwonroute);
    }
  }
}

class AppRouteName {
  static const String bottomNavigation = '/bottomNavigation';
  static const String inventoryView = '/inventoryView';
  static const String home = '/home';
  static const String setting = '/setting';
  static const String inventroyList = '/inventroyList';
  static const String reports = '/reports';
  static const String sell = '/sell';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String splash = '/splash';
  static const String unknwonroute = '/unknwonroute';
  static const String sellListAfterScan = '/sellListAfterScan';
  static const String nointernateConnection = '/nointernateConnection';
  static const String expense = '/expense';
  static const String discount = '/discount';
  static const String category = '/category';
  static const String animalCategory = '/animalCategory';
  static const String looseSell = '/looseSell';
  static const String revenueView = '/revenueView';
  static const String looseCategory = '/looseCategory';
  static const String appsetting = '/appsetting';
  static const String outOfStock = '/outOfStock';
}
