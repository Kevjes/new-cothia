import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../../../core/constants/app_colors.dart';

class SignupPage extends GetView<AuthController> {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onBackground),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 40),
              _buildSignupForm(),
              const SizedBox(height: 40),
              _buildSignupButton(),
              const SizedBox(height: 24),
              _buildLoginLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Icon(
          Icons.person_add,
          size: 80,
          color: AppColors.primary,
        ),
        const SizedBox(height: 16),
        Text(
          'Créer un compte',
          style: Get.textTheme.headlineMedium?.copyWith(
            color: AppColors.onBackground,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Rejoignez Cothia dès aujourd\'hui',
          style: Get.textTheme.bodyLarge?.copyWith(
            color: AppColors.hint,
          ),
        ),
      ],
    );
  }

  Widget _buildSignupForm() {
    return Form(
      key: controller.signupFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: controller.nameController,
            keyboardType: TextInputType.name,
            decoration: const InputDecoration(
              labelText: 'Nom complet',
              prefixIcon: Icon(Icons.person_outlined),
            ),
            validator: controller.validateName,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller.emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Adresse email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: controller.validateEmail,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller.passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Mot de passe',
              prefixIcon: Icon(Icons.lock_outlined),
              helperText: 'Au moins 6 caractères',
            ),
            validator: controller.validatePassword,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller.confirmPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Confirmer le mot de passe',
              prefixIcon: Icon(Icons.lock_outlined),
            ),
            validator: controller.validateConfirmPassword,
          ),
        ],
      ),
    );
  }

  Widget _buildSignupButton() {
    return Obx(
      () => ElevatedButton(
        onPressed: controller.isLoading ? null : controller.signUp,
        child: controller.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text('Créer le compte'),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Déjà un compte ? ',
          style: Get.textTheme.bodyMedium?.copyWith(
            color: AppColors.hint,
          ),
        ),
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            'Se connecter',
            style: Get.textTheme.bodyMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}