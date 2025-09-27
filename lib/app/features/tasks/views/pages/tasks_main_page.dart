import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_pages.dart';
import 'tasks_overview_page.dart';
import 'tasks_list_page.dart';
import 'projects/projects_list_page.dart';
import 'analytics/tasks_analytics_page.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../entities/controllers/entities_controller.dart';
import '../../controllers/tasks_controller.dart';

class TasksMainPage extends StatefulWidget {
  const TasksMainPage({super.key});

  @override
  State<TasksMainPage> createState() => _TasksMainPageState();
}

class _TasksMainPageState extends State<TasksMainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const TasksOverviewPage(),
    const TasksListPage(),
    const Placeholder(), // Projects - TODO: Create ProjectsListPage
    const TasksAnalyticsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_getPageTitle()),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => _showNotifications(),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearch(),
          ),
        ],
      ),
      drawer: _buildTasksDrawer(),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuickActionMenu(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle Tâche'),
      ),
    );
  }

  String _getPageTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Tableau de Bord - Tâches';
      case 1:
        return 'Mes Tâches';
      case 2:
        return 'Projets';
      case 3:
        return 'Analyses';
      default:
        return 'Tâches';
    }
  }

  Widget _buildTasksDrawer() {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            _buildDrawerHeader(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerSection('NAVIGATION', [
                    _buildDrawerItem(
                      icon: Icons.dashboard,
                      title: 'Tableau de Bord',
                      index: 0,
                      isSelected: _selectedIndex == 0,
                    ),
                    _buildDrawerItem(
                      icon: Icons.assignment,
                      title: 'Mes Tâches',
                      index: 1,
                      isSelected: _selectedIndex == 1,
                    ),
                    _buildDrawerItem(
                      icon: Icons.folder_special,
                      title: 'Projets',
                      index: 2,
                      isSelected: _selectedIndex == 2,
                    ),
                    _buildDrawerItem(
                      icon: Icons.analytics,
                      title: 'Analyses',
                      index: 3,
                      isSelected: _selectedIndex == 3,
                    ),
                  ]),
                  const Divider(),
                  _buildDrawerSection('GESTION', [
                    _buildDrawerActionItem(
                      icon: Icons.category,
                      title: 'Catégories',
                      onTap: () => Get.toNamed(Routes.TASKS_CATEGORIES),
                    ),
                    _buildDrawerActionItem(
                      icon: Icons.label,
                      title: 'Tags',
                      onTap: () => Get.toNamed(Routes.TASKS_TAGS),
                    ),
                    _buildDrawerActionItem(
                      icon: Icons.repeat,
                      title: 'Tâches Récurrentes',
                      onTap: () => Get.toNamed(Routes.TASKS_RECURRING),
                    ),
                  ]),
                  const Divider(),
                  _buildDrawerSection('OUTILS', [
                    _buildDrawerActionItem(
                      icon: Icons.import_export,
                      title: 'Import/Export',
                      onTap: () => _showComingSoon('Import/Export'),
                    ),
                    _buildDrawerActionItem(
                      icon: Icons.backup,
                      title: 'Sauvegarde',
                      onTap: () => _showComingSoon('Sauvegarde'),
                    ),
                  ]),
                  const Divider(),
                  _buildDrawerSection('CONFIGURATION', [
                    _buildDrawerActionItem(
                      icon: Icons.settings,
                      title: 'Paramètres Tâches',
                      onTap: () => _showComingSoon('Paramètres'),
                    ),
                    _buildDrawerActionItem(
                      icon: Icons.help,
                      title: 'Aide',
                      onTap: () => _showComingSoon('Aide'),
                    ),
                  ]),
                  // Ajouter un espace en bas pour éviter le conflit avec l'entity selector
                  const SizedBox(height: 100),
                ],
              ),
            ),
            _buildSimpleEntitySelector(), // Version simplifiée
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return GetBuilder<TasksController>(
      builder: (controller) {
        return DrawerHeader(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.assignment, color: Colors.white, size: 32),
                  const SizedBox(width: 12),
                  Text(
                    'Gestion des Tâches',
                    style: Get.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildHeaderStat(
                    'Total',
                    controller.totalTasks.toString(),
                  ),
                  _buildHeaderStat(
                    'En cours',
                    controller.inProgressTasks.toString(),
                  ),
                  _buildHeaderStat(
                    'Terminées',
                    controller.completedTasks.toString(),
                  ),
                ],
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildHeaderStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Get.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Get.textTheme.bodySmall?.copyWith(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildDrawerSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: Get.textTheme.labelSmall?.copyWith(
              color: AppColors.hint,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        ...items,
      ],
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required int index,
    required bool isSelected,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : AppColors.hint,
      ),
      title: Text(
        title,
        style: Get.textTheme.bodyMedium?.copyWith(
          color: isSelected ? AppColors.primary : Colors.white,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppColors.primary.withOpacity(0.1),
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        Navigator.of(context).pop();
      },
    );
  }

  Widget _buildDrawerActionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.hint),
      title: Text(
        title,
        style: Get.textTheme.bodyMedium?.copyWith(
          color: Colors.white,
        ),
      ),
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
    );
  }

  Widget _buildEntitySelector() {
    return GetBuilder<EntitiesController>(
      builder: (entitiesController) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border(
              top: BorderSide(color: AppColors.hint.withOpacity(0.2)),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ENTITÉ ACTIVE',
                style: Get.textTheme.labelSmall?.copyWith(
                  color: AppColors.hint,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: entitiesController.selectedEntityId.value,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: entitiesController.entities.map((entity) {
                  return DropdownMenuItem(
                    value: entity.id,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          entity.isPersonal ? Icons.person : Icons.business,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entity.name,
                            style: Get.textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    entitiesController.setSelectedEntity(value);
                    Get.find<TasksController>().setEntityFilter(value);
                  }
                },
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildSimpleEntitySelector() {
    return Container(
      height: 80, // Hauteur fixe pour éviter les problèmes de layout
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.hint.withOpacity(0.2)),
        ),
      ),
      child: GetBuilder<EntitiesController>(
        builder: (entitiesController) {
          final selectedEntity = entitiesController.entities.firstWhere(
            (entity) => entity.id == entitiesController.selectedEntityId.value,
            orElse: () => entitiesController.entities.first,
          );

          return Row(
            children: [
              Icon(
                selectedEntity.isPersonal ? Icons.person : Icons.business,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ENTITÉ ACTIVE',
                      style: Get.textTheme.labelSmall?.copyWith(
                        color: AppColors.hint,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      selectedEntity.name,
                      style: Get.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.swap_horiz, color: AppColors.primary),
                onPressed: () {
                  // Afficher un dialog pour changer d'entité
                  _showEntitySelectorDialog();
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEntitySelectorDialog() {
    final entitiesController = Get.find<EntitiesController>();

    Get.dialog(
      AlertDialog(
        title: const Text('Changer d\'entité'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: entitiesController.entities.length,
            itemBuilder: (context, index) {
              final entity = entitiesController.entities[index];
              final isSelected = entity.id == entitiesController.selectedEntityId.value;

              return ListTile(
                leading: Icon(
                  entity.isPersonal ? Icons.person : Icons.business,
                  color: isSelected ? AppColors.primary : AppColors.hint,
                ),
                title: Text(entity.name),
                trailing: isSelected ? Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () {
                  entitiesController.setSelectedEntity(entity.id);
                  Get.find<TasksController>().setEntityFilter(entity.id);
                  Get.back();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  void _showQuickActionMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Actions Rapides',
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildQuickAction(
                    'Nouvelle Tâche',
                    Icons.add_task,
                    AppColors.primary,
                    () => Get.toNamed(Routes.TASKS_CREATE),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickAction(
                    'Nouveau Projet',
                    Icons.add_box,
                    AppColors.secondary,
                    () => Get.toNamed(Routes.TASKS_PROJECT_CREATE),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickAction(
                    'Scan Tâche',
                    Icons.qr_code_scanner,
                    AppColors.info,
                    () => _showComingSoon('Scan QR Code'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickAction(
                    'Template Tâche',
                    Icons.content_copy,
                    AppColors.orange,
                    () => _showComingSoon('Templates'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: Get.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showNotifications() {
    _showComingSoon('Notifications');
  }

  void _showSearch() {
    // TODO: Implémenter la recherche globale
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Recherche'),
        content: TextField(
          decoration: InputDecoration(
            hintText: 'Rechercher des tâches...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSubmitted: (query) {
            Navigator.of(context).pop();
            // TODO: Implémenter la logique de recherche
            Get.find<TasksController>().setSearchQuery(query);
            setState(() {
              _selectedIndex = 1; // Aller à la liste des tâches
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    Get.snackbar(
      'Bientôt Disponible',
      '$feature sera disponible dans une prochaine version',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.info,
      colorText: Colors.white,
      icon: const Icon(Icons.upcoming, color: Colors.white),
    );
  }
}