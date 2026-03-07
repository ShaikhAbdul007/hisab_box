import 'package:get_storage/get_storage.dart';
import 'package:inventory/module/bank_details/model/bank_model.dart';
import 'package:inventory/module/inventory/model/product_model.dart';
import 'package:inventory/module/order_complete/model/customer_details_model.dart';
import 'package:inventory/module/setting/model/user_model.dart';

mixin class CacheManager {
  final box = GetStorage();

  //--------------------Save all the value------------------------------------------------------------------------------

  void saveUserLoggedIn(bool value) {
    box.write(Key.userLoginIn.toString(), value);
  }

  void savebillNo(int billNo) {
    box.write(Key.billNo.toString(), billNo);
  }

  void saveUserData(UserModel userModels) {
    box.write(Key.userModels.toString(), userModels.toJson());
  }

  void saveBankModelData(BankModel bankModel) {
    box.write(Key.bankModels.toString(), bankModel.toJson());
  }

  void savePrinterAddress(String value) {
    box.write(Key.printerAddress.toString(), value);
  }

  void saveInventoryScanValue(bool value) {
    box.write(Key.inventoryScan.toString(), value);
  }

  void saveCartProductList(List<ProductModel> product) {
    final productList = product.map((e) => e.toJson()).toList();
    box.write(Key.cartProduct.toString(), productList);
  }

  //----------------- checking expire token------------------------------------------------------------------------------

  bool isTokenExpired(int expireInSeconds, DateTime loginTime) {
    DateTime expiryDateTime = loginTime.add(Duration(seconds: expireInSeconds));
    DateTime currentDateTime = DateTime.now();
    return currentDateTime.isAfter(expiryDateTime);
  }

  //----------------- Retrieve all the value------------------------------------------------------------------------------

  String retrieveTenantValue() {
    return box.read(Key.categoryValue.toString());
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
    return UserModel(isSaved: false);
  }

  BankModel retrieveBankModelDetail() {
    final bank = box.read(Key.bankModels.toString());
    if (bank != null) {
      return BankModel.formJson(bank);
    }
    return BankModel();
  }

  Future<List<ProductModel>> retrieveCartProductList() async {
    final productList = box.read(Key.cartProduct.toString());
    if (productList != null && productList is List) {
      return productList.map((e) => ProductModel.fromJson(e)).toList();
    }
    return [];
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
}
