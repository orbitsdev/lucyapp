import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bettingapp/utils/app_colors.dart';
import 'package:bettingapp/controllers/place_bet_controller.dart';

class PlaceBetScreen extends StatelessWidget {
  const PlaceBetScreen({super.key});
  
  // Get the controller
  PlaceBetController get controller => Get.put(PlaceBetController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Place Bet'),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Game Type',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            _buildGameTypeSelector(),
            SizedBox(height: 24.h),
            Text(
              'Enter Numbers',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            _buildNumberSelector(),
            SizedBox(height: 24.h),
            Text(
              'Bet Amount',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            _buildAmountInput(),
            SizedBox(height: 32.h),
            _buildPlaceBetButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildGameTypeSelector() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Obx(() => _buildGameTypeOption('3D Game', 'Select 3 numbers from 0-9')),
          SizedBox(height: 12.h),
          Obx(() => _buildGameTypeOption('2D Game', 'Select 2 numbers from 0-9')),
          SizedBox(height: 12.h),
          Obx(() => _buildGameTypeOption('1D Game', 'Select 1 number from 0-9')),
        ],
      ),
    );
  }

  Widget _buildGameTypeOption(String title, String description) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        border: Border.all(
          color: controller.selectedGameType.value == title 
              ? AppColors.primaryBlue 
              : Colors.grey.shade300
        ),
        borderRadius: BorderRadius.circular(8),
        color: controller.selectedGameType.value == title 
            ? AppColors.primaryBlue.withOpacity(0.05) 
            : Colors.white,
      ),
      child: Row(
        children: [
          Radio(
            value: title,
            groupValue: controller.selectedGameType.value,
            onChanged: (value) {
              if (value != null) {
                controller.updateGameType(value);
              }
            },
            activeColor: AppColors.primaryBlue,
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberSelector() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumberButton('1'),
              _buildNumberButton('2'),
              _buildNumberButton('3'),
              _buildNumberButton('4'),
              _buildNumberButton('5'),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumberButton('6'),
              _buildNumberButton('7'),
              _buildNumberButton('8'),
              _buildNumberButton('9'),
              _buildNumberButton('0'),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(Icons.backspace_outlined, color: AppColors.primaryBlue),
                onPressed: () => controller.removeLastNumber(),
              ),
              IconButton(
                icon: Icon(Icons.clear, color: Colors.red),
                onPressed: () => controller.clearNumbers(),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Selected Numbers:',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Obx(() => Text(
                  controller.selectedNumbersFormatted,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8.w,
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    return Obx(() {
      final bool isSelected = controller.selectedNumbers.contains(number);
      final bool isDisabled = controller.selectedNumbers.length >= controller.maxDigits.value && !isSelected;
      
      return InkWell(
        onTap: isDisabled ? null : () => controller.addNumber(number),
        child: Container(
          width: 50.w,
          height: 50.w,
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected 
                  ? AppColors.primaryBlue 
                  : isDisabled 
                      ? Colors.grey.shade200 
                      : Colors.grey.shade300
            ),
            borderRadius: BorderRadius.circular(8),
            color: isSelected 
                ? AppColors.primaryBlue.withOpacity(0.1) 
                : isDisabled 
                    ? Colors.grey.shade100 
                    : Colors.white,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: isDisabled ? Colors.grey.shade400 : Colors.black,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildAmountInput() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: controller.amountController,
            keyboardType: TextInputType.number,
            onChanged: (value) => controller.updateAmount(value),
            decoration: InputDecoration(
              labelText: 'Enter Amount',
              prefixText: '₱ ',
              prefixIcon: Icon(Icons.payments_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickAmountButton('₱10'),
              _buildQuickAmountButton('₱20'),
              _buildQuickAmountButton('₱50'),
              _buildQuickAmountButton('₱100'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAmountButton(String amount) {
    return InkWell(
      onTap: () => controller.setAmount(amount),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryBlue),
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Text(
          amount,
          style: TextStyle(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceBetButton() {
    return Obx(() => SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.canPlaceBet() ? () {
          // Show confirmation dialog
          final betNumber = controller.selectedNumbers.join('');
          final amountFormatted = controller.formatAmount(controller.amount.value);
          
          Get.dialog(
            AlertDialog(
              title: const Text('Confirm Bet'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Are you sure you want to place this bet?'),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Text('Game Type: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(controller.selectedGameType.value),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text('Number: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(betNumber, style: TextStyle(fontSize: 18)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text('Amount: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('₱$amountFormatted', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                    controller.placeBet();
                  },
                  child: Text('Confirm'),
                ),
              ],
            ),
          );
        } : null,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          backgroundColor: AppColors.primaryBlue,
          disabledBackgroundColor: Colors.grey.shade300,
        ),
        child: Text(
          'Place Bet',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ));
  }
}
