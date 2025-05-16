// No need for material import here
import 'package:get/get.dart';
import 'package:bluetooth_print_plus/bluetooth_print_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

import '../services/printer_service.dart';
import '../widgets/common/modal.dart';

class PrinterController extends GetxController {
  final PrinterService _printerService = Get.find<PrinterService>();
  
  // Reactive variables
  final RxString lastConnectedAddress = ''.obs;
  final RxString lastConnectedName = ''.obs;
  final RxBool isConnected = false.obs;
  final RxBool isConnecting = false.obs;
  final RxList<BluetoothDevice> scanResults = <BluetoothDevice>[].obs;
  final RxBool isScanningNow = false.obs;
  
  // Keys for shared preferences
  static const String _keyLastConnectedAddress = 'last_connected_printer_address';
  static const String _keyLastConnectedName = 'last_connected_printer_name';
  
  // Initialize the controller
  Future<void> init() async {
    // Load saved data from storage
    await _loadSavedPrinterData();
    
    // Setup listeners to printer service state changes
    _setupServiceListeners();
  }
  
  void _setupServiceListeners() {
    // Listen to connection state changes
    ever(_printerService.isConnected, (connected) {
      isConnected.value = connected;
      
      // If disconnected, make sure we update the UI
      if (!connected) {
        isConnecting.value = false;
      }
    });
    
    // Listen to connecting state changes
    ever(_printerService.isConnecting, (connecting) {
      isConnecting.value = connecting;
    });
    
    // Listen to address changes
    ever(_printerService.lastConnectedAddress, (address) {
      lastConnectedAddress.value = address;
      _savePrinterData();
    });
    
    // Listen to name changes
    ever(_printerService.lastConnectedName, (name) {
      lastConnectedName.value = name;
      _savePrinterData();
    });
  }
  
  Future<void> _loadSavedPrinterData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load saved address and name
      final savedAddress = prefs.getString(_keyLastConnectedAddress) ?? '';
      final savedName = prefs.getString(_keyLastConnectedName) ?? '';
      
      // Update local state
      lastConnectedAddress.value = savedAddress;
      lastConnectedName.value = savedName;
      
      // Sync with printer service
      _printerService.lastConnectedAddress.value = savedAddress;
      _printerService.lastConnectedName.value = savedName;
      
      // Check if we're already connected
      isConnected.value = _printerService.isConnected.value;
      isConnecting.value = _printerService.isConnecting.value;
      
      print('Loaded saved printer data: $savedName ($savedAddress)');
    } catch (e) {
      print('Error loading saved printer data: $e');
    }
  }
  
  Future<void> _savePrinterData() async {
    try {
      if (lastConnectedAddress.value.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        
        // Save address and name
        await prefs.setString(_keyLastConnectedAddress, lastConnectedAddress.value);
        await prefs.setString(_keyLastConnectedName, lastConnectedName.value);
        
        print('Saved printer data: ${lastConnectedName.value} (${lastConnectedAddress.value})');
      }
    } catch (e) {
      print('Error saving printer data: $e');
    }
  }
  
  // Start scanning for printers
  Future<void> startScan({Duration timeout = const Duration(seconds: 10)}) async {
    try {
      isScanningNow.value = true;
      scanResults.clear();
      
      // Use the printer service to start scanning
      await _printerService.startScan(timeout: timeout);
    } catch (e) {
      print('Error starting scan: $e');
      isScanningNow.value = false;
      rethrow;
    }
  }
  
  // Stop scanning
  Future<void> stopScan() async {
    try {
      await _printerService.stopScan();
      isScanningNow.value = false;
    } catch (e) {
      print('Error stopping scan: $e');
      rethrow;
    }
  }
  
  // Connect to a printer
  Future<bool> connectToPrinter(BluetoothDevice device) async {
    try {
      // Use the printer service to connect
      final success = await _printerService.connectToPrinter(device);
      
      if (success) {
        // Update local state
        lastConnectedAddress.value = device.address;
        lastConnectedName.value = device.name.isNotEmpty ? device.name : 'Unknown Printer';
        
        // Save to persistent storage
        _savePrinterData();
      }
      
      return success;
    } catch (e) {
      print('Error connecting to printer: $e');
      rethrow;
    }
  }
  
  // Disconnect from printer
  Future<void> disconnectPrinter() async {
    try {
      await _printerService.disconnectPrinter();
    } catch (e) {
      print('Error disconnecting printer: $e');
      rethrow;
    }
  }
  
  // Print test page
  Future<void> printTestPage() async {
    try {
      // Show loading dialog
      Modal.showProgressModal(
        title: 'Printing Test Page',
        message: 'Please wait while the test page is being printed...',
      );
      
      await _printerService.printTestPage();
      
      // Close dialog and show success message
      Modal.closeDialog();
      Modal.showSuccessModal(
        title: 'Test Print Complete',
        message: 'The test page has been sent to the printer.',
        showButton: true,
        buttonText: 'OK',
      );
    } catch (e) {
      // Make sure to close the dialog if there's an error
      Modal.closeDialog();
      
      debugPrint('Error printing test page: $e');
      
      // Show error message
      Modal.showErrorModal(
        title: 'Printing Failed',
        message: 'Failed to print the test page. Please check printer connection.',
      );
    }
  }
  
  // Print a bet ticket
  Future<bool> printBetTicket({
    required String ticketId,
    required String betNumber,
    required dynamic amount,
    int? winningAmount,
    bool? isLowWin,
    required String gameTypeName,
    required String drawTime,
    required String betDate,
    required String status,
    required String tellerName,
    required String tellerUsername,
    required String locationName,
    bool isReprint = false,
  }) async {
    try {
      // Delegate to the printer service
      return await _printerService.printBetTicket(
        ticketId: ticketId,
        betNumber: betNumber,
        amount: amount,
        winningAmount: winningAmount,
        isLowWin: isLowWin,
        gameTypeName: gameTypeName,
        drawTime: drawTime,
        betDate: betDate,
        status: status,
        tellerName: tellerName,
        tellerUsername: tellerUsername,
        locationName: locationName,
        isReprint: isReprint,
      );
    } catch (e) {
      debugPrint('Error printing bet ticket: $e');
      
      // Show error message
      Modal.showErrorModal(
        title: 'Printing Error',
        message: 'Could not print the bet ticket. Please check printer connection.',
      );
      
      return false;
    }
  }
  
  // Update scan results
  void updateScanResults(List<BluetoothDevice> results) {
    // If we have a connected device, make sure it's in the list
    if (isConnected.value && lastConnectedAddress.value.isNotEmpty) {
      final connectedDeviceInResults = results.any((d) => d.address == lastConnectedAddress.value);
      
      if (!connectedDeviceInResults) {
        // Create a device entry for the connected printer
        final connectedDevice = BluetoothDevice(
          lastConnectedName.value.isNotEmpty ? lastConnectedName.value : 'Connected Printer',
          lastConnectedAddress.value
        );
        
        // Add it to the top of the list
        results.insert(0, connectedDevice);
      }
    }
    
    scanResults.value = results;
  }
  
  @override
  void onClose() {
    // Save any pending changes
    _savePrinterData();
    super.onClose();
  }
}
