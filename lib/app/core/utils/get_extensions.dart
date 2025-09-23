import 'package:get/get.dart';

extension GetXSafeBack on GetInterface {
  void safeBack<T>({
    T? result,
    bool closeOverlays = false,
    bool canPop = true,
    int? id,
  }) async {
    while (Get.isSnackbarOpen) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    Get.back<T>(result: result, closeOverlays: closeOverlays, canPop: canPop, id: id);
  }
}
