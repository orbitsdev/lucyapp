import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bettingapp/routes/app_routes.dart';
import '../controllers/auth_controller.dart';


class GuestMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final AuthController authController = Get.find<AuthController>();

    
  print('--------------------- GUEST MIDDLLEWARE ');
  print(authController.isLoggedIn);
  print('--------------------');


    // If logged in, redirect to appropriate dashboard
    if (authController.isLoggedIn) {
      switch (authController.userRole?.toLowerCase()) {
        case 'coordinator':
          return const RouteSettings(name: AppRoutes.coordinatorDashboard);
        case 'teller':
          return const RouteSettings(name: AppRoutes.tellerDashboard);
        case 'customer':
          return const RouteSettings(name: AppRoutes.customerDashboard);
        default:
          return null;
      }
    }
    
    // User is not logged in, allow access to guest routes
    return null;
  }
}
