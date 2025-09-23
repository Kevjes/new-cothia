class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Cothia';
  static const String appVersion = '1.0.0';

  // SharedPreferences Keys
  static const String keyIsFirstTime = 'is_first_time';
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUserId = 'user_id';
  static const String keyUserEmail = 'user_email';
  static const String keyPersonalEntityId = 'personal_entity_id';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String entitiesCollection = 'entities';
  static const String projectsCollection = 'projects';
  static const String transactionsCollection = 'transactions';
  static const String budgetsCollection = 'budgets';
  static const String accountsCollection = 'accounts';
  static const String habitsCollection = 'habits';
  static const String tasksCollection = 'tasks';

  // Entity Types
  static const String entityTypePersonal = 'personal';
  static const String entityTypeOrganization = 'organization';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;
  static const int maxDescriptionLength = 500;

  // Default Values
  static const String defaultPersonalEntityName = 'Personnel';
  static const String defaultCurrency = 'EUR';

  // Error Messages
  static const String genericErrorMessage = 'Une erreur s\'est produite. Veuillez réessayer.';
  static const String networkErrorMessage = 'Vérifiez votre connexion internet.';
  static const String authErrorMessage = 'Erreur d\'authentification.';
}