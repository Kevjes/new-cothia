import 'package:get/get.dart';
import '../controllers/finance_controller.dart';
import '../controllers/budgets_controller.dart';
import '../../../data/services/finance_service.dart';
import '../../../data/services/accounts_service.dart';
import '../../../data/services/budgets_service.dart';

class FinanceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FinanceService>(() => FinanceService(), fenix: true);
    Get.lazyPut<AccountsService>(() => AccountsService(), fenix: true);
    Get.lazyPut<BudgetsService>(() => BudgetsService(), fenix: true);
    Get.lazyPut<FinanceController>(() => FinanceController());
    Get.lazyPut<BudgetsController>(() => BudgetsController());
  }
}