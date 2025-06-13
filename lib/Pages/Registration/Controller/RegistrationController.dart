import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class RegistrationController extends GetxController {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  var nameError = "".obs;
  var emailError = "".obs;
  var mobError = "".obs;
  var passError = "".obs;
  var cPassError = "".obs;

  var nameHasError = false.obs;
  var emailHasError = false.obs;
  var mobHasError = false.obs;
  var passHasError = false.obs;
  var cPassHasError = false.obs;

  validate() {
    FocusManager.instance.primaryFocus?.unfocus();
    nameError.value = emailError.value = mobError.value = passError.value = cPassError.value = "";
    nameHasError.value = emailHasError.value = mobHasError.value = passHasError.value = cPassHasError.value = false;
    bool hasError = false;

    if (nameController.text.trim().isEmpty) {
      hasError = true;
      nameHasError.value = true;
      nameError.value = "Please enter your name";
    }
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
    if (mobileController.text.trim().isEmpty) {
      hasError = true;
      mobHasError.value = true;
      mobError.value = "Please enter mobile number";
    }
    if (mobileController.text.trim().length != 10) {
      hasError = true;
      mobHasError.value = true;
      mobError.value = "Please enter a valid mobile number";
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
    if (confirmPasswordController.text.trim() != passwordController.text.trim()) {
      hasError = true;
      cPassHasError.value = true;
      cPassError.value = "Password does not match";
    }
    if (confirmPasswordController.text.trim().isEmpty) {
      hasError = true;
      cPassHasError.value = true;
      cPassError.value = "Please enter your password again";
    }

    return !hasError;
  }

  void registerUser() async {
    if (validate()) {
      try {
        EasyLoading.show(status: "Please wait", maskType: EasyLoadingMaskType.black);
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: emailController.text.trim(), password: passwordController.text.trim());
        EasyLoading.dismiss();
        if (userCredential != null) {
          Get.back();
          Get.snackbar("Success!", "User Registered Successfully",
              snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
        }
      } on FirebaseAuthException catch (e) {
        EasyLoading.dismiss();
        print(e.toString());

        Get.snackbar(
            "Error!",
            (e.toString().toUpperCase().contains("The email address is badly formatted".toUpperCase()))
                ? "The email address is badly formatted"
                : "User Email ID Already Exists!\nPlease use different Email ID",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    }
  }
}
