import 'package:get/get.dart';
import 'package:bettingapp/routes/app_routes.dart';

class LoginController extends GetxController {
  var username = ''.obs;
  var password = ''.obs;
  var loading = false.obs;
  var showPassword = false.obs;

  void togglePasswordVisibility() {
    showPassword.value = !showPassword.value;
  }

  void login() async {
    if (username.isEmpty || password.isEmpty) {
      Get.snackbar(
        "Error", 
        "Please enter username and password",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.8),
        colorText: Get.theme.colorScheme.onError,
      );
      return;
    }
    
    loading.value = true;
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    loading.value = false;
    
    // Navigate based on role (default to teller dashboard)
    Get.offAllNamed(AppRoutes.tellerDashboard);
  }
}
