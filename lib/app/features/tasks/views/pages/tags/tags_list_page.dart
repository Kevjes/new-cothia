import 'package:cothia_app/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/constants/app_colors.dart';

class TagsListPage extends StatelessWidget {
  const TagsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Liste de tags d'exemple (à remplacer par des données Firebase)
    final List<Map<String, dynamic>> tags = [
      {'name': 'Urgent', 'color': Colors.red, 'count': 5},
      {'name': 'Important', 'color': Colors.orange, 'count': 12},
      {'name': 'Personnel', 'color': Colors.blue, 'count': 8},
      {'name': 'Travail', 'color': Colors.green, 'count': 15},
      {'name': 'Santé', 'color': Colors.purple, 'count': 3},
      {'name': 'Formation', 'color': Colors.teal, 'count': 7},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Gestion des Tags'),
        backgroundColor: AppColors.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateTagDialog(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh tags data from Firebase
          // TODO: Implémenter le service de tags
          Get.snackbar('Actualisation', 'Tags actualisés');
        },
        child: tags.isEmpty
            ? _buildEmptyState()
            : _buildTagsList(tags),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "tags_list_fab",
        onPressed: () => _showCreateTagDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.label_outline,
            size: 64,
            color: AppColors.hint,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun tag',
            style: Get.textTheme.headlineSmall?.copyWith(
              color: AppColors.hint,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Créez des tags pour organiser vos tâches',
            style: Get.textTheme.bodyMedium?.copyWith(
              color: AppColors.hint,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCreateTagDialog(Get.context!),
            icon: const Icon(Icons.add),
            label: const Text('Créer un tag'),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsList(List<Map<String, dynamic>> tags) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tags.length,
      itemBuilder: (context, index) {
        final tag = tags[index];
        return _buildTagCard(tag);
      },
    );
  }

  Widget _buildTagCard(Map<String, dynamic> tag) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: tag['color'],
            shape: BoxShape.circle,
          ),
        ),
        title: Text(
          tag['name'],
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text('${tag['count']} tâche(s)'),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditTagDialog(Get.context!, tag);
                break;
              case 'delete':
                _showDeleteConfirmation(Get.context!, tag);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Text('Modifier'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Supprimer'),
            ),
          ],
        ),
        onTap: () {
          // Navigate to tasks filtered by this tag
          Get.back();
          Get.toNamed('/tasks/list', parameters: {'tagFilter': tag['name']});
          Get.snackbar('Filtre appliqué', 'Affichage des tâches avec le tag "${tag['name']}"');
        },
      ),
    );
  }

  void _showCreateTagDialog(BuildContext context) {
    final nameController = TextEditingController();
    Color selectedColor = Colors.blue;

    Get.dialog(
      AlertDialog(
        title: const Text('Nouveau Tag'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom du tag',
                    hintText: 'Ex: Urgent, Important...',
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Couleur:'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    Colors.red,
                    Colors.orange,
                    Colors.yellow,
                    Colors.green,
                    Colors.blue,
                    Colors.purple,
                    Colors.pink,
                    Colors.teal,
                  ].map((color) {
                    return GestureDetector(
                      onTap: () => setState(() => selectedColor = color),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedColor == color ? Colors.white : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: selectedColor == color
                            ? const Icon(Icons.check, color: Colors.white, size: 16)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                // Save tag to Firebase
                final newTag = {
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                  'name': nameController.text.trim(),
                  'color': selectedColor,
                  'createdAt': DateTime.now().toIso8601String(),
                };
                // Here you would typically save to Firebase
                // await tagService.createTag(newTag);

                Get.back();
                Get.snackbar('Succès', 'Tag "${nameController.text}" créé avec succès');
              }
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  void _showEditTagDialog(BuildContext context, Map<String, dynamic> tag) {
    final nameController = TextEditingController(text: tag['name']);
    Color selectedColor = tag['color'];

    Get.dialog(
      AlertDialog(
        title: const Text('Modifier le Tag'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom du tag',
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Couleur:'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    Colors.red,
                    Colors.orange,
                    Colors.yellow,
                    Colors.green,
                    Colors.blue,
                    Colors.purple,
                    Colors.pink,
                    Colors.teal,
                  ].map((color) {
                    return GestureDetector(
                      onTap: () => setState(() => selectedColor = color),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedColor == color ? Colors.white : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: selectedColor == color
                            ? const Icon(Icons.check, color: Colors.white, size: 16)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                // Update tag in Firebase
                final updatedTag = {
                  'id': tag['id'],
                  'name': nameController.text.trim(),
                  'color': selectedColor,
                  'updatedAt': DateTime.now().toIso8601String(),
                };
                // Here you would typically update in Firebase
                // await tagService.updateTag(tag['id'], updatedTag);

                Get.back();
                Get.snackbar('Succès', 'Tag "${nameController.text}" modifié avec succès');
              }
            },
            child: const Text('Modifier'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Map<String, dynamic> tag) {
    Get.dialog(
      AlertDialog(
        title: const Text('Supprimer le tag'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Êtes-vous sûr de vouloir supprimer le tag "${tag['name']}" ?'),
            if (tag['count'] > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: AppColors.warning, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Ce tag est utilisé par ${tag['count']} tâche(s). Il sera retiré de toutes ces tâches.',
                        style: TextStyle(
                          color: AppColors.warning,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Delete tag from Firebase
              try {
                // Here you would typically delete from Firebase
                // await tagService.deleteTag(tag['id']);

                Get.back();
                Get.snackbar('Succès', 'Tag "${tag['name']}" supprimé avec succès');
              } catch (e) {
                Get.snackbar('Erreur', 'Impossible de supprimer le tag');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}