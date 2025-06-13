import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_manager/Consts/ApplicationRoutes.dart';
import 'package:task_manager/Pages/Login/Controller/LoginController.dart';

class LoginPage extends GetWidget<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                const Text(
                  'Welcome Back!',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: controller.emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    prefixIcon: Icon(Icons.email),
                    error: controller.emailHasError.value
                        ? Text(
                            controller.emailError.value,
                            style: TextStyle(color: Colors.red),
                          )
                        : null,
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: controller.passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    prefixIcon: Icon(Icons.lock),
                    error: controller.passHasError.value
                        ? Text(
                            controller.passError.value,
                            style: TextStyle(color: Colors.red),
                          )
                        : null,
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    controller.login();
                  },
                  child: const Text('Login'),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Get.toNamed(ApplicationRoutes.Registration);
                  },
                  child: const Text("Don't have an account? Register here"),
                ),
              ],
            )),
      ),
    );
  }
}
