import 'package:bettingapp/controllers/auth_controller.dart';
import 'package:bettingapp/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();
    
    // If not logged in, redirect to login
    if (!authController.isLoggedIn) {
      return const RouteSettings(name: AppRoutes.login);
    }
    
    // User is logged in, allow access
    return null;
  }
}
