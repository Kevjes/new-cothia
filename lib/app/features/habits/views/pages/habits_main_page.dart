import 'package:cothia_app/app/features/habits/models/routine_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/habits_controller.dart';
import '../../controllers/routines_controller.dart';
import '../widgets/habits_stats_widget.dart';
import '../widgets/today_habits_widget.dart';
import '../widgets/quick_actions_widget.dart';
import '../widgets/habits_drawer.dart';

class HabitsMainPage extends StatelessWidget {
  const HabitsMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final habitsController = Get.find<HabitsController>();
    final routinesController = Get.find<RoutinesController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Habitudes'),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => Get.toNamed('/habits/analytics'),
          ),
        ],
      ),
      drawer: const HabitsDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          await habitsController.refreshHabits();
          await routinesController.refreshRoutines();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Actions Section
              const QuickActionsWidget(),
              const SizedBox(height: 20),

              // Statistics Overview
              const HabitsStatsWidget(),
              const SizedBox(height: 20),

              // Today's Habits
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Habitudes d\'aujourd\'hui',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Obx(() => Text(
                            '${habitsController.completedTodayCount}/${habitsController.todayHabitsCount}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          )),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const TodayHabitsWidget(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Recent Routines
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Routines actives',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          TextButton(
                            onPressed: () => Get.toNamed('/habits/routines'),
                            child: const Text('Voir tout'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Obx(() {
                        final activeRoutines = routinesController.activeRoutines.take(3).toList();
                        if (activeRoutines.isEmpty) {
                          return const Center(
                            child: Text('Aucune routine active'),
                          );
                        }
                        return Column(
                          children: activeRoutines.map((routine) => ListTile(
                            leading: Icon(
                              routine.type.icon,
                              color: routine.color,
                            ),
                            title: Text(routine.name),
                            subtitle: Text('${routine.estimatedDuration} min'),
                            trailing: routine.isScheduledForToday
                                ? Icon(
                                    routinesController.isCompletedToday(routine.id)
                                        ? Icons.check_circle
                                        : Icons.circle_outlined,
                                    color: routinesController.isCompletedToday(routine.id)
                                        ? Colors.green
                                        : Colors.grey,
                                  )
                                : null,
                            onTap: () => Get.toNamed('/habits/routines/details', arguments: routine.id),
                          )).toList(),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQuickAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Rechercher'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Nom de l\'habitude...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            Get.find<HabitsController>().setSearchQuery(value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.find<HabitsController>().clearSearch();
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

  void _showQuickAddDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Ajouter'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.emoji_events),
              title: const Text('Nouvelle habitude'),
              onTap: () {
                Get.back();
                Get.toNamed('/habits/create');
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Nouvelle routine'),
              onTap: () {
                Get.back();
                Get.toNamed('/habits/routines/create');
              },
            ),
          ],
        ),
      ),
    );
  }
}