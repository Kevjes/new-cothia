import 'package:get/get.dart';

import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../features/auth/bindings/auth_binding.dart';
import '../features/auth/views/pages/login_page.dart';
import '../features/auth/views/pages/signup_page.dart';
import '../features/splash/bindings/splash_binding.dart';
import '../features/splash/views/pages/splash_page.dart';
import '../features/entities/bindings/entities_binding.dart';
import '../features/entities/views/pages/entities_main_page.dart';
import '../features/finance/bindings/finance_binding.dart';
import '../features/finance/views/pages/finance_main_page.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashPage(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.SIGNUP,
      page: () => const SignupPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.ENTITIES,
      page: () => const EntitiesMainPage(),
      binding: EntitiesBinding(),
    ),
    GetPage(
      name: _Paths.FINANCE,
      page: () => const FinanceMainPage(),
      binding: FinanceBinding(),
    ),
  ];
}
