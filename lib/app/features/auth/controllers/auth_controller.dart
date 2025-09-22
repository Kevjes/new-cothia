import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.put(AuthController());

  final AuthService _authService = AuthService.to;

  // Form keys
  final signInFormKey = GlobalKey<FormState>();
  final signUpFormKey = GlobalKey<FormState>();
  final forgotPasswordFormKey = GlobalKey<FormState>();

  // Text controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final displayNameController = TextEditingController();
  final resetEmailController = TextEditingController();

  // Observable variables
  final _isPasswordVisible = false.obs;
  final _isConfirmPasswordVisible = false.obs;
  final _currentAuthMode = AuthMode.signIn.obs;

  // Getters
  bool get isPasswordVisible => _isPasswordVisible.value;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible.value;
  AuthMode get currentAuthMode => _currentAuthMode.value;
  bool get isLoading => _authService.isLoading;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    displayNameController.dispose();
    resetEmailController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    _isPasswordVisible.value = !_isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordVisible.value = !_isConfirmPasswordVisible.value;
  }

  void setAuthMode(AuthMode mode) {
    _currentAuthMode.value = mode;
    _clearForm();
  }

  void _clearForm() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    displayNameController.clear();
  }

  Future<void> signIn() async {
    if (!signInFormKey.currentState!.validate()) return;

    final success = await _authService.signIn(
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    if (success) {
      Get.offAllNamed(Routes.HOME);
    }
  }

  Future<void> signUp() async {
    if (!signUpFormKey.currentState!.validate()) return;

    final success = await _authService.signUp(
      email: emailController.text.trim(),
      password: passwordController.text,
      displayName: displayNameController.text.trim().isEmpty
          ? null
          : displayNameController.text.trim(),
    );

    if (success) {
      Get.offAllNamed(Routes.HOME);
    }
  }

  Future<void> resetPassword() async {
    if (!forgotPasswordFormKey.currentState!.validate()) return;

    final success = await _authService.resetPassword(
      email: resetEmailController.text.trim(),
    );

    if (success) {
      resetEmailController.clear();
      setAuthMode(AuthMode.signIn);
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    Get.offAllNamed(Routes.AUTH);
  }

  // Validators
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez saisir un email';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Veuillez saisir un email valide';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez saisir un mot de passe';
    }
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez confirmer le mot de passe';
    }
    if (value != passwordController.text) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }

  String? validateDisplayName(String? value) {
    if (value != null && value.isNotEmpty && value.length < 2) {
      return 'Le nom doit contenir au moins 2 caractères';
    }
    return null;
  }
}

enum AuthMode {
  signIn,
  signUp,
  forgotPassword,
}