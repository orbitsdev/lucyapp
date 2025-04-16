import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bettingapp/utils/app_colors.dart';
import 'package:bettingapp/widgets/photo_proof_widget.dart';
import 'package:image_picker/image_picker.dart';

class ClaimController extends GetxController {
  final Rx<File?> image = Rx<File?>(null);
  final RxBool isLoading = false.obs;
  final ImagePicker _picker = ImagePicker();
  
  @override
  void onInit() {
    super.onInit();
    // Take a picture when the screen loads
    takePicture();
  }
  
  Future<void> takePicture() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 80,
      );
      
      if (pickedFile != null) {
        image.value = File(pickedFile.path);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to take picture: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  Future<void> saveClaim() async {
    if (image.value == null) {
      Get.snackbar(
        'Error',
        'Please take a picture first',
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
      'Claim saved successfully',
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
        backgroundColor: AppColors.claimColor,
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
          
          // Photo Preview and Buttons
          Expanded(
            child: Obx(() => PhotoProofWidget(
              image: controller.image.value,
              onRetake: () => controller.takePicture(),
              onSave: () => controller.saveClaim(),
            )),
          ),
          
          // Save Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(() => ElevatedButton(
              onPressed: controller.isLoading.value || controller.image.value == null
                  ? null
                  : () => controller.saveClaim(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.claimColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                disabledBackgroundColor: AppColors.claimColor.withOpacity(0.6),
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
