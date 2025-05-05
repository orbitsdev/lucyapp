import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bettingapp/widgets/common/modal.dart';
import 'package:bettingapp/utils/app_colors.dart';

class TestModalScreen extends StatelessWidget {
  const TestModalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modal Test Screen'),
        backgroundColor: AppColors.primaryRed,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionTitle('Success Modals'),
            _buildButton(
              'Success Modal (Auto Dismiss)',
              () => Modal.showSuccessModal(
                title: 'Bet Placed',
                message: 'Your bet has been successfully placed!',
              ),
            ),
            _buildButton(
              'Success Modal (With Button)',
              () => Modal.showSuccessModal(
                title: 'Bet Placed',
                message: 'Your bet has been successfully placed!',
                showButton: true,
                buttonText: 'Great!',
              ),
            ),
            
            _buildSectionTitle('Error Modals'),
            _buildButton(
              'Error Modal',
              () => Modal.showErrorModal(
                title: 'Connection Error',
                message: 'Unable to connect to the server. Please try again later.',
              ),
            ),
            
            _buildSectionTitle('Confirmation Modals'),
            _buildButton(
              'Confirmation Modal',
              () => Modal.showConfirmationModal(
                title: 'Confirm Bet',
                message: 'Are you sure you want to place this bet?',
                onConfirm: () {
                  Get.snackbar(
                    'Confirmed',
                    'Bet confirmed successfully',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                },
              ),
            ),
            _buildButton(
              'Dangerous Action Confirmation',
              () => Modal.showConfirmationModal(
                title: 'Cancel Bet',
                message: 'Are you sure you want to cancel this bet? This action cannot be undone.',
                confirmText: 'Yes, Cancel',
                cancelText: 'No, Keep Bet',
                isDangerousAction: true,
                onConfirm: () {
                  Get.snackbar(
                    'Cancelled',
                    'Bet cancelled successfully',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                },
              ),
            ),
            
            _buildSectionTitle('Info Modals'),
            _buildButton(
              'Info Modal',
              () => Modal.showInfoModal(
                title: 'Betting Rules',
                message: 'You can place bets on numbers between 1-99. Each bet costs ₱10 minimum.',
                buttonText: 'Got it',
              ),
            ),
            
            _buildSectionTitle('Progress Modals'),
            _buildButton(
              'Progress Modal',
              () {
                Modal.showProgressModal(
                  title: 'Processing Bet',
                  message: 'Please wait while we process your bet...',
                );
                
                // Auto close after 3 seconds for demo purposes
                Future.delayed(const Duration(seconds: 3), () {
                  Modal.closeDialog();
                  Modal.showSuccessModal(
                    title: 'Bet Processed',
                    message: 'Your bet has been processed successfully!',
                  );
                });
              },
            ),
            _buildButton(
              'Progress Modal (No Animation)',
              () {
                Modal.showProgressModal(
                  title: 'Connecting to Server',
                  message: 'Establishing connection...',
                  showAnimation: false,
                );
                
                // Auto close after 3 seconds for demo purposes
                Future.delayed(const Duration(seconds: 3), () {
                  Modal.closeDialog();
                });
              },
            ),
            
            _buildSectionTitle('No Internet Modal'),
            _buildButton(
              'No Internet Modal',
              () => Modal.showNoInternetModal(
                onRetry: () {
                  Get.snackbar(
                    'Retrying',
                    'Checking connection again...',
                    backgroundColor: Colors.blue,
                    colorText: Colors.white,
                  );
                },
              ),
            ),
            
            _buildSectionTitle('Custom Modal'),
            _buildButton(
              'Custom Modal',
              () => Modal.showCustomModal(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.celebration,
                      size: 60.r,
                      color: AppColors.primaryRed,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Congratulations!',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'You won ₱1,000!',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () {
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                      ),
                      child: Text('Claim Prize'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(top: 24.r, bottom: 8.r),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryRed,
        ),
      ),
    );
  }

  Widget _buildButton(String title, VoidCallback onPressed) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.r),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 2,
          padding: EdgeInsets.symmetric(vertical: 12.r),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
            side: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child: Text(title),
      ),
    );
  }
}