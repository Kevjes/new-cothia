import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );

    // L'AuthController est maintenant géré par le SplashController
    // Ne plus le créer ici pour éviter les boucles infinies
  }
}
