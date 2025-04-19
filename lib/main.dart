import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bettingapp/routes/app_routes.dart';
import 'package:bettingapp/utils/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  //          darkTheme: ThemeData.dark().copyWith(
  //   appBarTheme: AppBarTheme(
  //     iconTheme: IconThemeData(color: Colors.white),
  //   ),
  // ),
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
