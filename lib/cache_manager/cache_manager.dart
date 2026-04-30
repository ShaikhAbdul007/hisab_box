import 'package:get_storage/get_storage.dart';
import 'package:inventory/module/bank_details/model/bank_model.dart';
import 'package:inventory/module/category/model/category_model.dart';
import 'package:inventory/module/inventory/model/product_model.dart';
import 'package:inventory/module/inventorylist/model/inventory_model.dart';
import 'package:inventory/module/order_complete/model/customer_details_model.dart';
import 'package:inventory/module/setting/model/user_model.dart';

mixin class CacheManager {
  final box = GetStorage();

  //--------------------Save all the value------------------------------------------------------------------------------

  void saveUserLoggedIn(bool value) {
    box.write(Key.userLoginIn.toString(), value);
  }

  void saveToken(String token) {
    box.write(Key.tokenKey.toString(), token);
  }

  void savebillNo(int billNo) {
    box.write(Key.billNo.toString(), billNo);
  }

  void saveUserData(UserModel userModels) {
    box.write(Key.userModels.toString(), userModels.toJson());
  }

  void saveBankModelData(BankDetailsModel bankModel) {
    box.write(Key.bankModels.toString(), bankModel.toJson());
  }

  void savePrinterAddress(String value) {
    box.write(Key.printerAddress.toString(), value);
  }

  void saveInventoryScanValue(bool value) {
    box.write(Key.inventoryScan.toString(), value);
  }

  void saveCartProductList(List<InventoryItem> product) {
    final productList = product.map((e) => e.toJson()).toList();
    box.write(Key.cartProduct.toString(), productList);
  }

  void saveCategoryList(List<CategoryModelListData> categories) {
    final categoryList = categories.map((e) => e.toJson()).toList();
    box.write(Key.categoryValue.toString(), categoryList);
  }

  void saveAnimalList(List<CategoryModelListData> categories) {
    final categoryList = categories.map((e) => e.toJson()).toList();
    box.write(Key.animalCategoryValue.toString(), categoryList);
  }

  //----------------- checking expire token------------------------------------------------------------------------------

  bool isTokenExpired(int expireInSeconds, DateTime loginTime) {
    DateTime expiryDateTime = loginTime.add(Duration(seconds: expireInSeconds));
    DateTime currentDateTime = DateTime.now();
    return currentDateTime.isAfter(expiryDateTime);
  }

  //----------------- Retrieve all the value------------------------------------------------------------------------------

  // String retrieveTenantValue() {
  //   return box.read(Key.categoryValue.toString());
  // }

  // Tracking ke liye: Kaun kaam kar raha hai (Staff ki apni ID)
  String get currentUserId {
    final user = retrieveUserDetail();
    return "";
  }

  String? retrieveEmployeeId() {
    return box.read(Key.employeeIdKey.toString());
  }

  String? retrievePrinterAddress() {
    return box.read(Key.printerAddress.toString());
  }

  int retrieveBillNo() {
    box.writeIfNull(Key.billNo.toString(), 0);
    return box.read(Key.billNo.toString());
  }

  Future<bool> retrieveIsLoggedIn() async {
    box.writeIfNull(Key.userLoginIn.toString(), false);
    return box.read(Key.userLoginIn.toString());
  }

  Future<bool> retrieveInventoryScan() async {
    box.writeIfNull(Key.inventoryScan.toString(), false);
    return box.read(Key.inventoryScan.toString());
  }

  UserModel retrieveUserDetail() {
    final user = box.read(Key.userModels.toString());
    if (user != null) {
      return UserModel.fromJson(user);
    }
    return UserModel();
  }

  Future<List<CategoryModelListData>> retrieveCategory() async {
    final category = box.read(Key.categoryValue.toString());
    if (category != null && category is List) {
      return category.map((e) => CategoryModelListData.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<CategoryModelListData>> retrieveAnimalCategory() async {
    final category = box.read(Key.animalCategoryValue.toString());
    if (category != null && category is List) {
      return category.map((e) => CategoryModelListData.fromJson(e)).toList();
    }
    return [];
  }

  String retriveToken() {
    // box.writeIfNull(Key.tokenKey.toString(), '');
    return box.read(Key.tokenKey.toString()) ?? '';
  }

  BankDetailsModel retrieveBankModelDetail() {
    final bank = box.read(Key.bankModels.toString());
    if (bank != null) {
      return BankDetailsModel.fromJson(bank);
    }
    return BankDetailsModel();
  }

  Future<List<InventoryItem>> retrieveCartProductList() async {
    final productList = box.read(Key.cartProduct.toString());
    if (productList != null && productList is List) {
      return productList.map((e) => InventoryItem.fromJson(e)).toList();
    }
    return [];
  }

  String? resolveUserId(bool loadingState) {
    final userId = '';
    if (userId.isEmpty) {
      loadingState = false;
      return null;
    }
    return userId;
  }

  //----------------- Remove all the value------------------------------------------------------------------------------
  void removeCacheModel() {
    box.remove(Key.cacheModel.toString());
  }

  void removePoductModel() {
    box.remove(Key.product.toString());
  }

  void removeGodownProductList() {
    box.remove(Key.godownProduct.toString());
  }

  void removelooseInvetoryKeyModel() {
    box.remove(Key.looseInvetoryKey.toString());
  }

  void removeCartProductList() {
    box.remove(Key.cartProduct.toString());
  }

  void removeResetCacheModel() {
    box.remove(Key.shouldResetCacheModel.toString());
  }

  void removeBox() {
    removeCacheModel();
    box.erase();
  }

  // ================= CUSTOMER CACHE =================

  void saveCustomerList(List<CustomerDetails> customers) {
    final list = customers.map((e) => e.toJson()).toList();
    box.write(Key.customerListKey.toString(), list);
  }

  Future<List<CustomerDetails>> retrieveCustomerList() async {
    final stored = box.read(Key.customerListKey.toString());
    if (stored != null && stored is List) {
      return stored
          .map((e) => CustomerDetails.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }
}

enum Key {
  godownProduct,
  cacheModel,
  todayReportCache,
  todaySellCache,
  cacheEmployeeModel,
  todayRevenueCache,
  categoryValue,
  userLoginIn,
  employeeIdKey,
  animalCategoryValue,
  otherEmployeeNoKey,
  otherEmployeeNameKey,
  shouldResetCacheModel,
  splashVideoValueKey,
  inventoryScan,
  printerAddress,
  billNo,
  userModels,
  bankModels,
  product,
  cartProduct,
  looseInvetoryKey,
  dashboardCache,
  discountCache,
  customerListKey,
  tranferRequestKey,
  tokenKey,
}
