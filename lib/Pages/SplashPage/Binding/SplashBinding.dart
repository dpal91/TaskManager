import 'package:get/get.dart';
import 'package:task_manager/Pages/SplashPage/Controller/SplashController.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SplashController());
  }
}
