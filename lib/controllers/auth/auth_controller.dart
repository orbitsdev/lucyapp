import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:bettingapp/routes/app_routes.dart';

class AuthController extends GetxController {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  final RxString selectedRole = 'Teller'.obs;
  final RxBool isLoading = false.obs;
  final RxBool rememberMe = false.obs;
  
  void setRole(String role) {
    selectedRole.value = role;
  }
  
  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
  }
  
  Future<void> login() async {
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter both username and password',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    isLoading.value = true;
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // For demo purposes, allow any username and password
      // Remove this condition for production and implement proper authentication
      if (true) {
        // Navigate based on role
        switch (selectedRole.value) {
          case 'Coordinator':
            Get.offAllNamed(AppRoutes.coordinatorDashboard);
            break;
          case 'Teller':
            Get.offAllNamed(AppRoutes.tellerDashboard);
            break;
          case 'Customer':
            Get.offAllNamed(AppRoutes.customerDashboard);
            break;
          default:
            Get.offAllNamed(AppRoutes.tellerDashboard);
        }
      }
      // Demo mode: Authentication always succeeds
      // Uncomment for production use:
      /*
      else {
        Get.snackbar(
          'Error',
          'Invalid username or password',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
      */
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred during login',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
