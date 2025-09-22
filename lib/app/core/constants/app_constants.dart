class AppConstants {
  static const String appName = 'Cothia';
  static const String appVersion = '1.0.0';

  // Routes
  static const String initialRoute = '/';
  static const String authRoute = '/auth';
  static const String homeRoute = '/home';
  static const String profileRoute = '/profile';
  static const String habitsRoute = '/habits';
  static const String tasksRoute = '/tasks';
  static const String financeRoute = '/finance';
  static const String projectsRoute = '/projects';

  // SharedPreferences keys
  static const String themeKey = 'theme_mode';
  static const String isFirstLaunchKey = 'is_first_launch';
  static const String userTokenKey = 'user_token';
  static const String userIdKey = 'user_id';

  // Firebase collections
  static const String usersCollection = 'users';
  static const String habitsCollection = 'habits';
  static const String tasksCollection = 'tasks';
  static const String financeCollection = 'finance';
  static const String projectsCollection = 'projects';

  // Animation durations
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration pageTransitionDuration = Duration(milliseconds: 250);
}