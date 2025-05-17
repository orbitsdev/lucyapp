import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:bettingapp/routes/app_routes.dart';
import 'package:bettingapp/core/dio/dio_base.dart';
import 'package:bettingapp/config/api_config.dart';
import 'package:bettingapp/models/user.dart';
import 'package:bettingapp/widgets/common/modal.dart';

class AuthController extends GetxController {

  static AuthController controller = Get.find();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  final DioService _dioService = DioService();
  final Rx<User?> user = Rx<User?>(null);
  final RxString selectedRole = 'Coordinator'.obs;
  final RxBool isLoading = false.obs;
  final RxBool rememberMe = true.obs;
  
  // Reactive username for UI display
  final RxString currentUsername = ''.obs;
  
  bool get isLoggedIn => user.value != null;
  String? get userRole => user.value?.role;
  
  @override
  void onInit() {
    super.onInit();
    // Pre-fill credentials for demo purposes
    usernameController.text = 'tellerjane';
    passwordController.text = 'password';
    // Initialize reactive username
    currentUsername.value = 'tellerjane';
    // Show password by default for the demo
    rememberMe.value = true;
    // Set role to Teller by default
    selectedRole.value = 'Teller';
    
    // Note: checkLoginStatus is now called from AppBinding
    // to ensure it completes before routes are processed
  }
  
  Future<void> checkLoginStatus() async {
    await loadTokenAndUser(showModal: false);
  }
  
  Future<void> loadTokenAndUser({bool showModal = false}) async {
    try {
      print('Loading token and user data...');
      final hasToken = await _dioService.hasToken();
      
      if (hasToken) {
        print('Token found, fetching user details');
        // Token exists, fetch user details
        await fetchAndUpdateUserDetails(showModal: showModal);
        print('User data loaded, isLoggedIn: $isLoggedIn');
      } else {
        print('No token found');
      }
    } catch (e) {
      print('Error loading token and user: $e');
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
    print('Getting user profile...');
    
    final result = await _dioService.authGet(
      ApiConfig.user,
      fromJson: (data) => User.fromJson(data),
    );
    
    isLoading.value = false;
    
    return result.fold(
      (error) {
        print('Error getting user profile: ${error.message}');
        // Token might be invalid, clear it
        _dioService.clearToken();
        user.value = null;
        print('User value after error: ${user.value}');
        return false;
      },
      (userData) {
        print('User profile fetched successfully');
        print('User data: ${userData.toMap()}');
        user.value = userData;
        print('isLoggedIn after setting user: $isLoggedIn');
        return true;
      },
    );
  }
  
  void setRole(String role) {
    selectedRole.value = role;
    
    // Update username based on selected role for faster testing
    switch (role) {
      case 'Coordinator':
        usernameController.text = 'coordinatorjohn';
        currentUsername.value = 'coordinatorjohn';
        break;
      case 'Teller':
        usernameController.text = 'tellerjane';
        currentUsername.value = 'tellerjane';
        break;
      case 'Customer':
        // No customer account in the sample data yet
        usernameController.text = 'admin';
        currentUsername.value = 'admin';
        break;
      default:
        break;
    }
    
    // Password is the same for all test accounts
    passwordController.text = 'password';
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
    print('Attempting login with username: ${usernameController.text}');

    bool navigationDone = false;
    try {
      // Use username only for login
      final Map<String, dynamic> loginData = {
        'username': usernameController.text,
        'password': passwordController.text,
      };

      final result = await _dioService.post(
        ApiConfig.login,
        data: loginData,
        fromJson: (data) => data,
      );

      isLoading.value = false;

      return await result.fold(
        (error) async {
          print('Login error: ${error.message} (code: ${error.code})');
          // Ensure modal is closed before showing error
          if (Get.isDialogOpen ?? false) {
            Get.back();
          }
          _showApiError(error);
          return false;
        },
        (data) async {
          print('Login successful');
          await _dioService.setToken(data['access_token']);
          user.value = User.fromJson(data['user']);
          await fetchAndUpdateUserDetails(showModal: false);
          // Ensure modal is closed before navigation
          if (Get.isDialogOpen ?? false) {
            Get.back();
          }
          navigationDone = true;
          _navigateBasedOnRole();
          return true;
        },
      );
    } finally {
      isLoading.value = false;
      // Defensive: close modal if still open and navigation hasn't happened
      if (!navigationDone && (Get.isDialogOpen ?? false)) {
        Get.back();
      }
    }
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
        _showApiError(error);
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
        _showApiError(error);
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
  
  Future<void> _showApiError(dynamic error) async {
    // Accepts ApiError or Failure-like object with message/code
    final code = error.code;
    final message = error.message ?? 'An unexpected error occurred.';
    // Add a short delay to ensure dialog stack is clear
    await Future.delayed(const Duration(milliseconds: 100));
    switch (code) {
      case 'no_connection':
        Modal.showNoInternetModal();
        break;
      case 'timeout':
        Modal.showErrorModal(message: 'Request timed out. Please try again.');
        break;
      case 'unauthorized':
        Modal.showErrorModal(message: 'Unauthorized. Please login again.');
        break;
      case 'validation_error':
        Modal.showErrorModal(message: message);
        break;
      default:
        Modal.showErrorModal(message: message);
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
