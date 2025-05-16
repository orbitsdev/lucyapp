import 'package:bettingapp/controllers/auth_controller.dart';
import 'package:bettingapp/controllers/betting_controller.dart';
import 'package:bettingapp/controllers/dropdown_controller.dart';
import 'package:bettingapp/controllers/printer_controller.dart';
import 'package:bettingapp/controllers/report_controller.dart';
import 'package:bettingapp/controllers/sales_controller.dart';
import 'package:bettingapp/core/services/connectivity_service.dart';
import 'package:bettingapp/core/services/loading_service.dart';
import 'package:bettingapp/services/printer_service.dart';
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
    Get.put(SalesController(), permanent: true);
    
    // Initialize printer service first
    final printerService = PrinterService();
    Get.put(printerService, permanent: true);
    
    // Then initialize the printer controller which depends on the service
    Get.put(PrinterController(), permanent: true);
    
    // Start the printer service initialization process
    printerService.init();
  }
}
