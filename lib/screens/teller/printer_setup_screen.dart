import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bettingapp/utils/app_colors.dart';

class PrinterSetupController extends GetxController {
  final RxString selectedPrinter = ''.obs;
  final RxBool isConnecting = false.obs;
  final RxBool isPrinterConnected = false.obs;
  final RxList<Map<String, dynamic>> availablePrinters = <Map<String, dynamic>>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    // Load sample printer data
    loadPrinters();
  }
  
  void loadPrinters() {
    // Sample printer data
    availablePrinters.value = [
      {
        'id': 'printer1',
        'name': 'Thermal Printer TP-100',
        'address': 'BT:00:11:22:33:44:55',
        'isConnected': false,
      },
      {
        'id': 'printer2',
        'name': 'POS Printer 58mm',
        'address': 'BT:55:66:77:88:99:00',
        'isConnected': false,
      },
      {
        'id': 'printer3',
        'name': 'Receipt Printer XP-420B',
        'address': 'BT:AA:BB:CC:DD:EE:FF',
        'isConnected': false,
      },
    ];
  }
  
  Future<void> connectPrinter(String printerId) async {
    if (isConnecting.value) return;
    
    selectedPrinter.value = printerId;
    isConnecting.value = true;
    
    // Simulate connection process
    await Future.delayed(const Duration(seconds: 2));
    
    // Update printer connection status
    final index = availablePrinters.indexWhere((p) => p['id'] == printerId);
    if (index != -1) {
      final updatedPrinters = [...availablePrinters];
      
      // Disconnect all printers first
      for (var i = 0; i < updatedPrinters.length; i++) {
        updatedPrinters[i] = {...updatedPrinters[i], 'isConnected': false};
      }
      
      // Connect the selected printer
      updatedPrinters[index] = {...updatedPrinters[index], 'isConnected': true};
      availablePrinters.value = updatedPrinters;
      isPrinterConnected.value = true;
    }
    
    isConnecting.value = false;
    
    // Show success message
    Get.snackbar(
      'Success',
      'Printer connected successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
  
  Future<void> testPrint() async {
    if (!isPrinterConnected.value) {
      Get.snackbar(
        'Error',
        'Please connect a printer first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    // Simulate printing process
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false,
    );
    
    await Future.delayed(const Duration(seconds: 2));
    
    Get.back(); // Close the loading dialog
    
    // Show success message
    Get.snackbar(
      'Success',
      'Test page printed successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
}

class PrinterSetupScreen extends StatelessWidget {
  const PrinterSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PrinterSetupController());
    
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('PRINTER SETUP'),
        backgroundColor: AppColors.printerColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Instructions
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Instructions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Make sure your Bluetooth printer is turned on and in pairing mode. Select your printer from the list below to connect.',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
          
          // Available Printers List
          Expanded(
            child: Obx(() => ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.availablePrinters.length,
              itemBuilder: (context, index) {
                final printer = controller.availablePrinters[index];
                final bool isConnected = printer['isConnected'] ?? false;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isConnected ? AppColors.printerColor : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: InkWell(
                    onTap: () => controller.connectPrinter(printer['id']),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Printer Icon
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.printerColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.print,
                              color: AppColors.printerColor,
                              size: 24,
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          // Printer Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  printer['name'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryText,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  printer['address'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Connection Status
                          isConnected
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.green.shade700,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Connected',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.green.shade700,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Obx(() => controller.isConnecting.value && controller.selectedPrinter.value == printer['id']
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.bluetooth,
                                      color: Colors.grey,
                                    )),
                        ],
                      ),
                    ),
                  ),
                ).animate()
                  .fadeIn(duration: 300.ms, delay: (index * 50).ms)
                  .slideX(begin: 0.1, end: 0, duration: 300.ms);
              },
            )),
          ),
          
          // Test Print Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => controller.testPrint(),
                icon: const Icon(Icons.print),
                label: const Text('TEST PRINT'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.printerColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
