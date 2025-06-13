import 'package:get/get.dart';
import 'package:task_manager/Pages/HomePage/Binding/HomeBinding.dart';
import 'package:task_manager/Pages/HomePage/Pages/HomePage.dart';
import 'package:task_manager/Pages/Login/Binding/LoginBinding.dart';
import 'package:task_manager/Pages/Login/Pages/LoginPage.dart';
import 'package:task_manager/Pages/Registration/Binding/RegistrationBinding.dart';
import 'package:task_manager/Pages/Registration/Pages/RegistrationPage.dart';
import 'package:task_manager/Pages/SplashPage/Binding/SplashBinding.dart';
import 'package:task_manager/Pages/SplashPage/Pages/SplashPage.dart';

class ApplicationRoutes {
  static const String Splash = "/";
  static const String Home = "/home";
  static const String Login = "/login";
  static const String Registration = "/registration";

  static List<GetPage<dynamic>> pages = [
    GetPage(name: Splash, page: () => Splashpage(), transition: Transition.rightToLeft, binding: SplashBinding()),
    GetPage(name: Login, page: () => LoginPage(), transition: Transition.rightToLeft, binding: LoginBinding()),
    GetPage(name: Registration, page: () => RegistrationPage(), transition: Transition.rightToLeft, binding: RegistrationBinding()),
    GetPage(name: Home, page: () => HomePage(), transition: Transition.rightToLeft, binding: HomeBinding()),
  ];
}
