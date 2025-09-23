import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/account_model.dart';
import '../../../core/constants/app_constants.dart';

class AccountService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtenir tous les comptes d'une entité
  Future<List<AccountModel>> getAccountsByEntity(String entityId) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.accountsCollection)
          .where('entityId', isEqualTo: entityId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => AccountModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des comptes: ${e.toString()}');
    }
  }

  // Obtenir un compte par ID
  Future<AccountModel?> getAccountById(String accountId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.accountsCollection)
          .doc(accountId)
          .get();

      if (doc.exists) {
        return AccountModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération du compte: ${e.toString()}');
    }
  }

  // Créer un nouveau compte
  Future<AccountModel> createAccount(AccountModel account) async {
    try {
      final docRef = await _firestore
          .collection(AppConstants.accountsCollection)
          .add(account.toFirestore());

      return account.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Erreur lors de la création du compte: ${e.toString()}');
    }
  }

  // Mettre à jour un compte
  Future<AccountModel> updateAccount(AccountModel account) async {
    try {
      final updatedAccount = account.copyWith(updatedAt: DateTime.now());

      await _firestore
          .collection(AppConstants.accountsCollection)
          .doc(account.id)
          .update(updatedAccount.toFirestore());

      return updatedAccount;
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du compte: ${e.toString()}');
    }
  }

  // Supprimer un compte (soft delete)
  Future<void> deleteAccount(String accountId) async {
    try {
      await _firestore
          .collection(AppConstants.accountsCollection)
          .doc(accountId)
          .update({
        'isActive': false,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Erreur lors de la suppression du compte: ${e.toString()}');
    }
  }

  // Mettre à jour le solde d'un compte
  Future<void> updateAccountBalance({
    required String accountId,
    required double newBalance,
    double? projectedBalance,
  }) async {
    try {
      final updateData = {
        'currentBalance': newBalance,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (projectedBalance != null) {
        updateData['projectedBalance'] = projectedBalance;
      }

      await _firestore
          .collection(AppConstants.accountsCollection)
          .doc(accountId)
          .update(updateData);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du solde: ${e.toString()}');
    }
  }

  // Obtenir le total des comptes par type
  Future<Map<AccountType, double>> getBalanceByType(String entityId) async {
    try {
      final accounts = await getAccountsByEntity(entityId);
      final balanceMap = <AccountType, double>{};

      for (final type in AccountType.values) {
        final typeAccounts = accounts.where((account) => account.type == type);
        final totalBalance = typeAccounts.fold<double>(
          0.0,
          (sum, account) => sum + account.currentBalance,
        );
        balanceMap[type] = totalBalance;
      }

      return balanceMap;
    } catch (e) {
      throw Exception('Erreur lors du calcul des soldes par type: ${e.toString()}');
    }
  }

  // Obtenir le patrimoine total
  Future<double> getTotalWealth(String entityId) async {
    try {
      final accounts = await getAccountsByEntity(entityId);
      return accounts.fold<double>(
        0.0,
        (sum, account) => sum + account.currentBalance,
      );
    } catch (e) {
      throw Exception('Erreur lors du calcul du patrimoine total: ${e.toString()}');
    }
  }

  // Stream des comptes en temps réel
  Stream<List<AccountModel>> streamAccountsByEntity(String entityId) {
    return _firestore
        .collection(AppConstants.accountsCollection)
        .where('entityId', isEqualTo: entityId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AccountModel.fromFirestore(doc))
            .toList());
  }

  // Vérifier si le nom du compte existe déjà
  Future<bool> accountNameExists(String name, String entityId, {String? excludeId}) async {
    try {
      Query query = _firestore
          .collection(AppConstants.accountsCollection)
          .where('entityId', isEqualTo: entityId)
          .where('name', isEqualTo: name)
          .where('isActive', isEqualTo: true);

      final querySnapshot = await query.get();

      if (excludeId != null) {
        return querySnapshot.docs.any((doc) => doc.id != excludeId);
      }

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Erreur lors de la vérification du nom du compte: ${e.toString()}');
    }
  }

  // Créer des comptes par défaut pour une nouvelle entité
  Future<List<AccountModel>> createDefaultAccounts(String entityId) async {
    try {
      final now = DateTime.now();
      final defaultAccounts = [
        AccountModel(
          id: '',
          name: 'Compte Courant',
          type: AccountType.checking,
          entityId: entityId,
          initialBalance: 0.0,
          currentBalance: 0.0,
          projectedBalance: 0.0,
          description: 'Compte courant principal',
          createdAt: now,
          updatedAt: now,
        ),
        AccountModel(
          id: '',
          name: 'Épargne',
          type: AccountType.savings,
          entityId: entityId,
          initialBalance: 0.0,
          currentBalance: 0.0,
          projectedBalance: 0.0,
          description: 'Compte d\'épargne',
          createdAt: now,
          updatedAt: now,
        ),
        AccountModel(
          id: '',
          name: 'Espèces',
          type: AccountType.cash,
          entityId: entityId,
          initialBalance: 0.0,
          currentBalance: 0.0,
          projectedBalance: 0.0,
          description: 'Argent liquide',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final createdAccounts = <AccountModel>[];
      for (final account in defaultAccounts) {
        final created = await createAccount(account);
        createdAccounts.add(created);
      }

      return createdAccounts;
    } catch (e) {
      throw Exception('Erreur lors de la création des comptes par défaut: ${e.toString()}');
    }
  }

  // Obtenir les statistiques des comptes
  Future<Map<String, dynamic>> getAccountStats(String entityId) async {
    try {
      final accounts = await getAccountsByEntity(entityId);
      final totalAccounts = accounts.length;
      final totalBalance = accounts.fold<double>(0.0, (sum, acc) => sum + acc.currentBalance);
      final totalProjected = accounts.fold<double>(0.0, (sum, acc) => sum + acc.projectedBalance);

      final activeAccounts = accounts.where((acc) => acc.currentBalance != 0).length;
      final balanceByType = await getBalanceByType(entityId);

      return {
        'totalAccounts': totalAccounts,
        'activeAccounts': activeAccounts,
        'totalBalance': totalBalance,
        'totalProjected': totalProjected,
        'balanceByType': balanceByType,
        'averageBalance': totalAccounts > 0 ? totalBalance / totalAccounts : 0.0,
      };
    } catch (e) {
      throw Exception('Erreur lors du calcul des statistiques: ${e.toString()}');
    }
  }
}