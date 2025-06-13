import 'package:get/get.dart';
import 'package:task_manager/Pages/HomePage/Controller/HomeController.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
  }
}
