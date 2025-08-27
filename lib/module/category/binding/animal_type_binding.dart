import 'package:get/get.dart';

import '../controller/animaltype_controller.dart';

class AnimalTypeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AnimalTypeController());
  }
}
