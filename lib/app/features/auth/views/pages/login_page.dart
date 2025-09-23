import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_pages.dart';

class LoginPage extends GetView<AuthController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              _buildHeader(),
              const SizedBox(height: 60),
              _buildLoginForm(),
              const SizedBox(height: 24),
              _buildForgotPassword(),
              const SizedBox(height: 40),
              _buildLoginButton(),
              const SizedBox(height: 24),
              _buildSignupLink(),
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
          Icons.account_circle,
          size: 80,
          color: AppColors.primary,
        ),
        const SizedBox(height: 16),
        Text(
          'Bienvenue sur Cothia',
          style: Get.textTheme.headlineMedium?.copyWith(
            color: AppColors.onBackground,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Connectez-vous pour continuer',
          style: Get.textTheme.bodyLarge?.copyWith(
            color: AppColors.hint,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: controller.loginFormKey,
      child: Column(
        children: [
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
            ),
            validator: controller.validatePassword,
          ),
        ],
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => _showForgotPasswordDialog(),
        child: Text(
          'Mot de passe oublié ?',
          style: Get.textTheme.bodyMedium?.copyWith(
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Obx(
      () => ElevatedButton(
        onPressed: controller.isLoading ? null : controller.signIn,
        child: controller.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text('Se connecter'),
      ),
    );
  }

  Widget _buildSignupLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Pas encore de compte ? ',
          style: Get.textTheme.bodyMedium?.copyWith(
            color: AppColors.hint,
          ),
        ),
        TextButton(
          onPressed: () => Get.toNamed(Routes.SIGNUP),
          child: Text(
            'S\'inscrire',
            style: Get.textTheme.bodyMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();

    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Réinitialiser le mot de passe'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Entrez votre adresse email pour recevoir un lien de réinitialisation.',
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Adresse email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.resetPassword(emailController.text.trim());
              Get.back();
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }
}