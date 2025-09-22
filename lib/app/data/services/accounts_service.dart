import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../features/finance/models/account_model.dart';
import '../../features/finance/models/currency.dart';
import 'auth_service.dart';

class AccountsService extends GetxService {
  static AccountsService get to => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService.to;

  String get _userId => _authService.currentUser?.id ?? '';
  String get _accountsCollection => 'users/$_userId/accounts';

  // Créer un compte
  Future<String?> createAccount({
    required String name,
    required String description,
    required Currency currency,
    required double balance,
    required String icon,
    required String color,
  }) async {
    try {
      if (_userId.isEmpty) throw Exception('Utilisateur non connecté');

      final account = AccountModel(
        id: '', // Sera généré par Firestore
        name: name,
        description: description,
        currency: currency,
        balance: balance,
        icon: icon,
        color: color,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        userId: _userId,
      );

      final docRef = await _firestore
          .collection(_accountsCollection)
          .add(account.toMap());

      return docRef.id;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de créer le compte: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  // Récupérer tous les comptes
  Stream<List<AccountModel>> getAccountsStream() {
    if (_userId.isEmpty) return Stream.value([]);

    return _firestore
        .collection(_accountsCollection)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AccountModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Récupérer tous les comptes une seule fois
  Future<List<AccountModel>> getAccounts() async {
    try {
      if (_userId.isEmpty) return [];

      final snapshot = await _firestore
          .collection(_accountsCollection)
          .orderBy('createdAt', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => AccountModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de récupérer les comptes: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return [];
    }
  }

  // Récupérer un compte par ID
  Future<AccountModel?> getAccountById(String accountId) async {
    try {
      if (_userId.isEmpty) return null;

      final doc = await _firestore
          .collection(_accountsCollection)
          .doc(accountId)
          .get();

      if (doc.exists && doc.data() != null) {
        return AccountModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de récupérer le compte: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  // Mettre à jour un compte
  Future<bool> updateAccount({
    required String accountId,
    required String name,
    required String description,
    required Currency currency,
    required String icon,
    required String color,
  }) async {
    try {
      if (_userId.isEmpty) throw Exception('Utilisateur non connecté');

      await _firestore
          .collection(_accountsCollection)
          .doc(accountId)
          .update({
        'name': name,
        'description': description,
        'currency': currency.toMap(),
        'icon': icon,
        'color': color,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de mettre à jour le compte: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // Mettre à jour le solde d'un compte
  Future<bool> updateAccountBalance({
    required String accountId,
    required double newBalance,
  }) async {
    try {
      if (_userId.isEmpty) throw Exception('Utilisateur non connecté');

      await _firestore
          .collection(_accountsCollection)
          .doc(accountId)
          .update({
        'balance': newBalance,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de mettre à jour le solde: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // Supprimer un compte
  Future<bool> deleteAccount(String accountId) async {
    try {
      if (_userId.isEmpty) throw Exception('Utilisateur non connecté');

      // Vérifier s'il y a des transactions liées à ce compte
      final transactionsQuery = await _firestore
          .collection('users/$_userId/transactions')
          .where('accountId', isEqualTo: accountId)
          .limit(1)
          .get();

      if (transactionsQuery.docs.isNotEmpty) {
        Get.snackbar(
          'Impossible de supprimer',
          'Ce compte contient des transactions. Supprimez-les d\'abord.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      await _firestore
          .collection(_accountsCollection)
          .doc(accountId)
          .delete();

      return true;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de supprimer le compte: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // Définir un compte comme compte par défaut
  Future<bool> setDefaultAccount(String accountId) async {
    try {
      if (_userId.isEmpty) throw Exception('Utilisateur non connecté');

      // Enlever le statut par défaut de tous les comptes
      final batch = _firestore.batch();

      final accounts = await _firestore
          .collection(_accountsCollection)
          .get();

      for (final doc in accounts.docs) {
        batch.update(doc.reference, {'isDefault': false});
      }

      // Définir le nouveau compte par défaut
      final accountRef = _firestore
          .collection(_accountsCollection)
          .doc(accountId);

      batch.update(accountRef, {
        'isDefault': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      return true;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de définir le compte par défaut: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // Récupérer le compte par défaut
  Future<AccountModel?> getDefaultAccount() async {
    try {
      if (_userId.isEmpty) return null;

      final snapshot = await _firestore
          .collection(_accountsCollection)
          .where('isDefault', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        return AccountModel.fromMap(doc.data(), doc.id);
      }

      // Si aucun compte par défaut, récupérer le premier compte
      final allAccounts = await getAccounts();
      if (allAccounts.isNotEmpty) {
        await setDefaultAccount(allAccounts.first.id);
        return allAccounts.first;
      }

      return null;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de récupérer le compte par défaut: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  // Vérifier si un nom de compte existe déjà
  Future<bool> accountNameExists(String name, {String? excludeId}) async {
    try {
      if (_userId.isEmpty) return false;

      var query = _firestore
          .collection(_accountsCollection)
          .where('name', isEqualTo: name);

      final snapshot = await query.get();

      if (excludeId != null) {
        return snapshot.docs.any((doc) => doc.id != excludeId);
      }

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Obtenir les statistiques des comptes
  Future<Map<String, dynamic>> getAccountsStats() async {
    try {
      if (_userId.isEmpty) return {};

      final accounts = await getAccounts();

      double totalBalance = 0;
      int positiveAccounts = 0;
      int negativeAccounts = 0;
      int zeroAccounts = 0;

      for (final account in accounts) {
        totalBalance += account.balance;
        if (account.balance > 0) {
          positiveAccounts++;
        } else if (account.balance < 0) {
          negativeAccounts++;
        } else {
          zeroAccounts++;
        }
      }

      return {
        'totalAccounts': accounts.length,
        'totalBalance': totalBalance,
        'positiveAccounts': positiveAccounts,
        'negativeAccounts': negativeAccounts,
        'zeroAccounts': zeroAccounts,
        'averageBalance': accounts.isNotEmpty ? totalBalance / accounts.length : 0,
      };
    } catch (e) {
      return {};
    }
  }
}