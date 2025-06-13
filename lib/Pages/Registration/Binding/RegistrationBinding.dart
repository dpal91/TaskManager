import 'package:get/get.dart';
import 'package:task_manager/Pages/Registration/Controller/RegistrationController.dart';

class RegistrationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RegistrationController());
  }
}
