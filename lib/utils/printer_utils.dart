import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:bettingapp/controllers/auth_controller.dart';
import 'package:bettingapp/controllers/printer_controller.dart';
import 'package:bettingapp/widgets/common/modal.dart';
import 'package:bettingapp/models/bet.dart';
import 'package:bettingapp/models/draw.dart';
import 'package:bettingapp/models/game_type.dart';

/// Utility class for handling printer-related functions
class PrinterUtils {
  
  /// Print a bet ticket using data from a Bet model
  static Future<void> printBetTicketFromModel(Bet bet, {bool isReprint = true}) async {
    // Show confirmation dialog
    Completer<bool> completer = Completer<bool>();
    
    Modal.showConfirmationModal(
      title: 'Print Bet Ticket',
      message: 'Do you want to print this bet ticket?\n\n'
              'Ticket ID: ${bet.ticketId}\n'
              'Bet Number: ${bet.betNumber}\n'
              'Amount: PHP ${bet.amount?.toInt() ?? bet.amount}\n'
              'Winning Amount: ${bet.winningAmount != null ? "PHP ${bet.winningAmount}" : "Not set"}\n',
      confirmText: 'Print',
      cancelText: 'Cancel',
      animation: 'assets/animations/questionmark.json',
      onConfirm: () {
        completer.complete(true);
      },
      onCancel: () {
        completer.complete(false);
      },
    );
    
    bool shouldPrint = await completer.future;
    if (!shouldPrint) return;
    
    // Get current user info from AuthController
    final authController = AuthController.controller;
    final currentUser = authController.user.value;
    
    // Use the global printer controller to print the ticket
    final printerController = Get.find<PrinterController>();
    
    try {
      await printerController.printBetTicket(
        ticketId: bet.ticketId ?? 'Unknown',
        betNumber: bet.betNumber ?? 'Unknown',
        amount: bet.amount,
        winningAmount: bet.winningAmount,
        isLowWin: bet.isLowWin,
        gameTypeName: bet.gameType?.name ?? 'Unknown',
        drawTime: bet.draw?.drawTimeFormatted ?? 'Unknown',
        betDate: bet.betDateFormatted ?? 'Unknown',
        status: bet.isRejected == true ? 'Cancelled' : (bet.isClaimed == true ? 'Claimed' : 'Active'),
        tellerName: currentUser?.name ?? 'Unknown Teller',
        tellerUsername: currentUser?.username ?? 'unknown',
        locationName: currentUser?.location?.name ?? '',
        isReprint: isReprint,
      );
    } catch (e) {
      debugPrint('Error printing bet ticket: $e');
      // Show error message
      Get.snackbar(
        'Printing Error',
        'Could not print the bet ticket. Please check printer connection.',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }
  
  /// Print a bet ticket using form data (for new bets before they're saved)
  static Future<void> printBetTicketFromForm({
    required String ticketId,
    required String betNumber,
    required dynamic amount,
    required GameType? gameType,
    required Draw? draw,
    required String betDate,
  }) async {
    try {
      // Create a Bet object from the form data
      final bet = Bet(
        ticketId: ticketId,
        betNumber: betNumber,
        amount: amount is double ? amount : double.tryParse(amount.toString()),
        gameType: gameType,
        draw: draw,
        betDate: betDate,
        betDateFormatted: betDate,
        isRejected: false,
        isClaimed: false,
      );
      
      // Print using the model method
      await printBetTicketFromModel(bet, isReprint: false);
    } catch (e) {
      debugPrint('Error printing bet ticket from form: $e');
      Get.snackbar(
        'Printing Error',
        'Could not print the bet ticket. Please check printer connection.',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }
  
  /// Print a bet ticket using data from an API response map
  static Future<void> printBetTicketFromResponse(Map<String, dynamic> betData) async {
    try {
      debugPrint('API Response for printing: $betData');
      
      // Check if we need to extract data from a nested structure
      final Map<String, dynamic> actualData = betData.containsKey('data') ? 
          betData['data'] is Map ? betData['data'] : betData : betData;
      
      // Try to convert the API response to a Bet object
      Bet? bet;
      try {
        bet = Bet.fromJson(actualData);
        debugPrint('Successfully created Bet object: ${bet.ticketId}, Draw: ${bet.draw?.drawTimeFormatted}');
      } catch (parseError) {
        debugPrint('Error parsing Bet from JSON: $parseError');
        // We'll handle this below by using direct extraction
      }
      
      // If we successfully created a Bet object and it has a valid draw time, use it
      if (bet != null && bet.draw?.drawTimeFormatted != null) {
        await printBetTicketFromModel(bet, isReprint: false);
        return;
      }
      
      // Fallback: Direct extraction from the response if Bet object creation failed or has missing draw time
      // Get current user info from AuthController
      final authController = AuthController.controller;
      final currentUser = authController.user.value;
      
      // Extract values directly from the response data
      final String ticketId = actualData['ticket_id']?.toString() ?? 'Unknown';
      final String betNumber = actualData['bet_number']?.toString() ?? 'Unknown';
      final dynamic amount = actualData['amount'];
      
      // Extract draw time with fallbacks for different API structures
      String drawTime = 'Unknown';
      if (actualData['draw'] != null && actualData['draw'] is Map) {
        // Try to get formatted draw time first
        drawTime = actualData['draw']['draw_time_formatted']?.toString() ?? 
                  actualData['draw']['draw_time']?.toString() ?? 'Unknown';
      } else if (actualData['draw_time'] != null) {
        // Direct draw_time field
        drawTime = actualData['draw_time'].toString();
      }
      
      // Extract game type name
      String gameTypeName = 'Unknown';
      if (actualData['game_type'] != null && actualData['game_type'] is Map) {
        gameTypeName = actualData['game_type']['name']?.toString() ?? 'Unknown';
      }
      
      // Extract bet date
      final String betDate = actualData['bet_date_formatted']?.toString() ?? 
                           actualData['bet_date']?.toString() ?? 
                           DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      // Use the global printer controller to print the ticket
      final printerController = Get.find<PrinterController>();
      
      await printerController.printBetTicket(
        ticketId: ticketId,
        betNumber: betNumber,
        amount: amount,
        gameTypeName: gameTypeName,
        drawTime: drawTime,
        betDate: betDate,
        status: actualData['is_rejected'] == true ? 'Cancelled' : 
               (actualData['is_claimed'] == true ? 'Claimed' : 'Active'),
        tellerName: currentUser?.name ?? 'Unknown Teller',
        tellerUsername: currentUser?.username ?? 'unknown',
        locationName: currentUser?.location?.name ?? '',
        isReprint: false,
      );
    } catch (e) {
      debugPrint('Error printing bet ticket from response: $e');
      Get.snackbar(
        'Printing Error',
        'Could not print the bet ticket. Please check printer connection.',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }
}
