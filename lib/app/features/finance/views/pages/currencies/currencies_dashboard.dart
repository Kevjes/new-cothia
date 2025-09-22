import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/currency.dart';
import '../../../../../core/theme/app_colors.dart';

class CurrenciesDashboard extends StatelessWidget {
  const CurrenciesDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Devises'),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed('/finance/currencies/converter'),
            icon: const Icon(Icons.swap_horiz),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsCards(),
            const SizedBox(height: 24),
            _buildQuickActions(),
            const SizedBox(height: 24),
            _buildCurrencyConverter(),
            const SizedBox(height: 24),
            _buildSupportedCurrencies(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Devises Supportées',
            '${Currency.values.length}',
            Icons.currency_exchange,
            AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Devise Principale',
            Currency.fcfa.code,
            Icons.star,
            AppColors.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Taux Mis à Jour',
            'Aujourd\'hui',
            Icons.update,
            AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackWithOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.grey600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actions Rapides',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Convertisseur',
                Icons.swap_horiz,
                AppColors.primary,
                () => Get.toNamed('/finance/currencies/converter'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'Taux de Change',
                Icons.trending_up,
                AppColors.secondary,
                () => Get.toNamed('/finance/currencies/rates'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Historique',
                Icons.history,
                AppColors.warning,
                () => Get.toNamed('/finance/currencies/history'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'Paramètres',
                Icons.settings,
                AppColors.info,
                () => Get.toNamed('/finance/currencies/settings'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: color,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyConverter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Convertisseur Rapide',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.adaptiveEmptyStateBackground(Get.context!),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.adaptiveEmptyStateBorder(Get.context!)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<Currency>(
                      decoration: const InputDecoration(
                        labelText: 'De',
                        border: OutlineInputBorder(),
                      ),
                      value: Currency.fcfa,
                      items: Currency.values.map((currency) {
                        return DropdownMenuItem(
                          value: currency,
                          child: Row(
                            children: [
                              Text(currency.symbol),
                              const SizedBox(width: 8),
                              Text('${currency.code}'),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {},
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.swap_horiz,
                      color: AppColors.primary,
                    ),
                  ),
                  Expanded(
                    child: DropdownButtonFormField<Currency>(
                      decoration: const InputDecoration(
                        labelText: 'Vers',
                        border: OutlineInputBorder(),
                      ),
                      value: Currency.usd,
                      items: Currency.values.map((currency) {
                        return DropdownMenuItem(
                          value: currency,
                          child: Row(
                            children: [
                              Text(currency.symbol),
                              const SizedBox(width: 8),
                              Text('${currency.code}'),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Montant à convertir',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.money),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Get.theme.cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Résultat',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.grey600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '0.00 USD',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Taux: 1 FCFA = 0.0016 USD',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.toNamed('/finance/currencies/converter'),
                  child: const Text('Ouvrir le Convertisseur Complet'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSupportedCurrencies() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Devises Supportées',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => Get.toNamed('/finance/currencies/rates'),
              child: const Text('Voir les taux'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
          ),
          itemCount: Currency.values.length,
          itemBuilder: (context, index) {
            final currency = Currency.values[index];
            return _buildCurrencyCard(currency);
          },
        ),
      ],
    );
  }

  Widget _buildCurrencyCard(Currency currency) {
    final isDefault = currency == Currency.fcfa;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(8),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isDefault ? AppColors.primary : AppColors.grey600).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              currency.symbol,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDefault ? AppColors.primary : AppColors.grey600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  currency.code,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  currency.name,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.grey600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (isDefault)
                  Text(
                    'Défaut',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}