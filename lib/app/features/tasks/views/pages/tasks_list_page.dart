import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/tasks_controller.dart';
import '../../models/task_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/shimmer_widget.dart';
import '../widgets/task_card_widget.dart';

class TasksListPage extends StatefulWidget {
  const TasksListPage({super.key});

  @override
  State<TasksListPage> createState() => _TasksListPageState();
}

class _TasksListPageState extends State<TasksListPage> {
  final TasksController _controller = Get.find<TasksController>();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();

    // Vérifier s'il y a un filtre passé en argument
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null && arguments['filter'] != null) {
      _controller.setFilter(arguments['filter']);
    }
  }

  Future<void> _loadTasks() async {
    await _controller.loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mes Tâches'),
        backgroundColor: AppColors.surface,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterMenu,
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortMenu,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _controller.refreshTasks,
              child: _buildTasksList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "tasks_list_fab",
        onPressed: () => Get.toNamed('/tasks/create'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher des tâches...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _controller.setSearchQuery('');
                },
              )
            : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: AppColors.surface,
        ),
        onChanged: (value) {
          _controller.setSearchQuery(value);
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return GetBuilder<TasksController>(
      builder: (controller) {
        final filters = [
          {'key': 'all', 'label': 'Toutes', 'icon': Icons.apps},
          {'key': 'today', 'label': 'Aujourd\'hui', 'icon': Icons.today},
          {'key': 'week', 'label': 'Cette semaine', 'icon': Icons.date_range},
          {'key': 'overdue', 'label': 'En retard', 'icon': Icons.warning},
          {'key': 'pending', 'label': 'En attente', 'icon': Icons.schedule},
          {'key': 'inProgress', 'label': 'En cours', 'icon': Icons.play_arrow},
          {'key': 'completed', 'label': 'Terminées', 'icon': Icons.check_circle},
        ];

        return Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: filters.length,
            itemBuilder: (context, index) {
              final filter = filters[index];
              final isSelected = controller.selectedFilter.value == filter['key'];

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        filter['icon'] as IconData,
                        size: 16,
                        color: isSelected ? Colors.white : AppColors.hint,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        filter['label'] as String,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.hint,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    controller.setFilter(filter['key'] as String);
                  },
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  showCheckmark: false,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTasksList() {
    return GetBuilder<TasksController>(
      builder: (controller) {
        if (controller.isLoading.value) {
          return _buildShimmerList();
        }

        final tasks = controller.tasks;

        if (tasks.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TaskCardWidget(
                task: task,
                onTap: () => Get.toNamed('/tasks/details', arguments: task),
                onStatusChanged: (newStatus) => _handleStatusChange(task, newStatus),
                onEdit: () => Get.toNamed('/tasks/edit', arguments: task),
                onDelete: () => _confirmDelete(task),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ShimmerWidget(
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return GetBuilder<TasksController>(
      builder: (controller) {
        String title;
        String subtitle;
        IconData icon;
        Color color;

        switch (controller.selectedFilter.value) {
          case 'today':
            title = 'Aucune tâche pour aujourd\'hui';
            subtitle = 'Profitez de votre journée libre !';
            icon = Icons.check_circle_outline;
            color = AppColors.success;
            break;
          case 'overdue':
            title = 'Aucune tâche en retard';
            subtitle = 'Excellent ! Vous êtes à jour';
            icon = Icons.thumb_up;
            color = AppColors.success;
            break;
          case 'completed':
            title = 'Aucune tâche terminée';
            subtitle = 'Commencez par accomplir vos tâches';
            icon = Icons.assignment_turned_in;
            color = AppColors.info;
            break;
          default:
            title = 'Aucune tâche trouvée';
            subtitle = 'Créez votre première tâche pour commencer';
            icon = Icons.assignment;
            color = AppColors.primary;
        }

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 64, color: color),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: Get.textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: Get.textTheme.bodyMedium?.copyWith(
                    color: AppColors.hint,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (controller.selectedFilter.value == 'all')
                  ElevatedButton.icon(
                    onPressed: () => Get.toNamed('/tasks/create'),
                    icon: const Icon(Icons.add),
                    label: const Text('Créer ma première tâche'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFilterMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtrer par',
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildFilterOption('Priorité', Icons.priority_high, () {
              Navigator.pop(context);
              _showPriorityFilter();
            }),
            _buildFilterOption('Statut', Icons.assignment_turned_in, () {
              Navigator.pop(context);
              _showStatusFilter();
            }),
            _buildFilterOption('Date d\'échéance', Icons.event, () {
              Navigator.pop(context);
              _showDateFilter();
            }),
            _buildFilterOption('Projet', Icons.folder, () {
              Navigator.pop(context);
              _showProjectFilter();
            }),
            const Divider(),
            _buildFilterOption('Réinitialiser filtres', Icons.clear_all, () {
              Navigator.pop(context);
              _controller.clearFilters();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showSortMenu() {
    // TODO: Implémenter le menu de tri
    Get.snackbar(
      'Bientôt disponible',
      'Les options de tri seront disponibles bientôt',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showPriorityFilter() {
    // TODO: Implémenter le filtre par priorité
    Get.snackbar(
      'Filtre priorité',
      'Filtre par priorité bientôt disponible',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showStatusFilter() {
    // TODO: Implémenter le filtre par statut
    Get.snackbar(
      'Filtre statut',
      'Filtre par statut bientôt disponible',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showDateFilter() {
    // TODO: Implémenter le filtre par date
    Get.snackbar(
      'Filtre date',
      'Filtre par date bientôt disponible',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showProjectFilter() {
    // TODO: Implémenter le filtre par projet
    Get.snackbar(
      'Filtre projet',
      'Filtre par projet bientôt disponible',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> _handleStatusChange(TaskModel task, TaskStatus newStatus) async {
    final success = await _controller.changeTaskStatus(task.id, newStatus);

    if (!success) {
      Get.snackbar(
        'Erreur',
        'Impossible de changer le statut de la tâche',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _confirmDelete(TaskModel task) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer la tâche "${task.title}" ?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _controller.deleteTask(task.id);
      if (!success) {
        Get.snackbar(
          'Erreur',
          'Impossible de supprimer la tâche',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }
}