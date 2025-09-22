import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/theme_switcher.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cothia'),
        centerTitle: true,
        actions: const [
          ThemeSwitcher(),
          SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildLogo(),
              const SizedBox(height: 40),
              Obx(() {
                switch (controller.currentAuthMode) {
                  case AuthMode.signIn:
                    return _buildSignInForm();
                  case AuthMode.signUp:
                    return _buildSignUpForm();
                  case AuthMode.forgotPassword:
                    return _buildForgotPasswordForm();
                }
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        SvgPicture.asset(
          'assets/icons/cothia_logo.svg',
          width: 120,
          height: 120,
        ),
        const SizedBox(height: 16),
        Text(
          'Cothia',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Gérez vos habitudes, tâches et finances',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.grey600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSignInForm() {
    return Form(
      key: controller.signInFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Connexion',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildEmailField(),
          const SizedBox(height: 16),
          _buildPasswordField(),
          const SizedBox(height: 8),
          _buildForgotPasswordButton(),
          const SizedBox(height: 24),
          _buildSignInButton(),
          const SizedBox(height: 24),
          _buildSignUpPrompt(),
        ],
      ),
    );
  }

  Widget _buildSignUpForm() {
    return Form(
      key: controller.signUpFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Créer un compte',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildDisplayNameField(),
          const SizedBox(height: 16),
          _buildEmailField(),
          const SizedBox(height: 16),
          _buildPasswordField(),
          const SizedBox(height: 16),
          _buildConfirmPasswordField(),
          const SizedBox(height: 24),
          _buildSignUpButton(),
          const SizedBox(height: 24),
          _buildSignInPrompt(),
        ],
      ),
    );
  }

  Widget _buildForgotPasswordForm() {
    return Form(
      key: controller.forgotPasswordFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Mot de passe oublié',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Saisissez votre email pour recevoir un lien de réinitialisation',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.grey600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: controller.resetEmailController,
            validator: controller.validateEmail,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: SvgPicture.asset(
                  'assets/icons/email_icon.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    AppColors.grey600,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 24),
          _buildResetPasswordButton(),
          const SizedBox(height: 24),
          _buildBackToSignInButton(),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: controller.emailController,
      validator: controller.validateEmail,
      decoration: InputDecoration(
        labelText: 'Email',
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12),
          child: SvgPicture.asset(
            'assets/icons/email_icon.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              AppColors.grey600,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _buildPasswordField() {
    return Obx(() => TextFormField(
          controller: controller.passwordController,
          validator: controller.validatePassword,
          obscureText: !controller.isPasswordVisible,
          decoration: InputDecoration(
            labelText: 'Mot de passe',
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: SvgPicture.asset(
                'assets/icons/password_icon.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  AppColors.grey600,
                  BlendMode.srcIn,
                ),
              ),
            ),
            suffixIcon: IconButton(
              icon: SvgPicture.asset(
                controller.isPasswordVisible
                    ? 'assets/icons/eye_off_icon.svg'
                    : 'assets/icons/eye_icon.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  AppColors.grey600,
                  BlendMode.srcIn,
                ),
              ),
              onPressed: controller.togglePasswordVisibility,
            ),
          ),
        ));
  }

  Widget _buildConfirmPasswordField() {
    return Obx(() => TextFormField(
          controller: controller.confirmPasswordController,
          validator: controller.validateConfirmPassword,
          obscureText: !controller.isConfirmPasswordVisible,
          decoration: InputDecoration(
            labelText: 'Confirmer le mot de passe',
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: SvgPicture.asset(
                'assets/icons/password_icon.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  AppColors.grey600,
                  BlendMode.srcIn,
                ),
              ),
            ),
            suffixIcon: IconButton(
              icon: SvgPicture.asset(
                controller.isConfirmPasswordVisible
                    ? 'assets/icons/eye_off_icon.svg'
                    : 'assets/icons/eye_icon.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  AppColors.grey600,
                  BlendMode.srcIn,
                ),
              ),
              onPressed: controller.toggleConfirmPasswordVisibility,
            ),
          ),
        ));
  }

  Widget _buildDisplayNameField() {
    return TextFormField(
      controller: controller.displayNameController,
      validator: controller.validateDisplayName,
      decoration: InputDecoration(
        labelText: 'Nom (optionnel)',
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12),
          child: SvgPicture.asset(
            'assets/icons/user_icon.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              AppColors.grey600,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
      textCapitalization: TextCapitalization.words,
    );
  }

  Widget _buildSignInButton() {
    return Obx(() => ElevatedButton(
          onPressed: controller.isLoading ? null : controller.signIn,
          child: controller.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Se connecter'),
        ));
  }

  Widget _buildSignUpButton() {
    return Obx(() => ElevatedButton(
          onPressed: controller.isLoading ? null : controller.signUp,
          child: controller.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Créer le compte'),
        ));
  }

  Widget _buildResetPasswordButton() {
    return Obx(() => ElevatedButton(
          onPressed: controller.isLoading ? null : controller.resetPassword,
          child: controller.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Envoyer le lien'),
        ));
  }

  Widget _buildForgotPasswordButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => controller.setAuthMode(AuthMode.forgotPassword),
        child: Text('Mot de passe oublié ?'),
      ),
    );
  }

  Widget _buildSignUpPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Pas encore de compte ? '),
        TextButton(
          onPressed: () => controller.setAuthMode(AuthMode.signUp),
          child: Text('S\'inscrire'),
        ),
      ],
    );
  }

  Widget _buildSignInPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Déjà un compte ? '),
        TextButton(
          onPressed: () => controller.setAuthMode(AuthMode.signIn),
          child: Text('Se connecter'),
        ),
      ],
    );
  }

  Widget _buildBackToSignInButton() {
    return TextButton(
      onPressed: () => controller.setAuthMode(AuthMode.signIn),
      child: Text('Retour à la connexion'),
    );
  }
}