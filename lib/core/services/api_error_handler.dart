import 'package:bettingapp/models/api_error.dart';
import 'package:bettingapp/widgets/common/modal.dart';
import 'package:get/get.dart';

class ApiErrorHandler {
  /// Handles API errors and shows appropriate modals based on error type
  static void handleError(ApiError error, {Function? onRetry}) {
    // Close any existing dialogs first
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
    
    switch (error.code) {
      case 'no_connection':
        Modal.showNoInternetModal(
          onRetry: onRetry != null ? () => onRetry() : null,
        );
        break;
        
      case 'timeout':
        Modal.showErrorModal(
          title: 'Request Timeout',
          message: 'The server took too long to respond. Please try again.',
          onClose: onRetry != null ? () => onRetry() : null,
        );
        break;
        
      case 'unauthorized':
        Modal.showErrorModal(
          title: 'Session Expired',
          message: 'Your session has expired. Please log in again.',
          onClose: () {
            // Navigate to login screen
            Get.offAllNamed('/login');
          },
        );
        break;
        
      case 'validation_error':
        String errorMessage = error.message;
        
        // Extract validation errors if available
        if (error.data != null && 
            error.data is Map && 
            error.data.containsKey('errors')) {
          final errors = error.data['errors'];
          if (errors is Map && errors.isNotEmpty) {
            // Get the first error message
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              errorMessage = firstError.first.toString();
            }
          }
        }
        
        Modal.showErrorModal(
          title: 'Validation Error',
          message: errorMessage,
        );
        break;
        
      case 'server_error':
        Modal.showErrorModal(
          title: 'Server Error',
          message: 'Something went wrong on our server. Please try again later.',
        );
        break;
        
      default:
        Modal.showErrorModal(
          title: 'Error',
          message: error.message,
          onClose: onRetry != null ? () => onRetry() : null,
        );
        break;
    }
  }
  
  /// Handles API results using the Either pattern from fpdart
  static void handleApiResult<T>({
    required dynamic result,
    required Function(T) onSuccess,
    Function? onError,
    Function? onRetry,
  }) {
    result.fold(
      (ApiError error) {
        handleError(error, onRetry: onRetry);
        if (onError != null) onError();
      },
      (T data) => onSuccess(data),
    );
  }
}
