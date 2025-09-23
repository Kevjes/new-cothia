import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';
import '../../auth/controllers/auth_controller.dart';

class SplashController extends GetxController {
  final AuthService _authService = AuthService();

  final _isLoading = true.obs;
  final _loadingProgress = 0.0.obs;
  final _statusMessage = 'Initialisation...'.obs;

  bool get isLoading => _isLoading.value;
  double get loadingProgress => _loadingProgress.value;
  String get statusMessage => _statusMessage.value;

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Simulation du chargement avec messages
      await _updateProgress(0.2, 'Configuration Firebase...');
      await Future.delayed(const Duration(milliseconds: 500));

      await _updateProgress(0.4, 'Vérification de l\'authentification...');
      await Future.delayed(const Duration(milliseconds: 500));

      // Vérifier l'état d'authentification
      final isAuthenticated = await _authService.isAuthenticated();

      await _updateProgress(0.6, 'Chargement des données utilisateur...');
      await Future.delayed(const Duration(milliseconds: 500));

      // Si authentifié, initialiser l'AuthController avec les données utilisateur
      if (isAuthenticated) {
        await _updateProgress(0.8, 'Initialisation du profil...');
        // Créer l'AuthController de manière permanente
        if (!Get.isRegistered<AuthController>()) {
          final authController = Get.put<AuthController>(AuthController(), permanent: true);
          await authController.initializeUserData();
        }
      }

      await _updateProgress(0.9, 'Préparation de l\'interface...');
      await Future.delayed(const Duration(milliseconds: 500));

      await _updateProgress(1.0, 'Finalisation...');
      await Future.delayed(const Duration(milliseconds: 300));

      _isLoading.value = false;

      // Navigation selon l'état d'authentification
      if (isAuthenticated) {
        await Future.delayed(const Duration(milliseconds: 500));
        Get.offAllNamed(Routes.HOME);
      } else {
        await Future.delayed(const Duration(milliseconds: 500));
        Get.offAllNamed(Routes.LOGIN);
      }
    } catch (e) {
      _statusMessage.value = 'Erreur lors de l\'initialisation';
      await Future.delayed(const Duration(seconds: 2));
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  Future<void> _updateProgress(double progress, String message) async {
    _loadingProgress.value = progress;
    _statusMessage.value = message;
    await Future.delayed(const Duration(milliseconds: 100));
  }
}