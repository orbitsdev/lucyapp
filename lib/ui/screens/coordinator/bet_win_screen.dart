import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bettingapp/utils/app_colors.dart';
import 'package:intl/intl.dart';

class BetWinController extends GetxController {
  final RxString selectedSchedule = '11AM'.obs;
  final RxString betNumber = ''.obs;
  final RxString betAmount = 'PHP 10'.obs;
  final RxBool isProcessing = false.obs;
  final RxBool hasResult = false.obs;
  final Rx<Map<String, dynamic>?> winResult = Rx<Map<String, dynamic>?>(null);
  
  final List<String> schedules = [
    '11AM',
    '3P',
    '4PM',
    '9PM',
  ];
  
  final List<String> amounts = [
    'PHP 10',
    'PHP 20',
    'PHP 50',
    'PHP 100',
    'PHP 200',
    'PHP 500',
    'PHP 1,000',
  ];
  
  Future<void> checkWin() async {
    if (betNumber.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a bet number',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    isProcessing.value = true;
    hasResult.value = false;
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    // Determine if it's a win (for demo purposes, we'll make it a win if the bet number ends with '7')
    final isWin = betNumber.value.endsWith('7');
    
    if (isWin) {
      // Calculate win amount (for demo purposes, we'll multiply the bet amount by 40)
      final betAmountValue = int.parse(betAmount.value.replaceAll('PHP ', '').replaceAll(',', ''));
      final winAmount = betAmountValue * 40;
      
      winResult.value = {
        'isWin': true,
        'betNumber': betNumber.value,
        'schedule': selectedSchedule.value,
        'betAmount': betAmountValue,
        'winAmount': winAmount,
        'date': DateTime.now(),
      };
    } else {
      winResult.value = {
        'isWin': false,
        'betNumber': betNumber.value,
        'schedule': selectedSchedule.value,
        'betAmount': int.parse(betAmount.value.replaceAll('PHP ', '').replaceAll(',', '')),
        'date': DateTime.now(),
      };
    }
    
    isProcessing.value = false;
    hasResult.value = true;
  }
  
  void resetForm() {
    betNumber.value = '';
    hasResult.value = false;
    winResult.value = null;
  }
}

class BetWinScreen extends StatelessWidget {
  const BetWinScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BetWinController());
    
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('BET WIN'),
        backgroundColor: AppColors.betWinColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Instructions
              Container(
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
                      'Enter your bet number and select the schedule to check if you won. Standard payout is 40x your bet amount.',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ).animate()
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.1, end: 0, duration: 300.ms),
              
              const SizedBox(height: 24),
              
              // Bet Number Input
              const Text(
                'Bet Number',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                onChanged: (value) => controller.betNumber.value = value,
                controller: TextEditingController(text: controller.betNumber.value),
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 18),
                decoration: InputDecoration(
                  hintText: 'Enter bet number',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Schedule Dropdown
              const Text(
                'Schedule',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Obx(() => Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.selectedSchedule.value,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 16,
                    ),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        controller.selectedSchedule.value = newValue;
                      }
                    },
                    items: controller.schedules
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              )),
              
              const SizedBox(height: 24),
              
              // Bet Amount Dropdown
              const Text(
                'Bet Amount',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Obx(() => Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.betAmount.value,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 16,
                    ),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        controller.betAmount.value = newValue;
                      }
                    },
                    items: controller.amounts
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              )),
              
              const SizedBox(height: 32),
              
              // Check Win Button
              SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                  onPressed: controller.isProcessing.value
                      ? null
                      : () => controller.checkWin(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.betWinColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    disabledBackgroundColor: AppColors.betWinColor.withOpacity(0.6),
                  ),
                  child: controller.isProcessing.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'CHECK WIN',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                )),
              ),
              
              const SizedBox(height: 32),
              
              // Result Section
              Obx(() => controller.hasResult.value && controller.winResult.value != null
                  ? Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: controller.winResult.value!['isWin']
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: controller.winResult.value!['isWin']
                              ? Colors.green.shade200
                              : Colors.red.shade200,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Win/Lose Icon
                          Icon(
                            controller.winResult.value!['isWin']
                                ? Icons.emoji_events
                                : Icons.sentiment_dissatisfied,
                            size: 64,
                            color: controller.winResult.value!['isWin']
                                ? Colors.amber
                                : Colors.red.shade300,
                          ),
                          const SizedBox(height: 16),
                          
                          // Win/Lose Text
                          Text(
                            controller.winResult.value!['isWin']
                                ? 'Congratulations!'
                                : 'Better luck next time!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: controller.winResult.value!['isWin']
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          Text(
                            controller.winResult.value!['isWin']
                                ? 'You won PHP ${NumberFormat('#,###').format(controller.winResult.value!['winAmount'])}!'
                                : 'Your bet did not win this time.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: controller.winResult.value!['isWin']
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Bet Details
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                _buildDetailRow(
                                  'Bet Number',
                                  controller.winResult.value!['betNumber'],
                                ),
                                _buildDetailRow(
                                  'Schedule',
                                  controller.winResult.value!['schedule'],
                                ),
                                _buildDetailRow(
                                  'Bet Amount',
                                  'PHP ${NumberFormat('#,###').format(controller.winResult.value!['betAmount'])}',
                                ),
                                if (controller.winResult.value!['isWin'])
                                  _buildDetailRow(
                                    'Win Amount',
                                    'PHP ${NumberFormat('#,###').format(controller.winResult.value!['winAmount'])}',
                                    isHighlighted: true,
                                  ),
                                _buildDetailRow(
                                  'Date',
                                  DateFormat('MMM dd, yyyy hh:mm a').format(controller.winResult.value!['date']),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Try Again Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => controller.resetForm(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.betWinColor,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(color: AppColors.betWinColor),
                                ),
                              ),
                              child: const Text(
                                'TRY ANOTHER BET',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate()
                      .fadeIn(duration: 400.ms)
                      .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 400.ms)
                  : const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value, {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              color: isHighlighted ? AppColors.success : AppColors.primaryText,
            ),
          ),
        ],
      ),
    );
  }
}
