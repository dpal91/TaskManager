import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:task_manager/Consts/ApplicationRoutes.dart';
import 'package:task_manager/Consts/Constants.dart';
import 'package:task_manager/Pages/HomePage/Model/TaskModel.dart';

class HomeController extends GetxController {
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  Rx<DateTime?> selectedDate = Rxn<DateTime>();
  Rx<TimeOfDay?> selectedTime = Rxn<TimeOfDay>();

  var titleHasError = false.obs;
  var descHasError = false.obs;
  var dateHasError = false.obs;
  var timeHasError = false.obs;
  var titleError = "".obs;
  var descError = "".obs;
  var dateError = "".obs;
  var timeError = "".obs;

  DateTime parseCustomDate(String dateStr) {
    final parts = dateStr.split(' ');
    if (parts.length != 3) throw FormatException('Invalid date format');

    final day = int.parse(parts[0]);
    final month = _monthNameToNumber(parts[1]);
    final year = int.parse(parts[2]);

    return DateTime(year, month, day);
  }

  int _monthNameToNumber(String name) {
    const months = {
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'May': 5,
      'Jun': 6,
      'Jul': 7,
      'Aug': 8,
      'Sep': 9,
      'Oct': 10,
      'Nov': 11,
      'Dec': 12,
    };

    return months[name]!;
  }

  void addOrUpdateTask(Task? task) {
    if (validate()) {
      DateTime? finalDateTime;
      if (selectedDate.value != null && selectedTime.value != null) {
        finalDateTime = DateTime(
          selectedDate.value!.year,
          selectedDate.value!.month,
          selectedDate.value!.day,
          selectedTime.value!.hour,
          selectedTime.value!.minute,
        );
      }
      Task newTask = Task(title: titleController.text.trim(), description: descController.text.trim(), dateTime: finalDateTime);
      if (task == null) {
        //save new data
        try {
          // print(newTask.toMap());
          EasyLoading.show(status: "Please wait", maskType: EasyLoadingMaskType.black);
          FirebaseFirestore.instance.collection(Constants.userID).add(newTask.toMap()).then(
            (value) {
              print("success ${value.id}");
            },
          ).catchError((error) {
            Get.snackbar("Error!", "Some error occurred.",
                snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
          });
          EasyLoading.dismiss();
          Get.back(closeOverlays: true);
          Get.snackbar("Success!", "Data Saved Successfully..",
              snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
        } on Exception catch (e) {
          EasyLoading.dismiss();
          Get.snackbar("Error!", "Some error occurred.",
              snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
        }
      } else {
        //update

        try {
          EasyLoading.show(status: "Please wait", maskType: EasyLoadingMaskType.black);
          FirebaseFirestore.instance.collection(Constants.userID).doc(task.docId).update(newTask.toMap()).catchError((error) {
            Get.snackbar("Error!", "Some error occurred.",
                snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
          });
          EasyLoading.dismiss();
          Get.back(closeOverlays: true);
          Get.snackbar("Updated Successfully!", "Data Updated Successfully..",
              snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
        } on Exception catch (e) {
          EasyLoading.dismiss();
          Get.snackbar("Error!", "Some error occurred.",
              snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
        }
      }
    }
  }

  validate() {
    FocusManager.instance.primaryFocus?.unfocus();
    bool hasError = false;
    clearErrors();
    if (titleController.text.trim() == "") {
      hasError = true;
      titleHasError.value = true;
      titleError.value = "Please enter a title";
    }
    if (descController.text.trim() == "") {
      hasError = true;
      descHasError.value = true;
      descError.value = "Please enter a Description";
    }
    if (selectedDate.value != null || selectedTime.value != null) {
      if (selectedTime.value == null) {
        hasError = true;
        timeHasError.value = true;
        timeError.value = "Please select time";
      }
      if (selectedDate.value == null) {
        hasError = true;
        dateHasError.value = true;
        dateError.value = "Please select date";
      }
    }
    return !hasError;
  }

  void clearErrors() {
    titleHasError.value = descHasError.value = dateHasError.value = timeHasError.value = false;
    titleError.value = descError.value = dateError.value = timeError.value = "";
  }

  void deleteTask(Task task) {
    try {
      EasyLoading.show(status: "Please wait", maskType: EasyLoadingMaskType.black);
      FirebaseFirestore.instance.collection(Constants.userID).doc(task.docId).delete().catchError((error) {
        Get.snackbar("Error!", "Some error occurred.",
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      });
      EasyLoading.dismiss();
      Get.back(closeOverlays: true);
      Get.snackbar("Success!", "Task Deleted Successfully..",
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
    } on Exception catch (e) {
      EasyLoading.dismiss();
      Get.snackbar("Error!", "Some error occurred.",
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  logout() {
    try {
      EasyLoading.show(status: "Please wait", maskType: EasyLoadingMaskType.black);
      FirebaseAuth.instance.signOut();
      EasyLoading.dismiss();
      Get.offAndToNamed(ApplicationRoutes.Login);
    } catch (_) {
      EasyLoading.dismiss();
      Get.snackbar("Error!", "Unable to Logout", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
