import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_laundry/app/modules/splash/controllers/splash_controller.dart';

class SplashView extends StatelessWidget {
  final SplashController splashController = Get.put(SplashController());

  SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'assets/splash.png',
            fit: BoxFit.cover,
          ),
          // Centered loading indicator
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Color.fromARGB(255, 21, 10, 40),
                ),
                SizedBox(height: 20),
                Text(
                  'Loading...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
