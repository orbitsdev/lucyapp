import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bettingapp/utils/app_colors.dart';
import 'package:bettingapp/widgets/common/local_lottie_image.dart';

class Modal {
  // Animation paths
  static const String _defaultErrorAnimation = 'assets/animations/error.json';
  static const String _defaultSuccessAnimation = 'assets/animations/success.json';
  static const String _defaultConfirmationAnimation = 'assets/animations/questionmark.json';
  static const String _defaultNoInternetAnimation = 'assets/animations/no-internet.json';
  static const String _defaultLoadingAnimation = 'assets/animations/loading_animation.json';

  // Default styles
  static final _defaultDialogShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16.r),
  );
  
  static const _dialogBackgroundColor = Colors.white;
  
  static final _defaultButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryRed,
    foregroundColor: Colors.white,
    minimumSize: Size(double.infinity, 45.h),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.r),
    ),
  );
  
  static final _defaultOutlineButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: Colors.grey[700],
    side: BorderSide(color: Colors.grey[400]!),
    minimumSize: Size(0, 45.h),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.r),
    ),
  );

  static final _titleStyle = TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.bold,
  );

  static final _messageStyle = TextStyle(
    fontSize: 14.sp,
    color: Colors.grey[700],
  );

  static final _buttonTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 14.sp,
  );

  // 1. Success Modal - Auto dismisses after a duration
  static void showSuccessModal({
    String title = 'Success',
    String message = 'Operation completed successfully.',
    String animation = _defaultSuccessAnimation,
    VoidCallback? onClose,
    Duration duration = const Duration(seconds: 2),
    bool showButton = false,
    String buttonText = 'OK',
  }) {
    Get.dialog(
      Dialog(
        backgroundColor: _dialogBackgroundColor,
        shape: _defaultDialogShape,
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LocalLottieImage(
                path: animation,
                width: 100.w,
                height: 100.w,
                repeat: false,
              ),
              SizedBox(height: 16.h),
              Text(title, style: _titleStyle),
              SizedBox(height: 8.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: _messageStyle,
              ),
              if (showButton) ...[  
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                    if (onClose != null) onClose();
                  },
                  style: _defaultButtonStyle,
                  child: Text(buttonText, style: _buttonTextStyle),
                ),
              ],
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
    
    // Auto dismiss if no button is shown
    if (!showButton) {
      Future.delayed(duration, () {
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }
        if (onClose != null) {
          onClose();
        }
      });
    }
  }

  // 2. Error Modal - Shows an error message with a close button
  static void showErrorModal({
    String title = 'Error',
    String message = 'An error occurred.',
    String animation = _defaultErrorAnimation,
    VoidCallback? onClose,
    String buttonText = 'Close',
  }) {
    Get.dialog(
      Dialog(
        backgroundColor: _dialogBackgroundColor,
        shape: _defaultDialogShape,
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LocalLottieImage(
                path: animation,
                width: 100.w,
                height: 100.w,
                repeat: false,
              ),
              SizedBox(height: 16.h),
              Text(
                title,
                style: _titleStyle.copyWith(color: Colors.red[700]),
              ),
              SizedBox(height: 8.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: _messageStyle,
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  if (onClose != null) onClose();
                },
                style: _defaultButtonStyle,
                child: Text(buttonText, style: _buttonTextStyle),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  // 3. Confirmation Modal - Asks for confirmation with cancel/confirm buttons
  static void showConfirmationModal({
    String title = 'Confirmation',
    String message = 'Are you sure you want to proceed?',
    String animation = _defaultConfirmationAnimation,
    String cancelText = 'Cancel',
    String confirmText = 'Confirm',
    VoidCallback? onCancel,
    VoidCallback? onConfirm,
    bool isDangerousAction = false,
  }) {
    Get.dialog(
      Dialog(
        backgroundColor: _dialogBackgroundColor,
        shape: _defaultDialogShape,
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LocalLottieImage(
                path: animation,
                width: 100.w,
                height: 100.w,
                repeat: true,
              ),
              SizedBox(height: 16.h),
              Text(title, style: _titleStyle),
              SizedBox(height: 8.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: _messageStyle,
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back();
                        if (onCancel != null) onCancel();
                      },
                      style: _defaultOutlineButtonStyle,
                      child: Text(
                        cancelText,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        if (onConfirm != null) onConfirm();
                      },
                      style: isDangerousAction
                          ? _defaultButtonStyle.copyWith(
                              backgroundColor: WidgetStateProperty.all(Colors.red[700]))
                          : _defaultButtonStyle,
                      child: Text(confirmText, style: _buttonTextStyle),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // 4. Info Modal - Shows information with an OK button
  static void showInfoModal({
    String title = 'Information',
    String message = 'Information',
    String animation = _defaultSuccessAnimation,
    VoidCallback? onClose,
    String buttonText = 'OK',
  }) {
    Get.dialog(
      Dialog(
        backgroundColor: _dialogBackgroundColor,
        shape: _defaultDialogShape,
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LocalLottieImage(
                path: animation,
                width: 100.w,
                height: 100.w,
                repeat: false,
              ),
              SizedBox(height: 16.h),
              Text(title, style: _titleStyle),
              SizedBox(height: 8.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: _messageStyle,
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  if (onClose != null) onClose();
                },
                style: _defaultButtonStyle,
                child: Text(buttonText, style: _buttonTextStyle),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  // 5. Progress Modal - Shows a loading indicator with a message
  static void showProgressModal({
    String title = 'Progress',
    String message = 'Please wait...',
    String animation = _defaultLoadingAnimation,
    bool showAnimation = true,
  }) {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          backgroundColor: _dialogBackgroundColor,
          shape: _defaultDialogShape,
          child: Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showAnimation) ...[  
                  LocalLottieImage(
                    path: animation,
                    width: 100.w,
                    height: 100.w,
                    repeat: true,
                  ),
                  SizedBox(height: 16.h),
                ],
                Text(title, style: _titleStyle),
                SizedBox(height: 8.h),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: _messageStyle,
                ),
                SizedBox(height: 16.h),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryRed),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // 6. Custom Modal - Allows for a completely custom modal with provided content
  static void showCustomModal({
    required Widget content,
    bool barrierDismissible = true,
    BorderRadius? borderRadius,
    Color backgroundColor = Colors.white,
    EdgeInsets contentPadding = const EdgeInsets.all(20),
  }) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(16.r),
        ),
        backgroundColor: backgroundColor != Colors.white ? backgroundColor : _dialogBackgroundColor,
        child: Padding(
          padding: contentPadding.r,
          child: content,
        ),
      ),
      barrierDismissible: barrierDismissible,
    );
  }

  // 7. No Internet Modal - Shows when there's no internet connection
  static void showNoInternetModal({
    String title = 'No Internet Connection',
    String message = 'Please check your internet connection and try again.',
    VoidCallback? onRetry,
    String retryText = 'Retry',
  }) {
    Get.dialog(
      Dialog(
        shape: _defaultDialogShape,
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LocalLottieImage(
                path: _defaultNoInternetAnimation,
                width: 120.w,
                height: 120.w,
                repeat: true,
              ),
              SizedBox(height: 16.h),
              Text(title, style: _titleStyle),
              SizedBox(height: 8.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: _messageStyle,
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  if (onRetry != null) onRetry();
                },
                style: _defaultButtonStyle,
                child: Text(retryText, style: _buttonTextStyle),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  // Helper method to close any open dialog
  static void closeDialog() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }
}