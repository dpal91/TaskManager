import 'dart:async';

import 'package:get/get.dart';
import 'package:task_manager/Consts/ApplicationRoutes.dart';


class SplashController extends GetxController{
  SplashController(){
    Timer(const Duration(seconds: 3), () {
      Get.offAndToNamed(ApplicationRoutes.Login);
    });
  }
}