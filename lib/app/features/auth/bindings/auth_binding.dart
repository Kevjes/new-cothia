import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../data/services/auth_service.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthService>(() => AuthService(), fenix: true);
    Get.lazyPut<AuthController>(() => AuthController());
  }
}