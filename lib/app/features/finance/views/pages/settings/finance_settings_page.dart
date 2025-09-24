import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/finance_controller.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/custom_dropdown.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/custom_text_field.dart';

class FinanceSettingsPage extends StatefulWidget {
  const FinanceSettingsPage({super.key});

  @override
  State<FinanceSettingsPage> createState() => _FinanceSettingsPageState();
}

class _FinanceSettingsPageState extends State<FinanceSettingsPage> {
  String _defaultCurrency = 'FCFA';
  String _dateFormat = 'dd/MM/yyyy';
  String _numberFormat = 'space'; // space, comma, period
  bool _showCentimes = false;
  bool _enableNotifications = true;
  bool _autoBackup = true;
  bool _biometricAuth = false;
  String _backupFrequency = 'daily';
  String _theme = 'system';
  String _language = 'fr';

  final _budgetLimitController = TextEditingController();
  final _lowBalanceThresholdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    // En pratique, ces valeurs viendraient d'un service de préférences
    _budgetLimitController.text = '500000';
    _lowBalanceThresholdController.text = '50000';
  }

  @override
  void dispose() {
    _budgetLimitController.dispose();
    _lowBalanceThresholdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Paramètres Finance'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: _showResetDialog,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildCurrencySection(),
          const SizedBox(height: 24),
          _buildDisplaySection(),
          const SizedBox(height: 24),
          _buildNotificationsSection(),
          const SizedBox(height: 24),
          _buildSecuritySection(),
          const SizedBox(height: 24),
          _buildBackupSection(),
          const SizedBox(height: 24),
          _buildThresholdSection(),
          const SizedBox(height: 24),
          _buildAppearanceSection(),
          const SizedBox(height: 32),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildCurrencySection() {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Devise et Format',
              style: Get.textTheme.titleMedium?.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            CustomDropdown<String>(
              label: 'Devise par défaut',
              value: _defaultCurrency,
              items: const [
                DropdownMenuItem(value: 'FCFA', child: Text('FCFA (Franc CFA)')),
                DropdownMenuItem(value: 'EUR', child: Text('EUR (Euro)')),
                DropdownMenuItem(value: 'USD', child: Text('USD (Dollar)')),
                DropdownMenuItem(value: 'XOF', child: Text('XOF (Franc CFA)')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _defaultCurrency = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            CustomDropdown<String>(
              label: 'Séparateur de milliers',
              value: _numberFormat,
              items: const [
                DropdownMenuItem(value: 'space', child: Text('Espace (1 000 000)')),
                DropdownMenuItem(value: 'comma', child: Text('Virgule (1,000,000)')),
                DropdownMenuItem(value: 'period', child: Text('Point (1.000.000)')),
                DropdownMenuItem(value: 'none', child: Text('Aucun (1000000)')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _numberFormat = value;
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Afficher les centimes'),
              subtitle: const Text('Afficher les décimales dans les montants'),
              value: _showCentimes,
              onChanged: (value) {
                setState(() {
                  _showCentimes = value;
                });
              },
              activeColor: AppColors.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplaySection() {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Format d\'Affichage',
              style: Get.textTheme.titleMedium?.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            CustomDropdown<String>(
              label: 'Format de date',
              value: _dateFormat,
              items: const [
                DropdownMenuItem(value: 'dd/MM/yyyy', child: Text('31/12/2024')),
                DropdownMenuItem(value: 'MM/dd/yyyy', child: Text('12/31/2024')),
                DropdownMenuItem(value: 'yyyy-MM-dd', child: Text('2024-12-31')),
                DropdownMenuItem(value: 'dd MMM yyyy', child: Text('31 Déc 2024')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _dateFormat = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            CustomDropdown<String>(
              label: 'Langue',
              value: _language,
              items: const [
                DropdownMenuItem(value: 'fr', child: Text('Français')),
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'ar', child: Text('العربية')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _language = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications',
              style: Get.textTheme.titleMedium?.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Notifications actives'),
              subtitle: const Text('Recevoir des notifications financières'),
              value: _enableNotifications,
              onChanged: (value) {
                setState(() {
                  _enableNotifications = value;
                });
              },
              activeColor: AppColors.secondary,
            ),
            if (_enableNotifications) ...[
              const Divider(),
              CheckboxListTile(
                title: const Text('Solde faible'),
                subtitle: const Text('Alertes de solde bas'),
                value: true,
                onChanged: (value) {},
                activeColor: AppColors.secondary,
              ),
              CheckboxListTile(
                title: const Text('Objectifs atteints'),
                subtitle: const Text('Notifications d\'objectifs réalisés'),
                value: true,
                onChanged: (value) {},
                activeColor: AppColors.secondary,
              ),
              CheckboxListTile(
                title: const Text('Transactions importantes'),
                subtitle: const Text('Notifications pour les gros montants'),
                value: false,
                onChanged: (value) {},
                activeColor: AppColors.secondary,
              ),
              CheckboxListTile(
                title: const Text('Rappels de budget'),
                subtitle: const Text('Alertes de dépassement de budget'),
                value: true,
                onChanged: (value) {},
                activeColor: AppColors.secondary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sécurité',
              style: Get.textTheme.titleMedium?.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Authentification biométrique'),
              subtitle: const Text('Utiliser l\'empreinte digitale ou Face ID'),
              value: _biometricAuth,
              onChanged: (value) {
                setState(() {
                  _biometricAuth = value;
                });
              },
              activeColor: AppColors.secondary,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.lock_reset),
              title: const Text('Changer le mot de passe'),
              subtitle: const Text('Modifier votre mot de passe'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _showChangePasswordDialog,
            ),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Authentification à deux facteurs'),
              subtitle: const Text('Ajouter une couche de sécurité supplémentaire'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _show2FADialog,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupSection() {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sauvegarde et Synchronisation',
              style: Get.textTheme.titleMedium?.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Sauvegarde automatique'),
              subtitle: const Text('Sauvegarder automatiquement vos données'),
              value: _autoBackup,
              onChanged: (value) {
                setState(() {
                  _autoBackup = value;
                });
              },
              activeColor: AppColors.secondary,
            ),
            if (_autoBackup) ...[
              const SizedBox(height: 12),
              CustomDropdown<String>(
                label: 'Fréquence de sauvegarde',
                value: _backupFrequency,
                items: const [
                  DropdownMenuItem(value: 'realtime', child: Text('Temps réel')),
                  DropdownMenuItem(value: 'daily', child: Text('Quotidienne')),
                  DropdownMenuItem(value: 'weekly', child: Text('Hebdomadaire')),
                  DropdownMenuItem(value: 'monthly', child: Text('Mensuelle')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _backupFrequency = value;
                    });
                  }
                },
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Sauvegarder maintenant',
                    onPressed: _performBackup,
                    variant: ButtonVariant.outlined,
                    icon: Icons.backup,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Restaurer',
                    onPressed: _performRestore,
                    variant: ButtonVariant.outlined,
                    icon: Icons.restore,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThresholdSection() {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seuils et Limites',
              style: Get.textTheme.titleMedium?.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _budgetLimitController,
              label: 'Limite de budget par défaut (FCFA)',
              hint: '500000',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _lowBalanceThresholdController,
              label: 'Seuil de solde faible (FCFA)',
              hint: '50000',
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceSection() {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apparence',
              style: Get.textTheme.titleMedium?.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            CustomDropdown<String>(
              label: 'Thème',
              value: _theme,
              items: const [
                DropdownMenuItem(value: 'light', child: Text('Clair')),
                DropdownMenuItem(value: 'dark', child: Text('Sombre')),
                DropdownMenuItem(value: 'system', child: Text('Système')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _theme = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        CustomButton(
          text: 'Enregistrer les paramètres',
          onPressed: _saveSettings,
          icon: Icons.save,
        ),
        const SizedBox(height: 12),
        CustomButton(
          text: 'Réinitialiser par défaut',
          onPressed: _showResetDialog,
          variant: ButtonVariant.outlined,
          icon: Icons.restore,
        ),
        const SizedBox(height: 24),
        Card(
          color: Colors.red.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Zone de danger',
                  style: Get.textTheme.titleMedium?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: 'Supprimer toutes les données',
                  onPressed: _showDeleteAllDataDialog,
                  variant: ButtonVariant.outlined,
                  icon: Icons.delete_forever,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _saveSettings() {
    // En pratique, sauvegarder dans les préférences
    Get.snackbar('Succès', 'Paramètres sauvegardés avec succès');
  }

  void _showResetDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Réinitialiser les paramètres'),
        content: const Text('Voulez-vous restaurer tous les paramètres par défaut ?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _resetToDefaults();
            },
            child: const Text('Réinitialiser'),
          ),
        ],
      ),
    );
  }

  void _resetToDefaults() {
    setState(() {
      _defaultCurrency = 'FCFA';
      _dateFormat = 'dd/MM/yyyy';
      _numberFormat = 'space';
      _showCentimes = false;
      _enableNotifications = true;
      _autoBackup = true;
      _biometricAuth = false;
      _backupFrequency = 'daily';
      _theme = 'system';
      _language = 'fr';
      _budgetLimitController.text = '500000';
      _lowBalanceThresholdController.text = '50000';
    });

    Get.snackbar('Succès', 'Paramètres réinitialisés');
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Changer le mot de passe'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              controller: currentPasswordController,
              label: 'Mot de passe actuel',
              obscureText: true,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: newPasswordController,
              label: 'Nouveau mot de passe',
              obscureText: true,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: confirmPasswordController,
              label: 'Confirmer le mot de passe',
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              // Validation et changement de mot de passe
              Get.back();
              Get.snackbar('Succès', 'Mot de passe modifié avec succès');
            },
            child: const Text('Changer'),
          ),
        ],
      ),
    );
  }

  void _show2FADialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Authentification à deux facteurs'),
        content: const Text('Cette fonctionnalité sera bientôt disponible.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _performBackup() {
    Get.snackbar('Succès', 'Sauvegarde terminée');
  }

  void _performRestore() {
    Get.dialog(
      AlertDialog(
        title: const Text('Restaurer les données'),
        content: const Text('Voulez-vous restaurer les données depuis la dernière sauvegarde ?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.snackbar('Succès', 'Données restaurées avec succès');
            },
            child: const Text('Restaurer'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllDataDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Supprimer toutes les données'),
        content: const Text(
          'ATTENTION: Cette action supprimera définitivement toutes vos données financières. '
          'Cette action est irréversible. Êtes-vous absolument certain ?'
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _showFinalDeleteConfirmation();
            },
            child: const Text('Continuer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showFinalDeleteConfirmation() {
    final confirmController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Confirmation finale'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Tapez "SUPPRIMER TOUT" pour confirmer:'),
            const SizedBox(height: 12),
            CustomTextField(
              controller: confirmController,
              label: 'Confirmation',
              hint: 'SUPPRIMER TOUT',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              if (confirmController.text == 'SUPPRIMER TOUT') {
                Get.back();
                // Supprimer toutes les données
                Get.snackbar('Suppression', 'Toutes les données ont été supprimées');
              } else {
                Get.snackbar('Erreur', 'Confirmation incorrecte');
              }
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}