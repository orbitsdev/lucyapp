import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlaceBetController extends GetxController {
  // Selected game type
  final Rx<String> selectedGameType = '3D Game'.obs;
  
  // Selected numbers
  final RxList<String> selectedNumbers = <String>[].obs;
  
  // Maximum number of digits based on game type
  final RxInt maxDigits = 3.obs;
  
  // Amount
  final TextEditingController amountController = TextEditingController();
  final RxDouble amount = 0.0.obs;
  
  @override
  void onInit() {
    super.onInit();
    // Initialize with default values
    updateGameType('3D Game');
  }
  
  @override
  void onClose() {
    amountController.dispose();
    super.onClose();
  }
  
  // Update the selected game type
  void updateGameType(String gameType) {
    selectedGameType.value = gameType;
    
    // Reset selected numbers when game type changes
    selectedNumbers.clear();
    
    // Set max digits based on game type
    if (gameType == '3D Game') {
      maxDigits.value = 3;
    } else if (gameType == '2D Game') {
      maxDigits.value = 2;
    } else if (gameType == '1D Game') {
      maxDigits.value = 1;
    }
  }
  
  // Add a number to the selection
  void addNumber(String number) {
    if (selectedNumbers.length < maxDigits.value) {
      selectedNumbers.add(number);
    }
  }
  
  // Remove the last number from the selection
  void removeLastNumber() {
    if (selectedNumbers.isNotEmpty) {
      selectedNumbers.removeLast();
    }
  }
  
  // Clear all selected numbers
  void clearNumbers() {
    selectedNumbers.clear();
  }
  
  // Smart format amount function that handles both string and numeric inputs
  String formatAmount(dynamic amount) {
    // Handle null case
    if (amount == null) return '0';
    
    // Convert to double first
    double numAmount;
    
    if (amount is String) {
      // Try to parse the string to a double
      try {
        // Remove any currency symbols or commas
        final cleanAmount = amount.replaceAll(RegExp(r'[^0-9.]'), '');
        numAmount = double.parse(cleanAmount);
      } catch (e) {
        print('Error parsing amount string: $e');
        return '0'; // Return 0 if parsing fails
      }
    } else if (amount is int) {
      numAmount = amount.toDouble();
    } else if (amount is double) {
      numAmount = amount;
    } else {
      print('Unsupported amount type: ${amount.runtimeType}');
      return '0'; // Return 0 for unsupported types
    }
    
    // Check if it's a whole number
    if (numAmount == numAmount.truncateToDouble()) {
      return numAmount.toInt().toString(); // No decimal places for whole numbers
    } else {
      // For non-whole numbers, show only necessary decimal places (max 2)
      // First, round to 2 decimal places
      numAmount = (numAmount * 100).round() / 100;
      
      // If the fractional part ends with 0, show only 1 decimal place
      if ((numAmount * 10).round() % 10 == 0) {
        return numAmount.toStringAsFixed(1);
      } else {
        return numAmount.toStringAsFixed(2);
      }
    }
  }
  
  // Set amount from quick amount buttons
  void setAmount(String amountStr) {
    // Remove currency symbol and parse to double
    final cleanAmount = amountStr.replaceAll('₱', '').trim();
    
    try {
      final parsedAmount = double.parse(cleanAmount);
      amount.value = parsedAmount;
      amountController.text = formatAmount(parsedAmount);
    } catch (e) {
      print('Error parsing amount: $e');
    }
  }
  
  // Update amount from text field
  void updateAmount(String value) {
    try {
      // Try to parse the input value
      final parsedAmount = double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
      amount.value = parsedAmount;
    } catch (e) {
      print('Error updating amount: $e');
      amount.value = 0.0;
    }
  }
  
  // Get formatted selected numbers as a string
  String get selectedNumbersFormatted {
    if (selectedNumbers.isEmpty) {
      return '_' * maxDigits.value;
    }
    
    final formattedNumbers = selectedNumbers.join('');
    final remainingUnderscores = '_' * (maxDigits.value - selectedNumbers.length);
    
    return formattedNumbers + remainingUnderscores;
  }
  
  // Check if bet can be placed
  bool canPlaceBet() {
    return selectedNumbers.length == maxDigits.value && amount.value > 0;
  }
  
  // Place bet
  Future<void> placeBet() async {
    if (!canPlaceBet()) {
      Get.snackbar(
        'Error',
        'Please complete your bet selection and amount',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    try {
      // Format the bet number
      final betNumber = selectedNumbers.join('');
      
      // Format the amount using our smart formatter
      final formattedAmount = formatAmount(amount.value);
      
      // Here you would call your API to place the bet
      // For now, we'll just simulate a successful bet
      
      // Show success message
      Get.snackbar(
        'Success',
        'Your bet of ₱$formattedAmount on $betNumber has been placed!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      // Reset the form
      clearNumbers();
      amountController.clear();
      amount.value = 0.0;
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to place bet: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
