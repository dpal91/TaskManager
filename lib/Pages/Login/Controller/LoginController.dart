import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:task_manager/Consts/ApplicationRoutes.dart';
import 'package:task_manager/Consts/Constants.dart';

class LoginController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  var emailError = "".obs;
  var passError = "".obs;
  var emailHasError = false.obs;
  var passHasError = false.obs;

  validate() {
    FocusManager.instance.primaryFocus?.unfocus();
    emailError.value = passError.value = "";
    emailHasError.value = passHasError.value = false;
    bool hasError = false;

    if (emailController.text.trim().isEmpty) {
      hasError = true;
      emailHasError.value = true;
      emailError.value = "Please enter email ID";
    }
    if (!emailController.text.trim().contains("@")) {
      hasError = true;
      emailHasError.value = true;
      emailError.value = "Please enter a valid email ID";
    }
    if (!emailController.text.trim().contains(".")) {
      hasError = true;
      emailHasError.value = true;
      emailError.value = "Please enter a valid email ID";
    }
    if (passwordController.text.trim().isEmpty) {
      hasError = true;
      passHasError.value = true;
      passError.value = "Please enter your password";
    }
    if (passwordController.text.trim().length < 6) {
      hasError = true;
      passHasError.value = true;
      passError.value = "Password Length should be minimum of 6 character";
    }
    return !hasError;
  }

  void login() async {
    if (validate()) {
      try {
        EasyLoading.show(status: "Please wait", maskType: EasyLoadingMaskType.black);
        var loginInstance = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: emailController.text.trim(), password: passwordController.text.trim());
        Constants.userEmail = loginInstance.user?.email ?? "";
        Constants.userID = loginInstance.user?.uid ?? "";
        EasyLoading.dismiss();
        if (Constants.userID == "") {
          Get.snackbar("Error!", "Something Went wrong!\nPlease try again later",
              snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
        } else {
          Get.offAndToNamed(ApplicationRoutes.Home);
        }
      } on FirebaseAuthException catch (e) {
        EasyLoading.dismiss();
        Get.snackbar("Invalid Credentials!", "Please check your UsedID or Password",
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      }
    }
  }
}
