import 'package:bettingapp/core/getx/app_binding.dart';
import 'package:bettingapp/controllers/auth/auth_controller.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bettingapp/routes/app_routes.dart';
import 'package:bettingapp/utils/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize connectivity monitoring
  Connectivity().onConnectivityChanged.listen((results) {
    bool isConnected = results.any((result) => result != ConnectivityResult.none);
    if (!isConnected) {
      print('Device is offline from main.dart');
      // Note: We don't show modals here because the GetX context isn't ready yet
      // Modal handling is done in ConnectivityService
    } else {
      print('Device is online from main.dart');
    }
  });
  
  AppBinding().dependencies();
  
  // Check authentication status before app starts
  final authController = Get.find<AuthController>();
  await authController.loadTokenAndUser(showModal: false);
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Authentication is already checked in main() before app starts
  }


  @override
  void dispose() {
     WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch(state){
      case AppLifecycleState.resumed:
      print('resume');
      case AppLifecycleState.inactive:
      print('ianctive');
      case AppLifecycleState.detached:
      print('detach');
      print('detach');
      case AppLifecycleState.paused:
      print('pause');
      default:
    }
  }
  @override
  Widget build(BuildContext context) {
      
      

    return ScreenUtilInit(
      designSize: const Size(375, 812), // Base design size for responsive UI
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'LuckyBet',
          debugShowCheckedModeBanner: false,
  //       
          theme: ThemeData(
             iconTheme: IconThemeData(color: Colors.white),
            primaryColor: AppColors.primaryRed,
            scaffoldBackgroundColor: Colors.grey.shade100,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primaryRed,
              primary: AppColors.primaryRed,
            ),
            appBarTheme: AppBarTheme(
              elevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(vertical: 16.h),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primaryRed, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            ),
          ),
          initialRoute: AppRoutes.login,
          getPages: AppRoutes.routes,
          defaultTransition: Transition.fadeIn,
        );
      },
    );
  }
}
