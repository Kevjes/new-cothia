import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../features/auth/models/user_model.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find<AuthService>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late SharedPreferences _prefs;

  final _currentUser = Rxn<UserModel>();
  final _isLoading = false.obs;

  UserModel? get currentUser => _currentUser.value;
  bool get isLoading => _isLoading.value;
  bool get isLoggedIn => _currentUser.value != null;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initPrefs();
    _setupAuthListener();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  void _setupAuthListener() {
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        await _loadUserData(user);
      } else {
        _currentUser.value = null;
        await _clearUserData();
      }
    });
  }

  Future<void> _loadUserData(User user) async {
    try {
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        _currentUser.value = UserModel.fromJson({
          'id': user.uid,
          ...userDoc.data()!,
        });
      } else {
        final newUser = UserModel(
          id: user.uid,
          email: user.email!,
          displayName: user.displayName,
          photoURL: user.photoURL,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .set(newUser.toJson());

        _currentUser.value = newUser;
      }

      await _prefs.setString(AppConstants.userIdKey, user.uid);
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors du chargement des données utilisateur');
    }
  }

  Future<void> _clearUserData() async {
    await _prefs.remove(AppConstants.userIdKey);
    await _prefs.remove(AppConstants.userTokenKey);
  }

  Future<bool> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      _isLoading.value = true;

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null && displayName != null) {
        await credential.user!.updateDisplayName(displayName);
      }

      return true;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return false;
    } catch (e) {
      Get.snackbar('Erreur', 'Une erreur inattendue s\'est produite');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading.value = true;

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _updateLastLogin();
      return true;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return false;
    } catch (e) {
      Get.snackbar('Erreur', 'Une erreur inattendue s\'est produite');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> resetPassword({required String email}) async {
    try {
      _isLoading.value = true;

      await _auth.sendPasswordResetEmail(email: email);
      Get.snackbar(
        'Email envoyé',
        'Un email de réinitialisation a été envoyé à $email',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return false;
    } catch (e) {
      Get.snackbar('Erreur', 'Une erreur inattendue s\'est produite');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading.value = true;
      await _auth.signOut();
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la déconnexion');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _updateLastLogin() async {
    if (_currentUser.value != null) {
      try {
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(_currentUser.value!.id)
            .update({
          'lastLoginAt': DateTime.now().toIso8601String(),
        });

        _currentUser.value = _currentUser.value!.copyWith(
          lastLoginAt: DateTime.now(),
        );
      } catch (e) {
        print('Erreur lors de la mise à jour de la dernière connexion: $e');
      }
    }
  }

  void _handleAuthError(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'user-not-found':
        message = 'Aucun utilisateur trouvé avec cet email';
        break;
      case 'wrong-password':
        message = 'Mot de passe incorrect';
        break;
      case 'email-already-in-use':
        message = 'Cet email est déjà utilisé';
        break;
      case 'weak-password':
        message = 'Le mot de passe est trop faible';
        break;
      case 'invalid-email':
        message = 'Email invalide';
        break;
      case 'user-disabled':
        message = 'Ce compte a été désactivé';
        break;
      case 'too-many-requests':
        message = 'Trop de tentatives. Réessayez plus tard';
        break;
      default:
        message = 'Erreur d\'authentification: ${e.message}';
    }
    Get.snackbar('Erreur', message, snackPosition: SnackPosition.BOTTOM);
  }
}