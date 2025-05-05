import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bettingapp/utils/app_colors.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class TellerClaimController extends GetxController {
  final RxString scannedQrCode = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool hasScanned = false.obs;
  final scannerController = MobileScannerController();
  
  
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

class TellerClaimScreen extends StatelessWidget {
  const TellerClaimScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TellerClaimController());
    
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
          // Instructions
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primaryRed.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info,
                      color: AppColors.primaryRed,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Instructions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryRed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Scan the QR code on the betting slip to process a claim. Make sure the QR code is clearly visible and centered in the scanner.',
                  style: TextStyle(
                    color: AppColors.primaryRed.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ).animate()
            .fadeIn(duration: 300.ms)
            .slideY(begin: 0.1, end: 0, duration: 300.ms),
          
          // QR Scanner or Result
          Expanded(
            child: Obx(() => controller.hasScanned.value
              ? _buildScanResult(controller)
              : _buildScanner(controller)),
          ),
          
          // Action Button
          Container(
            padding: const EdgeInsets.all(16),
            child: Obx(() => controller.hasScanned.value
              ? Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => controller.scanQrCode(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryRed,
                          side: BorderSide(color: AppColors.primaryRed),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('SCAN AGAIN'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value
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
                            : const Text('PROCESS CLAIM'),
                      ),
                    ),
                  ],
                )
              : const SizedBox()),
          ),
        ],
      ),
    );
  }
  
  Widget _buildScanner(TellerClaimController controller) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      clipBehavior: Clip.hardEdge,
      child: MobileScanner(
        controller: controller.scannerController,
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty && !controller.hasScanned.value) {
            final String code = barcodes.first.rawValue ?? '';
            controller.scannedQrCode.value = code;
            controller.hasScanned.value = true;
            controller.scannerController.stop();
            HapticFeedback.mediumImpact();
          }
        },
      ),
    ).animate()
      .fadeIn(duration: 300.ms)
      .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), duration: 300.ms);
  }
  
  Widget _buildScanResult(TellerClaimController controller) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              color: Colors.green.shade600,
              size: 64,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'QR Code Scanned Successfully',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Ticket ID: ${controller.scannedQrCode.value}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          const Text(
            'Ready to process claim',
            style: TextStyle(
              fontSize: 16,
              color: Colors.green,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 300.ms)
      .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), duration: 300.ms);
  }
}
