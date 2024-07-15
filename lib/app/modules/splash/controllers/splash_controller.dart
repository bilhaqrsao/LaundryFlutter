import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:new_laundry/app/modules/bottombar/views/bottombar_view.dart';
import 'package:new_laundry/app/modules/login/views/login_view.dart';

class SplashController extends GetxController {
  final storage = GetStorage();

  @override
  void onReady() {
    super.onReady();
    checkTokenAndNavigate();
  }

  void checkTokenAndNavigate() async {
    await Future.delayed(const Duration(seconds: 3)); // Simulasi splash screen

    String? token = storage.read('token');

    if (token != null && token.isNotEmpty) {
      Get.off(() => const BottomNavbar()); // Redirect ke BottomNavbar jika token tersedia
    } else {
      Get.off(() => LoginView()); // Redirect ke LoginView jika token tidak tersedia
    }
  }
}
