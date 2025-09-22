import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/currency.dart';
import '../../../../../core/theme/app_colors.dart';

class CurrenciesList extends StatelessWidget {
  const CurrenciesList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Devises Disponibles'),
        actions: [
          IconButton(
            onPressed: () {
              Get.snackbar(
                'Info',
                'Fonctionnalité pour définir la devise par défaut - À implémenter',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            icon: const Icon(Icons.settings),
            tooltip: 'Paramètres des devises',
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: Currency.values.length,
        itemBuilder: (context, index) {
          final currency = Currency.values[index];
          final isDefault = currency == Currency.fcfa;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Get.theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDefault ? AppColors.primary : AppColors.grey200,
                width: isDefault ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.blackWithOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isDefault ? AppColors.primary : AppColors.grey600).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  currency.symbol,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDefault ? AppColors.primary : AppColors.grey600,
                  ),
                ),
              ),
              title: Text(
                currency.code,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                currency.name,
                style: TextStyle(
                  color: AppColors.grey600,
                  fontSize: 14,
                ),
              ),
              trailing: isDefault
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Défaut',
                        style: TextStyle(
                          color: Get.theme.cardColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : IconButton(
                      onPressed: () {
                        Get.snackbar(
                          'Devise sélectionnée',
                          '${currency.name} définie comme devise par défaut - À implémenter',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                      icon: const Icon(Icons.star_border),
                      tooltip: 'Définir comme devise par défaut',
                    ),
              onTap: () {
                if (!isDefault) {
                  Get.dialog(
                    AlertDialog(
                      title: const Text('Définir comme devise par défaut'),
                      content: Text('Voulez-vous définir ${currency.name} (${currency.code}) comme devise par défaut ?'),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('Annuler'),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.back();
                            Get.snackbar(
                              'Succès',
                              '${currency.name} est maintenant la devise par défaut - À implémenter',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                          child: const Text('Confirmer'),
                        ),
                      ],
                    ),
                  );
                }
              },
          ));
        },
      ),
    );
  }
}