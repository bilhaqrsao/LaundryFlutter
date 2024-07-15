import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_laundry/app/modules/bottombar/views/bottombar_view.dart';
import 'package:new_laundry/config/authservice.dart';

class LoginController extends GetxController {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void login() async {
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    try {
      String token = await AuthService().loginUser(username, password);
      // Handle navigasi atau aksi setelah login berhasil
      Get.offAll(() => const BottomNavbar());
      print('Token: $token'); // Opsional: Tampilkan token untuk debugging
    } catch (e) {
      // Tangani error jika login gagal
      print('Error saat login: $e');
      Get.snackbar(
        'Login Failed',
        'Failed to login. Please check your credentials and try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
