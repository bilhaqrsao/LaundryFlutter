import 'package:get/get.dart';

import '../controllers/trasanction_controller.dart';

class TrasanctionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TrasanctionController>(
      () => TrasanctionController(),
    );
  }
}
