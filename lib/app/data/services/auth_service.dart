import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/entity_model.dart';
import '../../core/constants/app_constants.dart';
import 'storage_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StorageService? _storageService;

  AuthService();

  Future<StorageService> _getStorageService() async {
    _storageService ??= await StorageService.getInstance();
    return _storageService!;
  }

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Create personal entity
        final personalEntity = await _createPersonalEntity(userCredential.user!.uid);

        // Create user document in Firestore
        final userModel = UserModel(
          id: userCredential.user!.uid,
          email: email,
          personalEntityId: personalEntity.id,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _createUserDocument(userModel);

        // Save to local storage
        final storageService = await _getStorageService();
        await storageService.saveUserSession(
          userId: userModel.id,
          email: userModel.email,
          personalEntityId: userModel.personalEntityId,
        );
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Erreur lors de la création du compte: ${e.toString()}');
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Get user data from Firestore
        final userDoc = await _firestore
            .collection(AppConstants.usersCollection)
            .doc(userCredential.user!.uid)
            .get();

        if (userDoc.exists) {
          final userModel = UserModel.fromFirestore(userDoc);

          // Save to local storage
          final storageService = await _getStorageService();
          await storageService.saveUserSession(
            userId: userModel.id,
            email: userModel.email,
            personalEntityId: userModel.personalEntityId,
          );
        }
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Erreur lors de la connexion: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      final storageService = await _getStorageService();
      await storageService.clearAuthData();
    } catch (e) {
      throw Exception('Erreur lors de la déconnexion: ${e.toString()}');
    }
  }

  // Create personal entity for new user
  Future<EntityModel> _createPersonalEntity(String userId) async {
    try {
      final personalEntity = EntityModel.createPersonal(ownerId: userId);

      final docRef = await _firestore
          .collection(AppConstants.entitiesCollection)
          .add(personalEntity.toFirestore());

      return personalEntity.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Erreur lors de la création de l\'entité personnelle: ${e.toString()}');
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(UserModel user) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.id)
          .set(user.toFirestore());
    } catch (e) {
      throw Exception('Erreur lors de la création du profil utilisateur: ${e.toString()}');
    }
  }

  // Get current user data
  Future<UserModel?> getCurrentUserData() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des données utilisateur: ${e.toString()}');
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? displayName,
  }) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('Utilisateur non connecté');

      // Update Firebase Auth profile
      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }

      // Update Firestore document
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .update({
        'displayName': displayName,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du profil: ${e.toString()}');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Erreur lors de l\'envoi de l\'email de réinitialisation: ${e.toString()}');
    }
  }

  // Check if user is authenticated and has valid session
  Future<bool> isAuthenticated() async {
    try {
      final storageService = await _getStorageService();
      final hasValidSession = storageService.hasValidSession();
      final isFirebaseAuthenticated = currentUser != null;

      return hasValidSession && isFirebaseAuthenticated;
    } catch (e) {
      return false;
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Le mot de passe est trop faible.';
      case 'email-already-in-use':
        return 'Un compte existe déjà avec cette adresse email.';
      case 'user-not-found':
        return 'Aucun utilisateur trouvé avec cette adresse email.';
      case 'wrong-password':
        return 'Mot de passe incorrect.';
      case 'invalid-email':
        return 'Adresse email invalide.';
      case 'user-disabled':
        return 'Ce compte utilisateur a été désactivé.';
      case 'too-many-requests':
        return 'Trop de tentatives. Veuillez réessayer plus tard.';
      case 'operation-not-allowed':
        return 'Cette opération n\'est pas autorisée.';
      default:
        return 'Erreur d\'authentification: ${e.message}';
    }
  }
}