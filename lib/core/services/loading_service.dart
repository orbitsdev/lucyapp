import 'package:get/get.dart';
import 'package:bettingapp/widgets/common/modal.dart';

class LoadingService extends GetxService {
  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  /// Shows a loading modal with the given message
  void showLoading({String title = 'Loading', String message = 'Please wait...'}) {
    if (!_isLoading.value) {
      _isLoading.value = true;
      Modal.showProgressModal(
        title: title,
        message: message,
      );
    }
  }

  /// Hides the loading modal
  void hideLoading() {
    if (_isLoading.value) {
      _isLoading.value = false;
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    }
  }

  /// Executes an async function while showing a loading modal
  /// Returns the result of the function
  Future<T> wrapWithLoading<T>({
    required Future<T> Function() asyncFunction,
    String title = 'Loading',
    String message = 'Please wait...',
  }) async {
    try {
      showLoading(title: title, message: message);
      final result = await asyncFunction();
      return result;
    } finally {
      hideLoading();
    }
  }
}
