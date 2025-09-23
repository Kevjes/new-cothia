import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/splash_controller.dart';
import '../../../../core/constants/app_colors.dart';

class SplashPage extends GetView<SplashController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              _buildLogo(),
              const SizedBox(height: 32),
              _buildAppName(),
              const SizedBox(height: 16),
              _buildTagline(),
              const Spacer(flex: 2),
              _buildLoadingSection(),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(
        Icons.account_balance_wallet_rounded,
        size: 60,
        color: Colors.white,
      ),
    );
  }

  Widget _buildAppName() {
    return Text(
      'Cothia',
      style: Get.textTheme.displayLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.onBackground,
        letterSpacing: 2.0,
      ),
    );
  }

  Widget _buildTagline() {
    return Text(
      'Gérez vos finances, tâches et habitudes',
      style: Get.textTheme.bodyLarge?.copyWith(
        color: AppColors.hint,
        letterSpacing: 0.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildLoadingSection() {
    return Obx(() => Column(
          children: [
            // Progress bar
            Container(
              width: double.infinity,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(3),
              ),
              child: Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: MediaQuery.of(Get.context!).size.width *
                           controller.loadingProgress * 0.8, // 80% de la largeur disponible
                    height: 6,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Status message with fade animation
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                controller.statusMessage,
                key: ValueKey(controller.statusMessage),
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 16),

            // Loading dots animation
            if (controller.isLoading) _buildLoadingDots(),
          ],
        ));
  }

  Widget _buildLoadingDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 600 + (index * 200)),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.6),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}