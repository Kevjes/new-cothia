import 'package:get/get.dart';
import '../../data/services/theme_service.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/finance_service.dart';
import '../../data/services/accounts_service.dart';
import '../../data/services/budgets_service.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ThemeService>(ThemeService(), permanent: true);
    Get.put<AuthService>(AuthService(), permanent: true);
    Get.put<FinanceService>(FinanceService(), permanent: true);
    Get.put<AccountsService>(AccountsService(), permanent: true);
    Get.put<BudgetsService>(BudgetsService(), permanent: true);
  }
}