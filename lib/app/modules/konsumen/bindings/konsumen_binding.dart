import 'package:get/get.dart';

import '../controllers/konsumen_controller.dart';

class KonsumenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KonsumenController>(
      () => KonsumenController(),
    );
  }
}
