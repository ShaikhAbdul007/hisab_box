import 'package:get_storage/get_storage.dart';
import 'package:inventory/module/bank_details/model/bank_model.dart';
import 'package:inventory/module/category/model/category_model.dart';
import 'package:inventory/module/inventory/model/product_model.dart';
import 'package:inventory/module/setting/model/user_model.dart';

import '../module/loose_sell/model/loose_model.dart' show LooseInvetoryModel;

mixin class CacheManager {
  final box = GetStorage();

  //--------------------Save all the value------------------------------------------------------------------------------

  void saveUserLoggedIn(bool value) {
    box.write(Key.userLoginIn.toString(), value);
  }

  void savebillNo(int billNo) {
    box.write(Key.billNo.toString(), billNo);
  }

  void saveUserData(InventoryUserModel userModels) {
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

  void saveCategoryModel(List<CategoryModel> category) {
    final storeList = category.map((e) => e.toJson()).toList();
    box.write(Key.categoryValue.toString(), storeList);
  }

  void saveAnimalCategoryModel(List<CategoryModel> category) {
    final storeList = category.map((e) => e.toJson()).toList();
    box.write(Key.animalCategoryValue.toString(), storeList);
  }

  void saveProductList(List<ProductModel> product) {
    final productList = product.map((e) => e.toJson()).toList();
    box.write(Key.product.toString(), productList);
  }

  void saveLoosedProductList(List<LooseInvetoryModel> loosedProduct) {
    final loosedProductList = loosedProduct.map((e) => e.toJson()).toList();
    box.write(Key.looseInvetoryKey.toString(), loosedProductList);
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

  InventoryUserModel retrieveUserDetail() {
    final user = box.read(Key.userModels.toString());
    if (user != null) {
      return InventoryUserModel.fromJson(user);
    }
    return InventoryUserModel();
  }

  BankModel retrieveBankModelDetail() {
    final bank = box.read(Key.bankModels.toString());
    if (bank != null) {
      return BankModel.formJson(bank);
    }
    return BankModel();
  }

  Future<List<CategoryModel>> retrieveCategoryModel() async {
    final storedList = box.read(Key.categoryValue.toString());
    if (storedList != null && storedList is List) {
      return storedList.map((e) => CategoryModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<CategoryModel>> retrieveAnimalCategoryModel() async {
    final storedList = box.read(Key.animalCategoryValue.toString());
    if (storedList != null && storedList is List) {
      return storedList.map((e) => CategoryModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<ProductModel>> retrieveProductList() async {
    final productList = box.read(Key.product.toString());
    if (productList != null && productList is List) {
      return productList.map((e) => ProductModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<LooseInvetoryModel>> retrieveLoosedProductList() async {
    final loosedProductList = box.read(Key.looseInvetoryKey.toString());
    if (loosedProductList != null && loosedProductList is List) {
      return loosedProductList
          .map((e) => LooseInvetoryModel.fromJson(e))
          .toList();
    }
    return [];
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
}

enum Key {
  cacheModel,
  cacheEmployeeModel,
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
}
