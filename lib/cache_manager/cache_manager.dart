import 'package:get_storage/get_storage.dart';
import 'package:inventory/module/setting/model/user_model.dart';

mixin class CacheManager {
  final box = GetStorage();

  //--------------------Save all the value------------------------------------------------------------------------------

  saveUserLoggedIn(bool value) {
    box.write(Key.userLoginIn.toString(), value);
  }

  savebillNo(int billNo) {
    box.write(Key.billNo.toString(), billNo);
  }

  saveUserData(InventoryUserModel userModels) {
    box.write(Key.userModels.toString(), userModels.toJson());
  }

  savePrinterAddress(String value) {
    box.write(Key.printerAddress.toString(), value);
  }

  saveInventoryScanValue(bool value) {
    box.write(Key.inventoryScan.toString(), value);
  }

  saveTenantName(String value) {
    box.write(Key.tenantValue.toString(), value);
  }

  //----------------- checking expire token------------------------------------------------------------------------------

  bool isTokenExpired(int expireInSeconds, DateTime loginTime) {
    DateTime expiryDateTime = loginTime.add(Duration(seconds: expireInSeconds));
    DateTime currentDateTime = DateTime.now();
    return currentDateTime.isAfter(expiryDateTime);
  }

  //----------------- Retrieve all the value------------------------------------------------------------------------------

  String retrieveTenantValue() {
    return box.read(Key.tenantValue.toString());
  }

  String? retrieveEmployeeId() {
    return box.read(Key.employeeIdKey.toString());
  }

  String? retrievePrinterAddress() {
    return box.read(Key.printerAddress.toString());
  }

  int retrieveBillNo() {
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

  //----------------- Remove all the value------------------------------------------------------------------------------
  removeCacheModel() {
    box.remove(Key.cacheModel.toString());
  }

  removeResetCacheModel() {
    box.remove(Key.shouldResetCacheModel.toString());
  }

  removeBox() {
    removeCacheModel();
    box.erase();
  }
}

enum Key {
  cacheModel,
  cacheEmployeeModel,
  tenantValue,
  userLoginIn,
  employeeIdKey,
  otherEmployeeIdKey,
  otherEmployeeNoKey,
  otherEmployeeNameKey,
  shouldResetCacheModel,
  splashVideoValueKey,
  inventoryScan,
  printerAddress,
  billNo,
  userModels,
}
