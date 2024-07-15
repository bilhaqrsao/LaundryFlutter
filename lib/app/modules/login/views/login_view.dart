import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_laundry/config/app_asset.dart';
import 'package:new_laundry/config/app_color.dart';
import '../controllers/login_controller.dart';

class LoginView extends StatelessWidget {
  LoginView({Key? key}) : super(key: key);

  final LoginController loginC = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppAsset.bgLogin),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Foreground content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 130),
                  // Username TextField
                  TextField(
                    controller: loginC.usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Password TextField
                  TextField(
                    controller: loginC.passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white70,
                      suffixIcon: Icon(Icons.visibility),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Login Button
                  ElevatedButton(
                    onPressed: () {
                      if (loginC.usernameController.text.trim().isEmpty ||
                          loginC.passwordController.text.trim().isEmpty) {
                        Get.snackbar(
                          'Error',
                          'Username or password cannot be empty',
                          icon: const Icon(Icons.error, color: Colors.red),
                          margin: const EdgeInsets.all(10),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          snackPosition: SnackPosition.TOP,
                        );
                      } else {
                        loginC.login(); // Panggil metode login dari LoginController
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                    ),
                    child: const Text(
                      'LOGIN',
                      style: TextStyle(color: AppColor.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Sign in with text
                  const Text(
                    'Or sign in with',
                    style: TextStyle(color: Colors.blueGrey),
                  ),
                  const SizedBox(height: 20),
                  // Create Account Button
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.purple,
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                      side: const BorderSide(color: Colors.purple),
                    ),
                    child: const Text('CREATE ACCOUNT'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
