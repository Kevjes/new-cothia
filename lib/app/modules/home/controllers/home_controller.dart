import 'package:get/get.dart';

class HomeController extends GetxController {
  static HomeController get to => Get.find<HomeController>();

  final _currentIndex = 0.obs;
  int get currentIndex => _currentIndex.value;

  void changeTabIndex(int index) {
    _currentIndex.value = index;
  }

  // Getters pour déterminer quel module afficher
  bool get isHomeTab => _currentIndex.value == 0;
  bool get isFinanceTab => _currentIndex.value == 1;
  bool get isHabitsTab => _currentIndex.value == 2;
  bool get isTasksTab => _currentIndex.value == 3;
  bool get isProjectsTab => _currentIndex.value == 4;

  String get currentTabTitle {
    switch (_currentIndex.value) {
      case 0:
        return 'Cothia';
      case 1:
        return 'Finance';
      case 2:
        return 'Habitudes';
      case 3:
        return 'Tâches';
      case 4:
        return 'Projets';
      default:
        return 'Cothia';
    }
  }
}
