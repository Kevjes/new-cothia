import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';
import '../../../core/constants/app_constants.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtenir toutes les catégories d'une entité
  Future<List<CategoryModel>> getCategoriesByEntity(String entityId) async {
    try {
      final querySnapshot = await _firestore
          .collection('categories')
          .where('entityId', isEqualTo: entityId)
          .where('isActive', isEqualTo: true)
          .orderBy('sortOrder')
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des catégories: ${e.toString()}');
    }
  }

  // Obtenir une catégorie par ID
  Future<CategoryModel?> getCategoryById(String categoryId) async {
    try {
      final doc = await _firestore
          .collection('categories')
          .doc(categoryId)
          .get();

      if (doc.exists) {
        return CategoryModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la catégorie: ${e.toString()}');
    }
  }

  // Créer une nouvelle catégorie
  Future<CategoryModel> createCategory(CategoryModel category) async {
    try {
      final docRef = await _firestore
          .collection('categories')
          .add(category.toFirestore());

      return category.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Erreur lors de la création de la catégorie: ${e.toString()}');
    }
  }

  // Mettre à jour une catégorie
  Future<CategoryModel> updateCategory(CategoryModel category) async {
    try {
      final updatedCategory = category.copyWith(updatedAt: DateTime.now());

      await _firestore
          .collection('categories')
          .doc(category.id)
          .update(updatedCategory.toFirestore());

      return updatedCategory;
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la catégorie: ${e.toString()}');
    }
  }

  // Supprimer une catégorie (soft delete)
  Future<void> deleteCategory(String categoryId) async {
    try {
      // Vérifier si la catégorie a des sous-catégories
      final subCategories = await getSubCategories(categoryId);
      if (subCategories.isNotEmpty) {
        throw Exception('Impossible de supprimer une catégorie qui a des sous-catégories');
      }

      await _firestore
          .collection('categories')
          .doc(categoryId)
          .update({
        'isActive': false,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la catégorie: ${e.toString()}');
    }
  }

  // Obtenir les catégories par type
  Future<List<CategoryModel>> getCategoriesByType(
    String entityId,
    CategoryType type,
  ) async {
    try {
      Query query = _firestore
          .collection('categories')
          .where('entityId', isEqualTo: entityId)
          .where('isActive', isEqualTo: true);

      if (type == CategoryType.both) {
        // Récupérer toutes les catégories
      } else {
        query = query.where('type', whereIn: [type.name, CategoryType.both.name]);
      }

      final querySnapshot = await query
          .orderBy('sortOrder')
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des catégories par type: ${e.toString()}');
    }
  }

  // Obtenir les sous-catégories d'une catégorie
  Future<List<CategoryModel>> getSubCategories(String parentCategoryId) async {
    try {
      final querySnapshot = await _firestore
          .collection('categories')
          .where('parentCategoryId', isEqualTo: parentCategoryId)
          .where('isActive', isEqualTo: true)
          .orderBy('sortOrder')
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des sous-catégories: ${e.toString()}');
    }
  }

  // Obtenir les catégories principales (sans parent)
  Future<List<CategoryModel>> getMainCategories(String entityId) async {
    try {
      final querySnapshot = await _firestore
          .collection('categories')
          .where('entityId', isEqualTo: entityId)
          .where('isActive', isEqualTo: true)
          .where('parentCategoryId', isNull: true)
          .orderBy('sortOrder')
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des catégories principales: ${e.toString()}');
    }
  }

  // Créer les catégories par défaut pour une nouvelle entité
  Future<List<CategoryModel>> createDefaultCategories(String entityId) async {
    try {
      final createdCategories = <CategoryModel>[];

      // Créer les catégories de dépenses par défaut
      for (final defaultCategory in DefaultCategories.expenseCategories) {
        final category = defaultCategory.copyWith(
          entityId: entityId,
          id: '', // Sera généré par Firestore
        );
        final created = await createCategory(category);
        createdCategories.add(created);
      }

      // Créer les catégories de revenus par défaut
      for (final defaultCategory in DefaultCategories.incomeCategories) {
        final category = defaultCategory.copyWith(
          entityId: entityId,
          id: '', // Sera généré par Firestore
        );
        final created = await createCategory(category);
        createdCategories.add(created);
      }

      return createdCategories;
    } catch (e) {
      throw Exception('Erreur lors de la création des catégories par défaut: ${e.toString()}');
    }
  }

  // Vérifier si le nom de catégorie existe déjà
  Future<bool> categoryNameExists(
    String name,
    String entityId, {
    String? excludeId,
    String? parentCategoryId,
  }) async {
    try {
      Query query = _firestore
          .collection('categories')
          .where('entityId', isEqualTo: entityId)
          .where('name', isEqualTo: name)
          .where('isActive', isEqualTo: true);

      if (parentCategoryId != null) {
        query = query.where('parentCategoryId', isEqualTo: parentCategoryId);
      } else {
        query = query.where('parentCategoryId', isNull: true);
      }

      final querySnapshot = await query.get();

      if (excludeId != null) {
        return querySnapshot.docs.any((doc) => doc.id != excludeId);
      }

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Erreur lors de la vérification du nom de la catégorie: ${e.toString()}');
    }
  }

  // Réorganiser l'ordre des catégories
  Future<void> reorderCategories(List<String> categoryIds) async {
    try {
      final batch = _firestore.batch();

      for (int i = 0; i < categoryIds.length; i++) {
        final categoryRef = _firestore.collection('categories').doc(categoryIds[i]);
        batch.update(categoryRef, {
          'sortOrder': i,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Erreur lors de la réorganisation des catégories: ${e.toString()}');
    }
  }

  // Stream des catégories en temps réel
  Stream<List<CategoryModel>> streamCategoriesByEntity(String entityId) {
    return _firestore
        .collection('categories')
        .where('entityId', isEqualTo: entityId)
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CategoryModel.fromFirestore(doc))
            .toList());
  }

  // Obtenir les statistiques des catégories
  Future<Map<String, dynamic>> getCategoryStats(String entityId) async {
    try {
      final categories = await getCategoriesByEntity(entityId);
      final totalCategories = categories.length;
      final incomeCategories = categories.where((c) => c.isIncomeCategory).length;
      final expenseCategories = categories.where((c) => c.isExpenseCategory).length;
      final subCategories = categories.where((c) => c.isSubCategory).length;
      final defaultCategories = categories.where((c) => c.isDefault).length;

      return {
        'totalCategories': totalCategories,
        'incomeCategories': incomeCategories,
        'expenseCategories': expenseCategories,
        'subCategories': subCategories,
        'defaultCategories': defaultCategories,
        'customCategories': totalCategories - defaultCategories,
      };
    } catch (e) {
      throw Exception('Erreur lors du calcul des statistiques des catégories: ${e.toString()}');
    }
  }

  // Rechercher des catégories
  Future<List<CategoryModel>> searchCategories(String entityId, String searchTerm) async {
    try {
      final allCategories = await getCategoriesByEntity(entityId);

      final searchTermLower = searchTerm.toLowerCase();

      return allCategories.where((category) {
        return category.name.toLowerCase().contains(searchTermLower) ||
               (category.description?.toLowerCase().contains(searchTermLower) ?? false);
      }).toList();
    } catch (e) {
      throw Exception('Erreur lors de la recherche de catégories: ${e.toString()}');
    }
  }
}