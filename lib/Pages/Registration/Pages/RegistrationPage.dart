import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_manager/Pages/Registration/Controller/RegistrationController.dart';

class RegistrationPage extends GetWidget<RegistrationController> {
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Obx(() => Form(
              // key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Registration',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: controller.nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      prefixIcon: Icon(Icons.person),
                      error: controller.nameHasError.value
                          ? Text(
                              controller.nameError.value,
                              style: TextStyle(color: Colors.red),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
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
                  TextFormField(
                    controller: controller.mobileController,
                    decoration: InputDecoration(
                      labelText: 'Mobile Number',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      prefixIcon: Icon(Icons.phone),
                      error: controller.mobHasError.value
                          ? Text(
                              controller.mobError.value,
                              style: TextStyle(color: Colors.red),
                            )
                          : null,
                    ),
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
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
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: controller.confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      prefixIcon: Icon(Icons.lock_outline),
                      error: controller.cPassHasError.value
                          ? Text(
                              controller.cPassError.value,
                              style: TextStyle(color: Colors.red),
                            )
                          : null,
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      controller.registerUser();
                    },
                    child: const Text('Register'),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
