import 'package:get/get.dart';
import 'package:new_laundry/app/modules/information/controllers/information_controller.dart';


class InformationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InformationController>(
      () => InformationController(),
    );
  }
}
