import 'package:get/get.dart';
import '../controllers/suggestions_controller.dart';
import '../../../core/services/suggestions_service.dart';

class SuggestionsBinding extends Bindings {
  @override
  void dependencies() {
    // Register the service first
    Get.lazyPut<SuggestionsService>(
      () => SuggestionsService(),
      fenix: true,
    );

    // Register the controller
    Get.lazyPut<SuggestionsController>(
      () => SuggestionsController(),
    );
  }
}