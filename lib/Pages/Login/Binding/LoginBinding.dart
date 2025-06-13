import 'package:get/get.dart';
import 'package:task_manager/Pages/Login/Controller/LoginController.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController());
  }
}
