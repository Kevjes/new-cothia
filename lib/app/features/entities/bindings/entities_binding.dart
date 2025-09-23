import 'package:get/get.dart';
import '../controllers/entities_controller.dart';

class EntitiesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EntitiesController>(
      () => EntitiesController(),
    );
  }
}