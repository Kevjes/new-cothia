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
              final isSelected = _controller.selectedFilter.value == filter['key'];

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
                    _controller.setFilter(filter['key'] as String);
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
        if (_controller.isLoading.value) {
          return _buildShimmerList();
        }

        final tasks = _controller.tasks;

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

        switch (_controller.selectedFilter.value) {
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
                if (_controller.selectedFilter.value == 'all')
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
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Trier par',
              style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Date de création'),
              onTap: () {
                Get.back();
                _controller.sortTasks('createdAt');
              },
            ),
            ListTile(
              leading: const Icon(Icons.date_range),
              title: const Text('Date d\'échéance'),
              onTap: () {
                Get.back();
                _controller.sortTasks('dueDate');
              },
            ),
            ListTile(
              leading: const Icon(Icons.priority_high),
              title: const Text('Priorité'),
              onTap: () {
                Get.back();
                _controller.sortTasks('priority');
              },
            ),
            ListTile(
              leading: const Icon(Icons.sort_by_alpha),
              title: const Text('Nom (A-Z)'),
              onTap: () {
                Get.back();
                _controller.sortTasks('title');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPriorityFilter() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filtrer par priorité',
              style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.clear, color: AppColors.hint),
              title: const Text('Toutes les priorités'),
              onTap: () {
                Get.back();
                _controller.filterByPriority(null);
              },
            ),
            ListTile(
              leading: Icon(Icons.keyboard_double_arrow_up, color: AppColors.error),
              title: const Text('Haute'),
              onTap: () {
                Get.back();
                _controller.filterByPriority(TaskPriority.high);
              },
            ),
            ListTile(
              leading: Icon(Icons.keyboard_arrow_up, color: AppColors.warning),
              title: const Text('Moyenne'),
              onTap: () {
                Get.back();
                _controller.filterByPriority(TaskPriority.medium);
              },
            ),
            ListTile(
              leading: Icon(Icons.keyboard_arrow_down, color: AppColors.success),
              title: const Text('Basse'),
              onTap: () {
                Get.back();
                _controller.filterByPriority(TaskPriority.low);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusFilter() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filtrer par statut',
              style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.clear, color: AppColors.hint),
              title: const Text('Tous les statuts'),
              onTap: () {
                Get.back();
                _controller.filterByStatus(null);
              },
            ),
            ListTile(
              leading: Icon(Icons.schedule, color: AppColors.warning),
              title: const Text('En attente'),
              onTap: () {
                Get.back();
                _controller.filterByStatus(TaskStatus.pending);
              },
            ),
            ListTile(
              leading: Icon(Icons.play_arrow, color: AppColors.primary),
              title: const Text('En cours'),
              onTap: () {
                Get.back();
                _controller.filterByStatus(TaskStatus.inProgress);
              },
            ),
            ListTile(
              leading: Icon(Icons.check_circle, color: AppColors.success),
              title: const Text('Terminées'),
              onTap: () {
                Get.back();
                _controller.filterByStatus(TaskStatus.completed);
              },
            ),
            ListTile(
              leading: Icon(Icons.cancel, color: AppColors.error),
              title: const Text('Annulées'),
              onTap: () {
                Get.back();
                _controller.filterByStatus(TaskStatus.cancelled);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDateFilter() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filtrer par date',
              style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.clear, color: AppColors.hint),
              title: const Text('Toutes les dates'),
              onTap: () {
                Get.back();
                _controller.filterByDate(null);
              },
            ),
            ListTile(
              leading: Icon(Icons.today, color: AppColors.primary),
              title: const Text('Aujourd\'hui'),
              onTap: () {
                Get.back();
                _controller.filterByDate('today');
              },
            ),
            ListTile(
              leading: Icon(Icons.date_range, color: AppColors.secondary),
              title: const Text('Cette semaine'),
              onTap: () {
                Get.back();
                _controller.filterByDate('week');
              },
            ),
            ListTile(
              leading: Icon(Icons.warning, color: AppColors.error),
              title: const Text('En retard'),
              onTap: () {
                Get.back();
                _controller.filterByDate('overdue');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showProjectFilter() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filtrer par projet',
              style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.clear, color: AppColors.hint),
              title: const Text('Tous les projets'),
              onTap: () {
                Get.back();
                _controller.filterByProject(null);
              },
            ),
            ListTile(
              leading: Icon(Icons.inbox, color: AppColors.hint),
              title: const Text('Sans projet'),
              onTap: () {
                Get.back();
                _controller.filterByProject('none');
              },
            ),
            GetBuilder<TasksController>(
              builder: (controller) {
                return Column(
                  children: _controller.projects.map((project) {
                    return ListTile(
                      leading: Icon(Icons.folder, color: AppColors.primary),
                      title: Text(project.name),
                      onTap: () {
                        Get.back();
                        _controller.filterByProject(project.id);
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
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