import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../../../features/finance/controllers/finance_controller.dart';
import '../../../data/services/finance_service.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );

    // Ajouter le FinanceController pour les onglets
    Get.lazyPut<FinanceService>(() => FinanceService(), fenix: true);
    Get.lazyPut<FinanceController>(() => FinanceController(), fenix: true);
  }
}
