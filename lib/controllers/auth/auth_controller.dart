import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:bettingapp/routes/app_routes.dart';
import 'package:bettingapp/core/dio/dio_base.dart';
import 'package:bettingapp/config/api_config.dart';
import 'package:bettingapp/models/user.dart';
import 'package:bettingapp/widgets/common/modal.dart';

class AuthController extends GetxController {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  final DioService _dioService = DioService();
  final Rx<User?> user = Rx<User?>(null);
  final RxString selectedRole = 'Teller'.obs;
  final RxBool isLoading = false.obs;
  final RxBool rememberMe = true.obs;
  
  bool get isLoggedIn => user.value != null;
  String? get userRole => user.value?.role;
  
  @override
  void onInit() {
    super.onInit();
    // Pre-fill credentials for demo purposes
    usernameController.text = 'demo';
    passwordController.text = 'password';
    // Show password by default for the demo
    rememberMe.value = true;
    
    // Check if user is already logged in
    checkLoginStatus();
  }
  
  Future<void> checkLoginStatus() async {
    final hasToken = await _dioService.hasToken();
    if (hasToken) {
      await fetchAndUpdateUserDetails(showModal: false);
    }
  }
  
  Future<bool> fetchAndUpdateUserDetails({bool showModal = false}) async {
    if (showModal) {
      Modal.showProgressModal(message: 'Refreshing user data...');
    }
    
    final result = await getUserProfile();
    
    if (showModal && (Get.isDialogOpen ?? false)) {
      Get.back();
    }
    
    return result;
  }
  
  Future<bool> getUserProfile() async {
    isLoading.value = true;
    
    final result = await _dioService.authGet(
      ApiConfig.user,
      fromJson: (data) => User.fromJson(data),
    );
    
    isLoading.value = false;
    
    return result.fold(
      (error) {
        // Token might be invalid, clear it
        _dioService.clearToken();
        user.value = null;
        return false;
      },
      (userData) {
        user.value = userData;
        return true;
      },
    );
  }
  
  void setRole(String role) {
    selectedRole.value = role;
  }
  
  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
  }
  
  Future<bool> login() async {
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      Modal.showErrorModal(message: 'Please enter both username and password');
      return false;
    }
    
    isLoading.value = true;
    Modal.showProgressModal(message: 'Logging in...');
    
    final result = await _dioService.post(
      ApiConfig.login,
      data: {
        'email': usernameController.text,
        'password': passwordController.text,
      },
      fromJson: (data) => data,
    );
    
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
    isLoading.value = false;
    
    return result.fold(
      (error) {
        Modal.showErrorModal(message: error.message);
        return false;
      },
      (data) async {
        // Save token
        await _dioService.setToken(data['access_token']);
        
        // Set user data
        user.value = User.fromJson(data['user']);
        
        // Navigate based on role
        _navigateBasedOnRole();
        
        return true;
      },
    );
  }
  
  Future<bool> register(String name, String username, String email, String password, String passwordConfirmation) async {
    isLoading.value = true;
    Modal.showProgressModal(message: 'Creating account...');
    
    final result = await _dioService.post(
      ApiConfig.register,
      data: {
        'name': name,
        'username': username,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
      fromJson: (data) => data,
    );
    
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
    isLoading.value = false;
    
    return result.fold(
      (error) {
        Modal.showErrorModal(message: error.message);
        return false;
      },
      (data) async {
        // Save token
        await _dioService.setToken(data['access_token']);
        
        // Set user data
        user.value = User.fromJson(data['user']);
        
        // Navigate based on role
        _navigateBasedOnRole();
        
        return true;
      },
    );
  }
  
  Future<bool> logout() async {
    isLoading.value = true;
    Modal.showProgressModal(message: 'Logging out...');
    
    final result = await _dioService.authPost(
      ApiConfig.logout,
      data: {},
      fromJson: (data) => data,
    );
    
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
    isLoading.value = false;
    
    // Even if the API call fails, we should clear local data
    await _dioService.clearToken();
    user.value = null;
    
    // Navigate to login
    Get.offAllNamed(AppRoutes.login);
    
    return result.fold(
      (error) {
        Modal.showErrorModal(message: error.message);
        return false;
      },
      (data) {
        return true;
      },
    );
  }
  
  void _navigateBasedOnRole() {
    switch (user.value?.role?.toLowerCase()) {
      case 'coordinator':
        Get.offAllNamed(AppRoutes.coordinatorDashboard);
        break;
      case 'teller':
        Get.offAllNamed(AppRoutes.tellerDashboard);
        break;
      case 'customer':
        Get.offAllNamed(AppRoutes.customerDashboard);
        break;
      default:
        // If role is unknown, go to login
        Get.offAllNamed(AppRoutes.login);
        break;
    }
  }
  
  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
