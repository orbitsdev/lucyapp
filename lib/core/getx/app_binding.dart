import 'package:bettingapp/controllers/auth_controller.dart';
import 'package:bettingapp/controllers/betting_controller.dart';
import 'package:bettingapp/controllers/dropdown_controller.dart';
import 'package:bettingapp/controllers/report_controller.dart';
import 'package:bettingapp/core/services/connectivity_service.dart';
import 'package:bettingapp/core/services/loading_service.dart';
import 'package:get/get.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Register services
    Get.put(ConnectivityService(), permanent: true);
    Get.put(LoadingService(), permanent: true);
    Get.put(AuthController(), permanent: true);

    Get.put(DropdownController(), permanent: true);
Get.put(BettingController(), permanent: true);
Get.put(ReportController(), permanent: true);
    
   
  }
}