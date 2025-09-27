import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/routines_controller.dart';
import '../../models/routine_model.dart';
import '../widgets/habits_drawer.dart';

class RoutinesListPage extends StatelessWidget {
  const RoutinesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RoutinesController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Routines'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
          PopupMenuButton<String>(
            onSelected: (filter) => controller.setFilter(filter),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('Toutes')),
              const PopupMenuItem(value: 'morning', child: Text('Matinales')),
              const PopupMenuItem(value: 'evening', child: Text('Du soir')),
              const PopupMenuItem(value: 'custom', child: Text('Personnalisées')),
              const PopupMenuItem(value: 'active', child: Text('Actives')),
              const PopupMenuItem(value: 'paused', child: Text('En pause')),
            ],
          ),
        ],
      ),
      drawer: const HabitsDrawer(),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Obx(() => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    context,
                    'Toutes',
                    'all',
                    controller.selectedFilter.value,
                    onTap: () => controller.setFilter('all'),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    context,
                    'Matinales',
                    'morning',
                    controller.selectedFilter.value,
                    onTap: () => controller.setFilter('morning'),
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    context,
                    'Du soir',
                    'evening',
                    controller.selectedFilter.value,
                    onTap: () => controller.setFilter('evening'),
                    color: Colors.indigo,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    context,
                    'Personnalisées',
                    'custom',
                    controller.selectedFilter.value,
                    onTap: () => controller.setFilter('custom'),
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    context,
                    'Actives',
                    'active',
                    controller.selectedFilter.value,
                    onTap: () => controller.setFilter('active'),
                    color: Colors.green,
                  ),
                ],
              ),
            )),
          ),

          // Routines list
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => controller.refreshRoutines(),
              child: Obx(() {
                if (controller.isLoading.value) {
                  return _buildShimmerList();
                }

                final routines = controller.routines;

                if (routines.isEmpty) {
                  return _buildEmptyState(context);
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: routines.length,
                  itemBuilder: (context, index) {
                    final routine = routines[index];
                    return _buildRoutineTile(context, routine);
                  },
                );
              }),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/habits/routines/create'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    String value,
    String selectedFilter, {
    required VoidCallback onTap,
    Color? color,
  }) {
    final isSelected = selectedFilter == value;
    final chipColor = color ?? Theme.of(context).primaryColor;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: chipColor.withOpacity(0.1),
      selectedColor: chipColor.withOpacity(0.2),
      checkmarkColor: chipColor,
      labelStyle: TextStyle(
        color: isSelected ? chipColor : Colors.grey[600],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildRoutineTile(BuildContext context, RoutineModel routine) {
    final controller = Get.find<RoutinesController>();

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: routine.color.withOpacity(0.2),
              child: Icon(
                routine.icon,
                color: routine.color,
              ),
            ),
            if (routine.type != RoutineType.custom)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: routine.type.color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    routine.type == RoutineType.morning ? Icons.wb_sunny : Icons.nightlight_round,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          routine.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: routine.status == RoutineStatus.paused ? Colors.grey : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (routine.description != null) ...[
              Text(
                routine.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
            ],
            Row(
              children: [
                _buildRoutineInfo(routine),
                const Spacer(),
                if (routine.startTime != null) ...[
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    routine.startTime!.format(context),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Today's completion status
            if (routine.isScheduledForToday) ...[
              Obx(() {
                final isCompleted = controller.isCompletedToday(routine.id);
                return Icon(
                  isCompleted ? Icons.check_circle : Icons.circle_outlined,
                  color: isCompleted ? Colors.green : Colors.grey,
                  size: 20,
                );
              }),
            ],
            PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(value, routine),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'start',
                  child: Row(
                    children: [
                      Icon(Icons.play_arrow, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Text('Démarrer'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Modifier'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: routine.status == RoutineStatus.active ? 'pause' : 'resume',
                  child: Row(
                    children: [
                      Icon(
                        routine.status == RoutineStatus.active ? Icons.pause : Icons.play_arrow,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(routine.status == RoutineStatus.active ? 'Mettre en pause' : 'Reprendre'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'archive',
                  child: Row(
                    children: [
                      Icon(Icons.archive, size: 20),
                      SizedBox(width: 8),
                      Text('Archiver'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('Supprimer', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () => Get.toNamed('/habits/routines/details', arguments: routine.id),
      ),
    );
  }

  Widget _buildRoutineInfo(RoutineModel routine) {
    final List<Widget> info = [];

    // Type badge
    Color badgeColor = routine.type.color;
    String badgeText = routine.type.displayName;

    info.add(Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        badgeText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    ));

    // Duration
    info.add(const SizedBox(width: 8));
    info.add(Text(
      '${routine.estimatedDuration} min',
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey[600],
      ),
    ));

    // Habits count
    info.add(const SizedBox(width: 8));
    info.add(Text(
      '${routine.habits.length} habitudes',
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey[600],
      ),
    ));

    return Row(children: info);
  }

  Widget _buildEmptyState(BuildContext context) {
    final controller = Get.find<RoutinesController>();
    final filter = controller.selectedFilter.value;

    String title = 'Aucune routine';
    String subtitle = 'Créez votre première routine pour organiser vos habitudes';

    switch (filter) {
      case 'morning':
        title = 'Aucune routine matinale';
        subtitle = 'Créez une routine pour bien commencer la journée';
        break;
      case 'evening':
        title = 'Aucune routine du soir';
        subtitle = 'Créez une routine pour terminer la journée en beauté';
        break;
      case 'custom':
        title = 'Aucune routine personnalisée';
        subtitle = 'Créez des routines adaptées à vos besoins';
        break;
      case 'active':
        title = 'Aucune routine active';
        subtitle = 'Activez ou créez de nouvelles routines';
        break;
      case 'paused':
        title = 'Aucune routine en pause';
        subtitle = 'Les routines pausées apparaîtront ici';
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.schedule,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          if (filter == 'all' || filter == 'morning' || filter == 'evening' || filter == 'custom') ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed('/habits/routines/create'),
              icon: const Icon(Icons.add),
              label: const Text('Créer une routine'),
            ),
          ],
          if (filter == 'all') ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => controller.createDefaultRoutines(),
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Créer les routines par défaut'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 4,
      itemBuilder: (context, index) => _buildShimmerItem(),
    );
  }

  Widget _buildShimmerItem() {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            shape: BoxShape.circle,
          ),
        ),
        title: Container(
          height: 16,
          color: Colors.grey[300],
        ),
        subtitle: Container(
          height: 12,
          width: 150,
          color: Colors.grey[300],
          margin: const EdgeInsets.only(top: 4),
        ),
        trailing: Container(
          width: 24,
          height: 24,
          color: Colors.grey[300],
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    final controller = Get.find<RoutinesController>();

    Get.dialog(
      AlertDialog(
        title: const Text('Rechercher'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Nom de la routine...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) => controller.setSearchQuery(value),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.clearSearch();
              Get.back();
            },
            child: const Text('Effacer'),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, RoutineModel routine) {
    final controller = Get.find<RoutinesController>();

    switch (action) {
      case 'start':
        Get.toNamed('/habits/routines/start', arguments: routine.id);
        break;
      case 'edit':
        Get.toNamed('/habits/routines/edit', arguments: routine.id);
        break;
      case 'pause':
        controller.pauseRoutine(routine.id);
        break;
      case 'resume':
        controller.resumeRoutine(routine.id);
        break;
      case 'archive':
        _confirmArchive(routine);
        break;
      case 'delete':
        _confirmDelete(routine);
        break;
    }
  }

  void _confirmArchive(RoutineModel routine) {
    Get.dialog(
      AlertDialog(
        title: const Text('Archiver la routine'),
        content: Text('Voulez-vous archiver "${routine.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await Get.find<RoutinesController>().archiveRoutine(routine.id);
              if (success) {
                Get.back();
              }
            },
            child: const Text('Archiver'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(RoutineModel routine) {
    Get.dialog(
      AlertDialog(
        title: const Text('Supprimer la routine'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${routine.name}" ?\n\nCette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await Get.find<RoutinesController>().deleteRoutine(routine.id);
              if (success) {
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}