import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bettingapp/utils/app_colors.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ClaimController extends GetxController {
  final RxString scannedQrCode = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool hasScanned = false.obs;
  final scannerController = MobileScannerController();
  
  @override
  void onInit() {
    super.onInit();
    // No need to automatically scan on init
  }
  
  @override
  void onClose() {
    scannerController.dispose();
    super.onClose();
  }
  
  void scanQrCode() {
    // Reset the scanned state when starting a new scan
    if (hasScanned.value) {
      hasScanned.value = false;
      scannedQrCode.value = '';
      scannerController.start();
    }
  }
  
  Future<void> saveClaim() async {
    if (scannedQrCode.value.isEmpty || !hasScanned.value) {
      Get.snackbar(
        'Error',
        'Please scan a QR code first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    isLoading.value = true;
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    isLoading.value = false;
    
    // Show success message
    Get.snackbar(
      'Success',
      'Claim processed successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
    
    // Go back to dashboard
    Get.back();
  }
}

class ClaimScreen extends StatelessWidget {
  const ClaimScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ClaimController());
    
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('CLAIM'),
        backgroundColor: AppColors.primaryRed, 
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Instructions - Keeping the original content
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
                  'Take a clear photo of your winning ticket. Make sure all details are visible and the ticket is properly lit.',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
          
          // QR Code Scan Result or Scanner
          Expanded(
            child: Obx(() => controller.hasScanned.value
              ? Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.qr_code_scanner,
                        size: 64,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'QR Code Scanned Successfully',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ticket ID: ${controller.scannedQrCode.value}',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => controller.scanQrCode(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Scan Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  margin: const EdgeInsets.all(16),
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: MobileScanner(
                          controller: controller.scannerController,
                          onDetect: (capture) {
                            final List<Barcode> barcodes = capture.barcodes;
                            for (final barcode in barcodes) {
                              if (barcode.rawValue != null && !controller.hasScanned.value) {
                                // Update state
                                controller.scannedQrCode.value = barcode.rawValue!;
                                controller.hasScanned.value = true;
                                
                                // Optional: provide feedback
                                HapticFeedback.mediumImpact();
                                
                                // Stop scanning
                                controller.scannerController.stop();
                              }
                            }
                          },
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        color: AppColors.primaryRed.withOpacity(0.8),
                        child: const Text(
                          'Position QR code in the scanner area',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ),
          ),
          
          // Submit Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(() => ElevatedButton(
              onPressed: controller.isLoading.value || !controller.hasScanned.value
                  ? null
                  : () => controller.saveClaim(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed, 
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                disabledBackgroundColor: AppColors.primaryRed.withOpacity(0.6), 
              ),
              child: controller.isLoading.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'SUBMIT CLAIM',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            )),
          ),
        ],
      ),
    );
  }
}
