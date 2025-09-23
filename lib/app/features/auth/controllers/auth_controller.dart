import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/models/user_model.dart';
import '../../../routes/app_pages.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  // Observables
  final _isLoading = false.obs;
  final _currentUser = Rxn<UserModel>();
  final _isAuthenticated = false.obs;

  // Form controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();

  // Form keys
  final loginFormKey = GlobalKey<FormState>();
  final signupFormKey = GlobalKey<FormState>();

  // Getters
  bool get isLoading => _isLoading.value;
  UserModel? get currentUser => _currentUser.value;
  bool get isAuthenticated => _isAuthenticated.value;

  // L'AuthController ne vérifie plus automatiquement l'authentification
  // Ceci est maintenant géré par le SplashController

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    super.onClose();
  }

  // Initialize user data (called from SplashController)
  Future<void> initializeUserData() async {
    try {
      final userData = await _authService.getCurrentUserData();
      _currentUser.value = userData;
      _isAuthenticated.value = true;
    } catch (e) {
      _isAuthenticated.value = false;
      _currentUser.value = null;
    }
  }

  // Cette méthode n'est plus utilisée - gérée par SplashController

  // Sign in with email and password
  Future<void> signIn() async {
    if (!loginFormKey.currentState!.validate()) return;

    try {
      _isLoading.value = true;

      final userCredential = await _authService.signInWithEmailPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (userCredential != null) {
        final userData = await _authService.getCurrentUserData();
        _currentUser.value = userData;
        _isAuthenticated.value = true;

        Get.snackbar(
          'Succès',
          'Connexion réussie',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Clear form and navigate to home
        _clearForm();
        Get.offAllNamed(Routes.HOME);
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Sign up with email and password
  Future<void> signUp() async {
    if (!signupFormKey.currentState!.validate()) return;

    try {
      _isLoading.value = true;

      final userCredential = await _authService.signUpWithEmailPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (userCredential != null) {
        // Update display name if provided
        if (nameController.text.trim().isNotEmpty) {
          await _authService.updateUserProfile(
            displayName: nameController.text.trim(),
          );
        }

        final userData = await _authService.getCurrentUserData();
        _currentUser.value = userData;
        _isAuthenticated.value = true;

        Get.snackbar(
          'Succès',
          'Compte créé avec succès',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Clear form and navigate to home
        _clearForm();
        Get.offAllNamed(Routes.HOME);
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _isLoading.value = true;

      await _authService.signOut();
      _currentUser.value = null;
      _isAuthenticated.value = false;

      Get.snackbar(
        'Succès',
        'Déconnexion réussie',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Navigate to login
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      Get.snackbar(
        'Erreur',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    if (email.isEmpty) {
      Get.snackbar(
        'Erreur',
        'Veuillez entrer votre adresse email',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      _isLoading.value = true;

      await _authService.resetPassword(email);

      Get.snackbar(
        'Succès',
        'Un email de réinitialisation a été envoyé',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Clear form fields
  void _clearForm() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    nameController.clear();
  }

  // Validators
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'adresse email est requise';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Adresse email invalide';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est requis';
    }
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La confirmation du mot de passe est requise';
    }
    if (value != passwordController.text) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le nom est requis';
    }
    if (value.length < 2) {
      return 'Le nom doit contenir au moins 2 caractères';
    }
    return null;
  }
}