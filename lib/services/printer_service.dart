import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bluetooth_print_plus/bluetooth_print_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Modal dialogs use their own colors for CircularProgressIndicator
import '../widgets/common/modal.dart';
import '../screens/teller/printer_setup_screen.dart';

class PrinterService {
  // Singleton instance
  static final PrinterService _instance = PrinterService._internal();
  factory PrinterService() => _instance;
  PrinterService._internal();
  
  // Connection state
  final RxBool isConnected = false.obs;
  final RxString lastConnectedAddress = "".obs;
  final RxString lastConnectedName = "".obs;
  
  // Initialize printer service
  Future<void> init() async {
    await _loadSavedPrinter();
  }
  
  // Load saved printer from SharedPreferences
  Future<void> _loadSavedPrinter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedAddress = prefs.getString('printer_address');
      final savedName = prefs.getString('printer_name');
      
      if (savedAddress != null && savedName != null) {
        lastConnectedAddress.value = savedAddress;
        lastConnectedName.value = savedName;
        
        // Check if already connected
        bool connected = false;
        try {
          connected = await BluetoothPrintPlus.isConnected;
        } catch (e) {
          debugPrint('Error checking connection: $e');
        }
        
        isConnected.value = connected;
      }
    } catch (e) {
      debugPrint('Error loading saved printer: $e');
    }
  }
  
  // Check printer connection and prompt to connect if needed
  Future<bool> ensurePrinterConnected() async {
    bool connected = false;
    try {
      connected = await BluetoothPrintPlus.isConnected;
      isConnected.value = connected;
    } catch (e) {
      debugPrint('Error checking printer connection: $e');
      isConnected.value = false;
      connected = false;
    }
    
    if (!connected) {
      Completer<bool> setupCompleter = Completer<bool>();
      
      Modal.showConfirmationModal(
        title: 'Printer Not Connected',
        message: 'You need to connect to a printer first. Would you like to set up a printer now?',
        confirmText: 'Setup Printer',
        cancelText: 'Cancel',
        animation: 'assets/animations/questionmark.json',
        onConfirm: () {
          setupCompleter.complete(true);
        },
        onCancel: () {
          setupCompleter.complete(false);
        },
      );
      
      bool shouldSetupPrinter = await setupCompleter.future;
      
      if (shouldSetupPrinter) {
        await Get.to(() => const PrinterSetupScreen());
        // Check connection again after returning from setup screen
        try {
          connected = await BluetoothPrintPlus.isConnected;
          isConnected.value = connected;
          
          if (!connected) {
            Modal.showErrorModal(
              title: 'Printer Not Connected',
              message: 'Could not connect to a printer. Please try again.',
            );
          }
        } catch (e) {
          // Error checking connection
          Modal.showErrorModal(
            title: 'Connection Error',
            message: 'Could not verify printer connection. Please try again.',
          );
        }
      }
    }
    
    return connected;
  }
  
  // Print a bet ticket
  Future<bool> printBetTicket({
    required String ticketId,
    required String betNumber,
    required dynamic amount,
    required String gameTypeName,
    required String drawTime,
    required String betDate,
    required String status,
    required String tellerName,
    required String tellerUsername,
    required String locationName,
    bool isReprint = false,
  }) async {
    // Check if connected to a printer
    if (!await ensurePrinterConnected()) {
      return false;
    }
    
    try {
      // Show loading dialog
      Modal.showProgressModal(
        title: 'Printing Ticket',
        message: 'Please wait while the ticket is being printed...',
      );
      
      // Generate receipt content
      final List<int> bytes = [];
      
      // Initialize printer
      bytes.addAll([27, 64]); // ESC @
      
      // Center align
      bytes.addAll([27, 97, 1]); // ESC a 1
      
      // Bold on
      bytes.addAll([27, 69, 1]); // ESC E 1
      
      // Title
      bytes.addAll(utf8.encode('BETTING RECEIPT\n'));
      
      // Bold off
      bytes.addAll([27, 69, 0]); // ESC E 0
      
      // Company name
      bytes.addAll([27, 33, 16]); // ESC ! 16 (Double height)
      bytes.addAll(utf8.encode('LUCY BETTING\n'));
      bytes.addAll([27, 33, 0]); // ESC ! 0 (Normal)
      
      // Location
      bytes.addAll(utf8.encode('$locationName\n'));
      bytes.addAll(utf8.encode('--------------------------------\n'));
      
      // Left align
      bytes.addAll([27, 97, 0]); // ESC a 0
      
      // QR code for ticket ID (if supported by printer)
      // Center align for QR code
      bytes.addAll([27, 97, 1]); // ESC a 1
      
      // QR Code - Model 2
      bytes.addAll([29, 40, 107, 3, 0, 49, 65, 50, 0]); // GS ( k 3 0 49 65 50 0
      // QR Code - Set size (6)
      bytes.addAll([29, 40, 107, 3, 0, 49, 67, 6, 0]); // GS ( k 3 0 49 67 6 0
      // QR Code - Set error correction level (48 - L)
      bytes.addAll([29, 40, 107, 3, 0, 49, 69, 48, 0]); // GS ( k 3 0 49 69 48 0
      // QR Code - Store data in symbol storage area
      bytes.addAll([29, 40, 107, ticketId.length + 3, 0, 49, 80, 48]); // GS ( k (data length + 3) 0 49 80 48
      bytes.addAll(utf8.encode(ticketId));
      // QR Code - Print symbol data in symbol storage area
      bytes.addAll([29, 40, 107, 3, 0, 49, 81, 48, 0]); // GS ( k 3 0 49 81 48 0
      
      // Add some space after QR code
      bytes.addAll(utf8.encode('\n'));
      
      // Left align for details
      bytes.addAll([27, 97, 0]); // ESC a 0
      
      // Add ticket details
      bytes.addAll(utf8.encode('--------------------------------\n'));
      bytes.addAll(utf8.encode('Ticket ID: $ticketId\n'));
      bytes.addAll(utf8.encode('Bet Number: $betNumber\n'));
      bytes.addAll(utf8.encode('Amount: ₱${amount is int ? amount : (amount is double ? amount.toInt() : amount)}\n'));
      bytes.addAll(utf8.encode('Game Type: $gameTypeName\n'));
      bytes.addAll(utf8.encode('Draw Time: $drawTime\n'));
      bytes.addAll(utf8.encode('Date: $betDate\n'));
      bytes.addAll(utf8.encode('Status: $status\n'));
      bytes.addAll(utf8.encode('--------------------------------\n'));
      
      // Add teller information
      bytes.addAll(utf8.encode('Teller: $tellerName\n'));
      if (tellerUsername.isNotEmpty) {
        bytes.addAll(utf8.encode('ID: $tellerUsername\n'));
      }
      bytes.addAll(utf8.encode('Printed: ${DateFormat('MM/dd/yyyy hh:mm a').format(DateTime.now())}\n'));
      bytes.addAll(utf8.encode('--------------------------------\n'));
      
      // Center align for footer
      bytes.addAll([27, 97, 1]); // ESC a 1
      
      // Add reprint watermark if needed
      if (isReprint) {
        // Bold on for watermark
        bytes.addAll([27, 69, 1]); // ESC E 1
        bytes.addAll(utf8.encode('REPRINT - NOT FOR BETTING\n'));
        bytes.addAll([27, 69, 0]); // ESC E 0
      }
      
      bytes.addAll(utf8.encode('Thank you for playing!\n'));
      bytes.addAll(utf8.encode('www.lucybetting.com\n\n'));
      
      // Cut paper
      bytes.addAll([29, 86, 66, 0]); // GS V B 0
      
      // Send to printer
      await BluetoothPrintPlus.write(Uint8List.fromList(bytes));
      
      // Close dialog and show success message
      Modal.closeDialog();
      Modal.showSuccessModal(
        title: 'Printing Complete',
        message: 'The ticket has been sent to the printer.',
        showButton: true,
        buttonText: 'OK',
      );
      
      return true;
    } catch (e) {
      // Close dialog and show error message
      Modal.closeDialog();
      Modal.showErrorModal(
        title: 'Printing Failed',
        message: 'Failed to print the ticket. Error: $e',
      );
      return false;
    }
  }
  
  // Print a test page
  Future<bool> printTestPage() async {
    // Check if connected to a printer
    if (!await ensurePrinterConnected()) {
      return false;
    }
    
    try {
      // Show loading indicator
      Modal.showProgressModal(
        title: 'Printing Test Page',
        message: 'Please wait while the test page is being printed...',
      );
      
      // Simple test print command
      final List<int> bytes = [];
      // Initialize printer
      bytes.addAll([27, 64]); // ESC @
      // Center align
      bytes.addAll([27, 97, 1]); // ESC a 1
      // Bold on
      bytes.addAll([27, 69, 1]); // ESC E 1
      // Title
      bytes.addAll(utf8.encode('TEST PRINT\n'));
      // Bold off
      bytes.addAll([27, 69, 0]); // ESC E 0
      // Company name
      bytes.addAll([27, 33, 16]); // ESC ! 16 (Double height)
      bytes.addAll(utf8.encode('LUCY BETTING\n'));
      bytes.addAll([27, 33, 0]); // ESC ! 0 (Normal)
      // Test content
      bytes.addAll(utf8.encode('Printer connected successfully\n'));
      bytes.addAll(utf8.encode('--------------------------------\n'));
      bytes.addAll(utf8.encode('Printer: ${lastConnectedName.value}\n'));
      bytes.addAll(utf8.encode('Date: ${DateFormat('MM/dd/yyyy hh:mm a').format(DateTime.now())}\n'));
      bytes.addAll(utf8.encode('--------------------------------\n'));
      bytes.addAll(utf8.encode('This is a test print.\n'));
      bytes.addAll(utf8.encode('If you can read this, your printer\n'));
      bytes.addAll(utf8.encode('is working correctly.\n\n'));
      // Cut paper
      bytes.addAll([29, 86, 66, 0]); // GS V B 0
      
      // Print
      await BluetoothPrintPlus.write(Uint8List.fromList(bytes));
      
      // Close dialog
      Modal.closeDialog();
      
      // Show success message
      Modal.showSuccessModal(
        title: 'Test Print Complete',
        message: 'The test page has been sent to the printer.',
        showButton: true,
        buttonText: 'OK',
      );
      
      return true;
    } catch (e) {
      // Close dialog if open
      Modal.closeDialog();
      
      debugPrint('Error printing: $e');
      Modal.showErrorModal(
        title: 'Printing Failed', 
        message: 'Error: $e',
      );
      
      return false;
    }
  }
}
