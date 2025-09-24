import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/finance_controller.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/custom_button.dart';

class ImportExportPage extends StatefulWidget {
  const ImportExportPage({super.key});

  @override
  State<ImportExportPage> createState() => _ImportExportPageState();
}

class _ImportExportPageState extends State<ImportExportPage> {
  bool _isLoading = false;
  String _selectedExportFormat = 'json';
  String _selectedImportFormat = 'json';
  List<String> _selectedDataTypes = ['transactions', 'accounts', 'objectives'];

  final List<Map<String, dynamic>> _exportFormats = [
    {'value': 'json', 'label': 'JSON', 'description': 'Format structuré pour sauvegarde complète'},
    {'value': 'csv', 'label': 'CSV', 'description': 'Format tableur compatible Excel'},
    {'value': 'pdf', 'label': 'PDF', 'description': 'Rapport imprimable'},
    {'value': 'excel', 'label': 'Excel', 'description': 'Fichier Microsoft Excel natif'},
  ];

  final List<Map<String, dynamic>> _dataTypes = [
    {'value': 'transactions', 'label': 'Transactions', 'icon': Icons.receipt_long},
    {'value': 'accounts', 'label': 'Comptes', 'icon': Icons.account_balance},
    {'value': 'objectives', 'label': 'Objectifs', 'icon': Icons.flag},
    {'value': 'budgets', 'label': 'Budgets', 'icon': Icons.pie_chart},
    {'value': 'categories', 'label': 'Catégories', 'icon': Icons.category},
    {'value': 'settings', 'label': 'Paramètres', 'icon': Icons.settings},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Import/Export'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildExportSection(),
          const SizedBox(height: 32),
          _buildImportSection(),
          const SizedBox(height: 32),
          _buildBackupSection(),
          const SizedBox(height: 32),
          _buildTemplatesSection(),
        ],
      ),
    );
  }

  Widget _buildExportSection() {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.file_download, color: AppColors.secondary, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Exporter les données',
                  style: Get.textTheme.titleLarge?.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Exportez vos données financières vers différents formats',
              style: Get.textTheme.bodyMedium?.copyWith(
                color: AppColors.hint,
              ),
            ),
            const SizedBox(height: 24),

            // Sélection du format d'export
            Text(
              'Format d\'export',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ..._exportFormats.map((format) {
              return RadioListTile<String>(
                title: Text(format['label']),
                subtitle: Text(format['description']),
                value: format['value'],
                groupValue: _selectedExportFormat,
                onChanged: (value) {
                  setState(() {
                    _selectedExportFormat = value!;
                  });
                },
                activeColor: AppColors.secondary,
              );
            }).toList(),

            const SizedBox(height: 24),

            // Sélection des types de données
            Text(
              'Types de données à exporter',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ..._dataTypes.map((dataType) {
              return CheckboxListTile(
                title: Text(dataType['label']),
                secondary: Icon(dataType['icon'], color: AppColors.secondary),
                value: _selectedDataTypes.contains(dataType['value']),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedDataTypes.add(dataType['value']);
                    } else {
                      _selectedDataTypes.remove(dataType['value']);
                    }
                  });
                },
                activeColor: AppColors.secondary,
              );
            }).toList(),

            const SizedBox(height: 24),

            CustomButton(
              text: 'Exporter maintenant',
              onPressed: _selectedDataTypes.isNotEmpty ? _exportData : null,
              icon: Icons.download,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImportSection() {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.file_upload, color: Colors.green, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Importer les données',
                  style: Get.textTheme.titleLarge?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Importez des données depuis un fichier externe',
              style: Get.textTheme.bodyMedium?.copyWith(
                color: AppColors.hint,
              ),
            ),
            const SizedBox(height: 24),

            // Format d'import acceptés
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Formats acceptés',
                    style: Get.textTheme.titleSmall?.copyWith(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('• JSON - Sauvegarde complète Cothia'),
                  Text('• CSV - Données tabulaires (transactions, comptes)'),
                  Text('• Excel - Fichiers Microsoft Excel (.xlsx)'),
                  Text('• OFX/QIF - Formats bancaires standards'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Choisir un fichier',
                    onPressed: _selectImportFile,
                    icon: Icons.folder_open,
                    variant: ButtonVariant.outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Importer',
                    onPressed: _importData,
                    icon: Icons.upload,
                    isLoading: _isLoading,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Attention: L\'import remplacera les données existantes. '
                      'Effectuez une sauvegarde avant d\'importer.',
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.backup, color: Colors.purple, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Sauvegarde Cloud',
                  style: Get.textTheme.titleLarge?.copyWith(
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Synchronisez vos données avec le cloud',
              style: Get.textTheme.bodyMedium?.copyWith(
                color: AppColors.hint,
              ),
            ),
            const SizedBox(height: 24),

            _buildBackupOption(
              'Google Drive',
              'Sauvegarde automatique sur Google Drive',
              Icons.cloud,
              () => _performCloudBackup('google'),
            ),
            const SizedBox(height: 12),
            _buildBackupOption(
              'Dropbox',
              'Sauvegarde sur Dropbox',
              Icons.cloud_queue,
              () => _performCloudBackup('dropbox'),
            ),
            const SizedBox(height: 12),
            _buildBackupOption(
              'OneDrive',
              'Sauvegarde sur Microsoft OneDrive',
              Icons.cloud_upload,
              () => _performCloudBackup('onedrive'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupOption(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.secondary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
      tileColor: AppColors.secondary.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildTemplatesSection() {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.description, color: Colors.teal, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Modèles d\'import',
                  style: Get.textTheme.titleLarge?.copyWith(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Téléchargez des modèles pour faciliter vos imports',
              style: Get.textTheme.bodyMedium?.copyWith(
                color: AppColors.hint,
              ),
            ),
            const SizedBox(height: 24),

            _buildTemplateItem(
              'Modèle Transactions CSV',
              'Formatage standard pour importer vos transactions',
              'transactions_template.csv',
            ),
            const SizedBox(height: 12),
            _buildTemplateItem(
              'Modèle Comptes CSV',
              'Format pour créer plusieurs comptes en une fois',
              'accounts_template.csv',
            ),
            const SizedBox(height: 12),
            _buildTemplateItem(
              'Modèle Objectifs Excel',
              'Feuille Excel pour planifier vos objectifs',
              'objectives_template.xlsx',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateItem(String title, String description, String fileName) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            fileName.endsWith('.csv') ? Icons.table_chart : Icons.description,
            color: Colors.teal,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Get.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Get.textTheme.bodySmall?.copyWith(
                    color: AppColors.hint,
                  ),
                ),
              ],
            ),
          ),
          CustomButton(
            text: 'Télécharger',
            onPressed: () => _downloadTemplate(fileName),
            variant: ButtonVariant.outlined,
            icon: Icons.download,
          ),
        ],
      ),
    );
  }

  Future<void> _exportData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simuler l'export
      await Future.delayed(const Duration(seconds: 2));

      Get.snackbar(
        'Export réussi',
        'Données exportées au format $_selectedExportFormat\n'
        '${_selectedDataTypes.length} types de données inclus',
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      Get.snackbar('Erreur', 'Échec de l\'export: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _selectImportFile() {
    // En pratique, ouvrir un sélecteur de fichier
    Get.snackbar('Sélection', 'Sélecteur de fichier ouvert');
  }

  Future<void> _importData() async {
    // Confirmation avant import
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirmer l\'import'),
        content: const Text(
          'L\'import va remplacer certaines données existantes. '
          'Voulez-vous continuer ?'
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Importer'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Simuler l'import
      await Future.delayed(const Duration(seconds: 3));

      Get.snackbar(
        'Import réussi',
        'Données importées avec succès',
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar('Erreur', 'Échec de l\'import: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _performCloudBackup(String provider) {
    Get.dialog(
      AlertDialog(
        title: Text('Sauvegarde $provider'),
        content: Text('Configurer la sauvegarde automatique sur $provider ?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Plus tard'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.snackbar('Configuration', 'Sauvegarde $provider configurée');
            },
            child: const Text('Configurer'),
          ),
        ],
      ),
    );
  }

  void _downloadTemplate(String fileName) {
    Get.snackbar(
      'Téléchargement',
      'Modèle $fileName téléchargé dans les Documents',
      duration: const Duration(seconds: 2),
    );
  }
}