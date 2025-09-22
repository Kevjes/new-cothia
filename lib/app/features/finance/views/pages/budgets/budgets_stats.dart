import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/budgets_controller.dart';
import '../../../../../core/theme/app_colors.dart';

class BudgetsStats extends GetView<BudgetsController> {
  const BudgetsStats({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.analytics,
                  size: 48,
                  color: AppColors.grey500,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Statistiques',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Cette section sera disponible prochainement avec des graphiques et analyses détaillées',
                style: TextStyle(
                  color: AppColors.grey600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}