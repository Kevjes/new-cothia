import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/habits_controller.dart';
import '../../controllers/routines_controller.dart';

class HabitsDrawer extends StatelessWidget {
  const HabitsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final habitsController = Get.find<HabitsController>();
    final routinesController = Get.find<RoutinesController>();

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.emoji_events,
                  size: 48,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                const SizedBox(height: 8),
                Text(
                  'Gestion des Habitudes',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                Obx(() => Text(
                  '${habitsController.activeHabitsCount} habitudes actives',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
                  ),
                )),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Vue d'ensemble
                ListTile(
                  leading: const Icon(Icons.dashboard),
                  title: const Text('Vue d\'ensemble'),
                  onTap: () {
                    Get.back();
                    Get.toNamed('/habits');
                  },
                ),
                const Divider(),

                // Habitudes
                ExpansionTile(
                  leading: const Icon(Icons.emoji_events),
                  title: const Text('Habitudes'),
                  children: [
                    ListTile(
                      leading: const Icon(Icons.list),
                      title: const Text('Toutes les habitudes'),
                      onTap: () {
                        Get.back();
                        habitsController.setFilter('all');
                        Get.toNamed('/habits/list');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.trending_up, color: Colors.green),
                      title: const Text('Bonnes habitudes'),
                      onTap: () {
                        Get.back();
                        habitsController.setFilter('good');
                        Get.toNamed('/habits/list');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.trending_down, color: Colors.red),
                      title: const Text('Mauvaises habitudes'),
                      onTap: () {
                        Get.back();
                        habitsController.setFilter('bad');
                        Get.toNamed('/habits/list');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.play_arrow, color: Colors.blue),
                      title: const Text('Habitudes actives'),
                      onTap: () {
                        Get.back();
                        habitsController.setFilter('active');
                        Get.toNamed('/habits/list');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.pause, color: Colors.orange),
                      title: const Text('Habitudes en pause'),
                      onTap: () {
                        Get.back();
                        habitsController.setFilter('paused');
                        Get.toNamed('/habits/list');
                      },
                    ),
                  ],
                ),

                // Routines
                ExpansionTile(
                  leading: const Icon(Icons.schedule),
                  title: const Text('Routines'),
                  children: [
                    ListTile(
                      leading: const Icon(Icons.list),
                      title: const Text('Toutes les routines'),
                      onTap: () {
                        Get.back();
                        routinesController.setFilter('all');
                        Get.toNamed('/habits/routines');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.wb_sunny, color: Colors.amber),
                      title: const Text('Routines matinales'),
                      onTap: () {
                        Get.back();
                        routinesController.setFilter('morning');
                        Get.toNamed('/habits/routines');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.nightlight_round, color: Colors.indigo),
                      title: const Text('Routines du soir'),
                      onTap: () {
                        Get.back();
                        routinesController.setFilter('evening');
                        Get.toNamed('/habits/routines');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.settings, color: Colors.grey),
                      title: const Text('Routines personnalisées'),
                      onTap: () {
                        Get.back();
                        routinesController.setFilter('custom');
                        Get.toNamed('/habits/routines');
                      },
                    ),
                  ],
                ),

                const Divider(),

                // Analytics et rapports
                ListTile(
                  leading: const Icon(Icons.analytics),
                  title: const Text('Analyses'),
                  onTap: () {
                    Get.back();
                    Get.toNamed('/habits/analytics');
                  },
                ),

                // Suggestions et templates
                ListTile(
                  leading: const Icon(Icons.lightbulb),
                  title: const Text('Suggestions'),
                  onTap: () {
                    Get.back();
                    Get.toNamed('/habits/suggestions');
                  },
                ),

                const Divider(),

                // Paramètres
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Paramètres'),
                  onTap: () {
                    Get.back();
                    Get.toNamed('/habits/settings');
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Obx(() => LinearProgressIndicator(
                  value: habitsController.todayCompletionRate / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                )),
                const SizedBox(height: 8),
                Obx(() => Text(
                  '${habitsController.todayCompletionRate.toStringAsFixed(0)}% aujourd\'hui',
                  style: Theme.of(context).textTheme.bodySmall,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}