import 'package:get/get.dart';
import 'bindings/habits_binding.dart';
import 'views/pages/habits_main_page.dart';
import 'views/pages/habits_list_page.dart';
import 'views/pages/habit_form_page.dart';
import 'views/pages/habit_details_page.dart';
import 'views/pages/routines_list_page.dart';
import 'views/pages/routine_form_page.dart';
import 'views/pages/routine_details_page.dart';
import 'views/pages/routine_start_page.dart';

class HabitsModule {
  static const String mainRoute = '/habits';
  static const String listRoute = '/habits/list';
  static const String createRoute = '/habits/create';
  static const String editRoute = '/habits/edit';
  static const String detailsRoute = '/habits/details';
  static const String routinesRoute = '/habits/routines';
  static const String routinesCreateRoute = '/habits/routines/create';
  static const String routinesEditRoute = '/habits/routines/edit';
  static const String routinesDetailsRoute = '/habits/routines/details';
  static const String routinesStartRoute = '/habits/routines/start';
  static const String analyticsRoute = '/habits/analytics';
  static const String suggestionsRoute = '/habits/suggestions';
  static const String settingsRoute = '/habits/settings';
  static const String todayRoute = '/habits/today';
  static const String historyRoute = '/habits/history';

  static List<GetPage> routes = [
    // Main habits routes
    GetPage(
      name: mainRoute,
      page: () => const HabitsMainPage(),
      binding: HabitsBinding(),
    ),
    GetPage(
      name: listRoute,
      page: () => const HabitsListPage(),
      binding: HabitsBinding(),
    ),
    GetPage(
      name: createRoute,
      page: () => const HabitFormPage(),
      binding: HabitsBinding(),
    ),
    GetPage(
      name: editRoute,
      page: () => const HabitFormPage(),
      binding: HabitsDetailBinding(),
    ),
    GetPage(
      name: detailsRoute,
      page: () => const HabitDetailsPage(),
      binding: HabitsDetailBinding(),
    ),

    // Routines routes
    GetPage(
      name: routinesRoute,
      page: () => const RoutinesListPage(),
      binding: HabitsBinding(),
    ),
    GetPage(
      name: routinesCreateRoute,
      page: () => const RoutineFormPage(),
      binding: HabitsBinding(),
    ),
    GetPage(
      name: routinesEditRoute,
      page: () => const RoutineFormPage(),
      binding: RoutinesDetailBinding(),
    ),
    GetPage(
      name: routinesDetailsRoute,
      page: () => const RoutineDetailsPage(),
      binding: RoutinesDetailBinding(),
    ),
    GetPage(
      name: routinesStartRoute,
      page: () => const RoutineStartPage(),
      binding: RoutinesDetailBinding(),
    ),

    // Additional pages - redirect to main for now
    GetPage(
      name: analyticsRoute,
      page: () => const HabitsMainPage(),
      binding: HabitsBinding(),
    ),
    GetPage(
      name: suggestionsRoute,
      page: () => const HabitsMainPage(),
      binding: HabitsBinding(),
    ),
    GetPage(
      name: settingsRoute,
      page: () => const HabitsMainPage(),
      binding: HabitsBinding(),
    ),
    GetPage(
      name: todayRoute,
      page: () => const HabitsListPage(),
      binding: HabitsBinding(),
    ),
    GetPage(
      name: historyRoute,
      page: () => const HabitDetailsPage(),
      binding: HabitsDetailBinding(),
    ),
  ];

  // Navigation helpers
  static void toMain() => Get.toNamed(mainRoute);
  static void toList() => Get.toNamed(listRoute);
  static void toCreate() => Get.toNamed(createRoute);
  static void toEdit(String habitId) => Get.toNamed(editRoute, arguments: habitId);
  static void toDetails(String habitId) => Get.toNamed(detailsRoute, arguments: habitId);
  static void toRoutines() => Get.toNamed(routinesRoute);
  static void toRoutineCreate() => Get.toNamed(routinesCreateRoute);
  static void toRoutineEdit(String routineId) => Get.toNamed(routinesEditRoute, arguments: routineId);
  static void toRoutineDetails(String routineId) => Get.toNamed(routinesDetailsRoute, arguments: routineId);
  static void toRoutineStart(String routineId) => Get.toNamed(routinesStartRoute, arguments: routineId);
  static void toAnalytics() => Get.toNamed(analyticsRoute);
  static void toSuggestions() => Get.toNamed(suggestionsRoute);
  static void toSettings() => Get.toNamed(settingsRoute);
  static void toToday() => Get.toNamed(todayRoute);
  static void toHistory(String habitId) => Get.toNamed(historyRoute, arguments: habitId);
}