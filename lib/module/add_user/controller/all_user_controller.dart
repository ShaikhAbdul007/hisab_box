import 'package:get/get.dart';
import 'package:inventory/helper/app_message.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/helper/logger.dart';
import 'package:inventory/module/add_user/model/employee_model.dart';
import 'package:inventory/module/add_user/repo/all_user_view_repo.dart';
import 'package:inventory/supabase_db/supabase_error_handler.dart';

class AllUserController extends GetxController {
  AllUserViewRepo allUserViewRepo = AllUserViewRepo();
  Rx<EmployeeModel> empolyeeModel = EmployeeModel().obs;
  RxBool isLoading = RxBool(false);

  @override
  void onInit() {
    getEmployees();
    super.onInit();
  }

  Future<void> getEmployees() async {
    isLoading.value = true;
    try {
      final response = await allUserViewRepo.getEmployees();
      if (response.success == success) {
        empolyeeModel.value = response;
      } else if (response.success == failed) {
        showSnackBar(error: response.msg ?? somethingWentMessage);
      } else {
        showSnackBar(error: somethingWentMessage);
      }
    } catch (e) {
      AppLogger.info((e).toString());
      showSnackBar(error: e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
