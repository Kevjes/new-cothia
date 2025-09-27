import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/habits_controller.dart';
import '../../models/habit_model.dart';
import '../widgets/habits_drawer.dart';

class HabitsListPage extends StatelessWidget {
  const HabitsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HabitsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Habitudes'),
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
              const PopupMenuItem(value: 'good', child: Text('Bonnes habitudes')),
              const PopupMenuItem(value: 'bad', child: Text('Mauvaises habitudes')),
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
                    'Bonnes',
                    'good',
                    controller.selectedFilter.value,
                    onTap: () => controller.setFilter('good'),
                    color: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    context,
                    'Mauvaises',
                    'bad',
                    controller.selectedFilter.value,
                    onTap: () => controller.setFilter('bad'),
                    color: Colors.red,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    context,
                    'Actives',
                    'active',
                    controller.selectedFilter.value,
                    onTap: () => controller.setFilter('active'),
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    context,
                    'Pause',
                    'paused',
                    controller.selectedFilter.value,
                    onTap: () => controller.setFilter('paused'),
                    color: Colors.orange,
                  ),
                ],
              ),
            )),
          ),

          // Habits list
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => controller.refreshHabits(),
              child: Obx(() {
                if (controller.isLoading.value) {
                  return _buildShimmerList();
                }

                final habits = controller.habits;

                if (habits.isEmpty) {
                  return _buildEmptyState(context);
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: habits.length,
                  itemBuilder: (context, index) {
                    final habit = habits[index];
                    return _buildHabitTile(context, habit);
                  },
                );
              }),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/habits/create'),
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

  Widget _buildHabitTile(BuildContext context, HabitModel habit) {
    final controller = Get.find<HabitsController>();

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: habit.color.withOpacity(0.2),
              child: Icon(
                habit.icon,
                color: habit.color,
              ),
            ),
            if (habit.type == HabitType.bad)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.block,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          habit.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: habit.status == HabitStatus.paused ? Colors.grey : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (habit.description != null) ...[
              Text(
                habit.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
            ],
            Row(
              children: [
                _buildHabitInfo(habit),
                const Spacer(),
                if (habit.currentStreak > 0) ...[
                  Icon(
                    Icons.local_fire_department,
                    size: 16,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${habit.currentStreak}',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
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
            Obx(() {
              final isCompleted = controller.isCompletedToday(habit.id);
              return Icon(
                isCompleted ? Icons.check_circle : Icons.circle_outlined,
                color: isCompleted ? Colors.green : Colors.grey,
                size: 20,
              );
            }),
            PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(value, habit),
              itemBuilder: (context) => [
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
                  value: habit.status == HabitStatus.active ? 'pause' : 'resume',
                  child: Row(
                    children: [
                      Icon(
                        habit.status == HabitStatus.active ? Icons.pause : Icons.play_arrow,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(habit.status == HabitStatus.active ? 'Mettre en pause' : 'Reprendre'),
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
        onTap: () => Get.toNamed('/habits/details', arguments: habit.id),
      ),
    );
  }

  Widget _buildHabitInfo(HabitModel habit) {
    final List<Widget> info = [];

    // Type badge
    info.add(Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: habit.type == HabitType.good ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        habit.type == HabitType.good ? 'Bonne' : 'Mauvaise',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    ));

    // Frequency
    info.add(const SizedBox(width: 8));
    info.add(Text(
      habit.frequency.displayName,
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey[600],
      ),
    ));

    // Target quantity
    if (habit.targetQuantity != null) {
      info.add(const SizedBox(width: 8));
      info.add(Text(
        '${habit.targetQuantity} ${habit.unit ?? ''}',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ));
    }

    return Row(children: info);
  }

  Widget _buildEmptyState(BuildContext context) {
    final controller = Get.find<HabitsController>();
    final filter = controller.selectedFilter.value;

    String title = 'Aucune habitude';
    String subtitle = 'Créez votre première habitude pour commencer';

    switch (filter) {
      case 'good':
        title = 'Aucune bonne habitude';
        subtitle = 'Créez des habitudes positives';
        break;
      case 'bad':
        title = 'Aucune mauvaise habitude';
        subtitle = 'Identifiez les habitudes à éviter';
        break;
      case 'active':
        title = 'Aucune habitude active';
        subtitle = 'Activez ou créez de nouvelles habitudes';
        break;
      case 'paused':
        title = 'Aucune habitude en pause';
        subtitle = 'Les habitudes pausées apparaîtront ici';
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events,
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
          if (filter == 'all' || filter == 'good' || filter == 'bad') ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed('/habits/create'),
              icon: const Icon(Icons.add),
              label: const Text('Créer une habitude'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 6,
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
    final controller = Get.find<HabitsController>();

    Get.dialog(
      AlertDialog(
        title: const Text('Rechercher'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Nom de l\'habitude...',
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

  void _handleMenuAction(String action, HabitModel habit) {
    final controller = Get.find<HabitsController>();

    switch (action) {
      case 'edit':
        Get.toNamed('/habits/edit', arguments: habit.id);
        break;
      case 'pause':
        controller.pauseHabit(habit.id);
        break;
      case 'resume':
        controller.resumeHabit(habit.id);
        break;
      case 'archive':
        _confirmArchive(habit);
        break;
      case 'delete':
        _confirmDelete(habit);
        break;
    }
  }

  void _confirmArchive(HabitModel habit) {
    Get.dialog(
      AlertDialog(
        title: const Text('Archiver l\'habitude'),
        content: Text('Voulez-vous archiver "${habit.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await Get.find<HabitsController>().archiveHabit(habit.id);
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

  void _confirmDelete(HabitModel habit) {
    Get.dialog(
      AlertDialog(
        title: const Text('Supprimer l\'habitude'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${habit.name}" ?\n\nCette action est irréversible et supprimera également tout l\'historique.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await Get.find<HabitsController>().deleteHabit(habit.id);
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