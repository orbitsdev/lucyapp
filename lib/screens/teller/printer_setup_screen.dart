import 'dart:typed_data';
import 'dart:async';
import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:bluetooth_print_plus/bluetooth_print_plus.dart';
import 'package:bettingapp/utils/app_colors.dart';
import 'package:get/get.dart';

import '../../controllers/printer_controller.dart';

class PrinterSetupScreen extends StatefulWidget {
  const PrinterSetupScreen({super.key});

  @override
  State<PrinterSetupScreen> createState() => _PrinterSetupScreenState();
}

class _PrinterSetupScreenState extends State<PrinterSetupScreen> {
  // Get the global printer controller
  final PrinterController _printerController = Get.find<PrinterController>();
  
  BluetoothDevice? _device;
  late StreamSubscription<bool> _isScanningSubscription;
  late StreamSubscription<BlueState> _blueStateSubscription;
  late StreamSubscription<ConnectState> _connectStateSubscription;
  late StreamSubscription<Uint8List> _receivedDataSubscription;
  late StreamSubscription<List<BluetoothDevice>> _scanResultsSubscription;
  List<BluetoothDevice> _scanResults = [];
  
  // Local variables to track UI state
  String _lastConnectedAddress = "";

  @override
  void initState() {
    super.initState();
    _initializeController();
    initBluetoothPrintPlusListen();
    
    // Initialize local state from the controller
    _lastConnectedAddress = _printerController.lastConnectedAddress.value;
    
    // If we have a last connected address and the printer is connected,
    // create a device entry for it to ensure it's displayed
    if (_printerController.isConnected.value && _lastConnectedAddress.isNotEmpty) {
      _device = BluetoothDevice(
        _printerController.lastConnectedName.value.isNotEmpty 
            ? _printerController.lastConnectedName.value 
            : 'Connected Printer',
        _lastConnectedAddress
      );
      
      // Make sure the connected device is in the scan results
      _ensureConnectedDeviceInResults();
    }
    
    // Start scanning for printers
    _startScan();
  }
  
  // Initialize the controller
  Future<void> _initializeController() async {
    await _printerController.init();
  }
  
  // Ensure the connected device is in the scan results
  void _ensureConnectedDeviceInResults() {
    if (_device != null && _printerController.isConnected.value) {
      // Check if the device is already in the scan results
      final deviceInResults = _scanResults.any((d) => d.address == _device!.address);
      
      if (!deviceInResults) {
        // Add the connected device to the scan results if it's not already there
        setState(() {
          _scanResults.insert(0, _device!);
        });
      }
    }
  }

  // Start scanning for printers with improved error handling
  Future<void> _startScan() async {
    try {
      if (await BluetoothPrintPlus.isBlueOn) {
        // Use the printer controller to start scanning
        await _printerController.startScan(timeout: const Duration(seconds: 8)); // Increased timeout for better discovery
        
        // Add a small delay to allow scan results to populate before attempting reconnection
        if (_lastConnectedAddress.isNotEmpty && !_printerController.isConnected.value && !_printerController.isConnecting.value) {
          // Delay reconnection attempt to allow scan to find devices first
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted && !_printerController.isConnected.value && !_printerController.isConnecting.value) {
              _reconnectLastPrinter();
            }
          });
        }
      } else {
        // Show a message to the user about Bluetooth being off
        Get.snackbar(
          'Bluetooth Off',
          'Please turn on Bluetooth to scan for printers',
          backgroundColor: Colors.amber.shade100,
          colorText: Colors.amber.shade900,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      print('Error starting scan: $e');
      Get.snackbar(
        'Scan Error',
        'Could not scan for printers: $e',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
    }
  }
  
  // Enhanced reconnection logic with retry mechanism
  Future<void> _reconnectLastPrinter() async {
    if (_lastConnectedAddress.isEmpty || _printerController.isConnected.value || _printerController.isConnecting.value) {
      return;
    }
    
    // Show a subtle connecting indicator
    Get.snackbar(
      'Reconnecting',
      'Attempting to reconnect to your last printer...',
      backgroundColor: Colors.blue.shade50,
      colorText: Colors.blue.shade800,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
    
    // Check if the device is in scan results
    final savedDevice = _scanResults.firstWhereOrNull(
      (device) => device.address == _lastConnectedAddress
    );
    
    if (savedDevice != null) {
      // Connect to the saved device from scan results
      print('Reconnecting to device found in scan results: ${savedDevice.name}');
      _connectToDevice(savedDevice);
    } else if (_device != null && _device!.address == _lastConnectedAddress) {
      // Connect to the stored device reference
      print('Reconnecting to stored device reference: ${_device!.name}');
      _connectToDevice(_device!);
    } else {
      // Create a temporary device and try to connect
      final tempDevice = BluetoothDevice(
        _printerController.lastConnectedName.value.isNotEmpty 
            ? _printerController.lastConnectedName.value 
            : 'Last Connected Printer',
        _lastConnectedAddress
      );
      print('Reconnecting to recreated device: ${tempDevice.name}');
      _connectToDevice(tempDevice);
      
      // If the device isn't in scan results, trigger a new scan after connection attempt
      // This helps in case the device is powered on after opening the screen
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && !_printerController.isConnected.value && !_printerController.isConnecting.value) {
          print('Device not found in initial scan, starting a new scan');
          onScanPressed(); // Start a new scan to find the device
        }
      });
    }
  }
  
  // Update local state when a printer is connected
  void _updateLocalState() {
    setState(() {
      _lastConnectedAddress = _printerController.lastConnectedAddress.value;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _isScanningSubscription.cancel();
    _blueStateSubscription.cancel();
    
    // Stop scanning if we're leaving the screen
    if (_printerController.isScanningNow.value) {
      _printerController.stopScan();
    }
    
    _connectStateSubscription.cancel();
    _receivedDataSubscription.cancel();
    _scanResultsSubscription.cancel();
    _scanResults.clear();
  }

  // Initialize Bluetooth listeners
  Future<void> initBluetoothPrintPlusListen() async {
    // Listen for scan results
    _scanResultsSubscription = BluetoothPrintPlus.scanResults.listen((devices) {
      if (mounted) {
        // Create a new list from the scan results
        List<BluetoothDevice> updatedResults = List.from(devices);
        
        // Update the controller with the scan results
        _printerController.updateScanResults(updatedResults);
        
        setState(() {
          _scanResults = updatedResults;
          // Ensure connected device is in the results
          _ensureConnectedDeviceInResults();
        });
      }
    });
    
    // Listen for scanning state changes
    _isScanningSubscription = BluetoothPrintPlus.isScanning.listen((isScanning) {
      if (mounted) {
        // Update controller's scanning state
        _printerController.isScanningNow.value = isScanning;
        setState(() {});
      }
    });
    
    // Listen for Bluetooth state changes
    _blueStateSubscription = BluetoothPrintPlus.blueState.listen((state) async {
      if (mounted) {
        // Check Bluetooth state - need to use async here
        final bool isBluetoothOn = await BluetoothPrintPlus.isBlueOn;
        
        if (isBluetoothOn) {
          // Bluetooth turned on, start scanning
          _startScan();
        } else {
          // Bluetooth turned off, update UI
          setState(() {
            _scanResults = [];
          });
        }
      }
    });
    
    // Listen for connection state changes
    _connectStateSubscription = BluetoothPrintPlus.connectState.listen((state) {
      if (mounted) {
        // Update controller's connection state based on ConnectState
        _printerController.isConnected.value = state == ConnectState.connected;
        _printerController.isConnecting.value = state != ConnectState.connected && state != ConnectState.disconnected;
        
        // Update local state when connection status changes
        _updateLocalState();
      }
    });
    
    // We don't need to listen for received data in this screen
    // Just set up a dummy subscription to avoid null errors
    _receivedDataSubscription = Stream<Uint8List>.empty().listen((data) {});
  }

  Future<void> initBluetoothPrintPlusListenOld() async {
    /// listen scanResults
    _scanResultsSubscription = BluetoothPrintPlus.scanResults.listen((event) {
      if (mounted) {
        // Create a new list from the scan results
        List<BluetoothDevice> updatedResults = List.from(event);
        
        // If we have a connected device that's not in the scan results, add it
        if (_printerController.isConnected.value && _lastConnectedAddress.isNotEmpty) {
          final connectedDeviceInResults = updatedResults.any((d) => d.address == _lastConnectedAddress);
          
          if (!connectedDeviceInResults && _device != null) {
            // Add the connected device at the top of the list
            updatedResults.insert(0, _device!);
          }
        }
        
        setState(() {
          _scanResults = updatedResults;
        });
        
        // If we have a saved printer in the scan results, try to auto-connect
        if (_lastConnectedAddress.isNotEmpty && !_printerController.isConnected.value && !_printerController.isConnecting.value) {
          final savedDevice = updatedResults.firstWhereOrNull(
            (device) => device.address == _lastConnectedAddress
          );
          
          if (savedDevice != null) {
            // Auto-connect to the saved printer
            _connectToDevice(savedDevice);
          }
        }
      }
    });

    /// listen isScanning
    _isScanningSubscription = BluetoothPrintPlus.isScanning.listen((event) {
      print('********** isScanning: $event **********');
      if (mounted) {
        setState(() {});
      }
    });

    /// listen blue state
    _blueStateSubscription = BluetoothPrintPlus.blueState.listen((event) {
      print('********** blueState change: $event **********');
      if (mounted) {
        // Check if Bluetooth is on using the correct enum
        if (event == BlueState.blueOn) {
          // Bluetooth turned on, start scanning
          _startScan();
        } else {
          // Bluetooth turned off, update UI
          setState(() {
            _scanResults = [];
          });
        }
      }
    });

    /// listen connect state
    _connectStateSubscription = BluetoothPrintPlus.connectState.listen((event) {
      print('********** connectState change: $event **********');
      if (event == ConnectState.connected) {
        if (_device != null) {
          // Update local state
          _updateLocalState();
          
          // Show success message
          Get.snackbar(
            'Printer Connected', 
            'Successfully connected to ${_device!.name}',
            backgroundColor: Colors.green.shade100,
            colorText: Colors.green.shade800,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          );
        }
      }
      
      // Always update UI when connection state changes
      setState(() {});
    });

    /// listen received data
    _receivedDataSubscription = BluetoothPrintPlus.receivedData.listen((data) {
      print('********** received data: $data **********');

      /// do something...
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('PRINTER SETUP'),
        backgroundColor: AppColors.primaryRed,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white,),
          onPressed: () => Get.back(),
        ),
        actions: [
          // Use Obx to reactively update based on connection state
          Obx(() => _printerController.isConnected.value
            ? IconButton(
                icon: const Icon(Icons.print, color: Colors.white,),
                onPressed: () => _printerController.printTestPage(),
                tooltip: 'Test Print',
              )
            : const SizedBox.shrink()),
          Obx(() => _printerController.isScanningNow.value
              ? Container(
                  margin: const EdgeInsets.only(right: 16),
                  width: 20,
                  height: 20,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ))
              : IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white,),
                  onPressed: onScanPressed,
                  tooltip: 'Scan for printers',
                )),
        ],
      ),
      body: Column(
        children: [
          // Instructions
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _printerController.isConnected.value ? Colors.green.shade50 : AppColors.primaryRed.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _printerController.isConnected.value ? Colors.green.shade200 : AppColors.primaryRed.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _printerController.isConnected.value ? Icons.check_circle : Icons.info,
                      color: _printerController.isConnected.value ? Colors.green.shade700 : AppColors.primaryRed,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Printer Connection',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _printerController.isConnected.value ? Colors.green.shade700 : AppColors.primaryRed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Obx(() {
                  final connectedName = _printerController.lastConnectedName.value.isNotEmpty
                      ? _printerController.lastConnectedName.value
                      : (_lastConnectedAddress.isNotEmpty
                          ? _lastConnectedAddress
                          : 'Unknown Printer');
                  
                  return Text(
                    _printerController.isConnected.value
                        ? 'Your printer "$connectedName" is connected and ready to use. You can print a test page or disconnect using the buttons above.'
                        : 'Make sure your Bluetooth printer is turned on and in pairing mode. Select your printer from the list below to connect. Previously connected printers will be highlighted.',
                    style: TextStyle(
                      color: _printerController.isConnected.value ? Colors.green.shade700 : AppColors.primaryRed,
                    ),
                  );
                }),
              ],
            ),
          ),
          
          // Bluetooth Status Indicator (when off)
          !BluetoothPrintPlus.isBlueOn
              ? Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade100),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.bluetooth_disabled,
                            color: Colors.red.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Bluetooth is turned off',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please turn on Bluetooth to scan for and connect to printers.',
                        style: TextStyle(
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
          
          // Connected Printer Section (if any)
          Obx(() {
            if (_printerController.isConnected.value && _lastConnectedAddress.isNotEmpty) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.green.shade700,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Connected Printer',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _printerController.lastConnectedName.value.isNotEmpty
                                    ? _printerController.lastConnectedName.value
                                    : _lastConnectedAddress,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _printerController.disconnectPrinter(),
                          icon: Icon(Icons.bluetooth_disabled, color: Colors.red.shade700, size: 16),
                          label: Text('Disconnect', style: TextStyle(color: Colors.red.shade700)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.red.shade200),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _printerController.printTestPage(),
                          icon: const Icon(Icons.print, size: 16),
                          label: const Text('Print Test Page'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.green.shade700,
                            side: BorderSide(color: Colors.green.shade300),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            } else if (_lastConnectedAddress.isNotEmpty && !_printerController.isConnecting.value) {
              // Show last connected printer with reconnect option
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.bluetooth,
                        color: Colors.amber.shade700,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Last Connected Printer',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _printerController.lastConnectedName.value.isNotEmpty
                                ? _printerController.lastConnectedName.value
                                : _lastConnectedAddress,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.amber.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _reconnectLastPrinter,
                      icon: const Icon(Icons.bluetooth_connected, size: 16),
                      label: const Text('Reconnect'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
              );
            } else if (_printerController.isConnecting.value) {
              // Show connecting status
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Connecting to Printer',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _device != null 
                                ? (_device!.name.isNotEmpty ? _device!.name : _device!.address)
                                : 'Please wait...',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          }),
            
          // Available Printers List
          Expanded(
            child: _scanResults.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.print_disabled,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No printers found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          BluetoothPrintPlus.isScanningNow
                              ? 'Scanning for printers...'
                              : 'Make sure your printer is turned on\nand tap refresh to scan again',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (!BluetoothPrintPlus.isScanningNow) ...[  
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: onScanPressed,
                            icon: const Icon(Icons.refresh),
                            label: const Text('SCAN AGAIN'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.printerColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _scanResults.length,
                    itemBuilder: (context, index) {
                      final device = _scanResults[index];
                      
                      // Show different colors based on connection status
                  final bool isConnected = _printerController.isConnected.value && device.address == _lastConnectedAddress;
                  final bool isLastConnected = device.address == _lastConnectedAddress;
                  
                  return Card(
                    elevation: isConnected ? 3 : isLastConnected ? 2 : 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: isConnected 
                            ? Colors.green.shade200 
                            : isLastConnected 
                                ? Colors.amber.shade200 
                                : Colors.grey.shade300,
                        width: isConnected || isLastConnected ? 1.5 : 1,
                      ),
                    ),
                    color: isConnected 
                        ? Colors.green.shade50 // Connected device
                        : isLastConnected 
                            ? Colors.amber.shade50 // Last connected but not currently connected
                            : Colors.grey.shade50, // Other devices
                    child: InkWell(
                      onTap: () {
                        _connectToDevice(device);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Printer Icon with device type indicator
                            Stack(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: isConnected
                                        ? Colors.green.shade50
                                        : isLastConnected
                                            ? Colors.amber.shade50
                                            : AppColors.printerColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isConnected
                                          ? Colors.green.shade300
                                          : isLastConnected
                                              ? Colors.amber.shade300
                                              : Colors.transparent,
                                      width: isConnected ? 2 : 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      _getPrinterIcon(device.name),
                                      color: isConnected
                                          ? Colors.green.shade700
                                          : isLastConnected
                                              ? Colors.amber.shade700
                                              : AppColors.printerColor,
                                      size: 24,
                                    ),
                                  ),
                                ),
                                if (isConnected)
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade100,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 1.5),
                                      ),
                                      child: Icon(
                                        Icons.check,
                                        size: 10,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            
                            const SizedBox(width: 16),
                            
                            // Printer Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        device.name.isEmpty ? 'Unknown Device' : device.name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isConnected ? Colors.green.shade800 : Colors.black87,
                                        ),
                                      ),
                                      if (isConnected)
                                        Container(
                                          margin: const EdgeInsets.only(left: 8),
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade100,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'Active',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green.shade800,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        _getDeviceType(device.name),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        height: 4,
                                        width: 4,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade400,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          device.address,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            
                            // Connection Status
                            Obx(() {
                              if (_printerController.isConnecting.value && _device?.address == device.address) {
                                // Currently connecting to this device
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.blue.shade700,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Connecting...',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              } else if (isConnected) {
                                // This is the currently connected device
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.green.shade500),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        size: 16,
                                        color: Colors.green.shade700,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Connected',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.green.shade700,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              } else if (isLastConnected) {
                                // This was the last connected device
                                return ElevatedButton.icon(
                                  onPressed: _reconnectLastPrinter,
                                  icon: const Icon(Icons.bluetooth_connected, size: 16),
                                  label: const Text('Reconnect'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.amber.shade600,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                );
                              } else {
                                // Regular device
                                return OutlinedButton.icon(
                                  onPressed: () => _connectToDevice(device),
                                  icon: const Icon(Icons.bluetooth, size: 16),
                                  label: const Text('Connect'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primaryRed,
                                    side: BorderSide(color: AppColors.primaryRed),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                );
                              }
                            }),
                            
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: Obx(() {
        if (BluetoothPrintPlus.isBlueOn && !_printerController.isScanningNow.value) {
          return FloatingActionButton(
            onPressed: onScanPressed,
            backgroundColor: AppColors.primaryRed,
            child: const Icon(Icons.refresh, color: Colors.white),
          );
        } else {
          return const SizedBox.shrink(); // Return an empty widget instead of null
        }
      }),
    );
  }

  // Helper method to determine printer icon based on device name
  IconData _getPrinterIcon(String deviceName) {
    final name = deviceName.toLowerCase();
    
    if (name.contains('epson') || name.contains('tm-')) {
      return Icons.receipt_long; // Receipt printer icon for Epson
    } else if (name.contains('hp') || name.contains('canon') || name.contains('brother')) {
      return Icons.print; // Standard printer icon for major brands
    } else if (name.contains('zebra') || name.contains('label')) {
      return Icons.qr_code; // Label printer icon for Zebra
    } else if (name.contains('star')) {
      return Icons.receipt; // Receipt printer icon for Star
    } else {
      return Icons.print; // Default printer icon
    }
  }
  
  // Helper method to determine device type based on name
  String _getDeviceType(String deviceName) {
    final name = deviceName.toLowerCase();
    
    if (name.isEmpty) {
      return 'Unknown Printer';
    } else if (name.contains('epson') || name.contains('tm-')) {
      return 'Thermal Receipt Printer';
    } else if (name.contains('zebra')) {
      return 'Label Printer';
    } else if (name.contains('star')) {
      return 'POS Printer';
    } else if (name.contains('hp') || name.contains('canon') || name.contains('brother')) {
      return 'Office Printer';
    } else if (name.contains('bluetooth')) {
      return 'Bluetooth Printer';
    } else {
      return 'Generic Printer';
    }
  }

  Widget buildBlueOffWidget() {
    return Center(
        child: Text(
      "Bluetooth is turned off\nPlease turn on Bluetooth...",
      style: TextStyle(
          fontWeight: FontWeight.w700, fontSize: 16, color: Colors.red),
      textAlign: TextAlign.center,
    ));
  }

  Widget buildScanButton(BuildContext context) {
    if (BluetoothPrintPlus.isScanningNow) {
      return FloatingActionButton(
        onPressed: onStopPressed,
        backgroundColor: Colors.red,
        child: Icon(Icons.stop),
      );
    } else {
      return FloatingActionButton(
          onPressed: onScanPressed,
          backgroundColor: Colors.green,
          child: Text("SCAN"));
    }
  }

  // Enhanced device connection with better error handling and retry logic
  Future<void> _connectToDevice(BluetoothDevice device) async {
    // Prevent multiple connection attempts to the same device
    if (_printerController.isConnecting.value) {
      print('Already connecting to a device, ignoring new connection request');
      return;
    }
    
    try {
      // Store the device reference for UI updates
      setState(() {
        _device = device;
      });
      
      print('Attempting to connect to printer: ${device.name} (${device.address})');
      
      // Use the printer controller to connect
      final success = await _printerController.connectToPrinter(device);
      
      if (success) {
        // Ensure the connected device is in the scan results
        _ensureConnectedDeviceInResults();
        
        // Update local state to reflect connection
        _updateLocalState();
        
        print('Successfully connected to printer: ${device.name}');
      } else {
        // Connection failed but not due to an exception
        print('Connection failed to printer: ${device.name}');
        
        // Show error message if connection failed
        Get.snackbar(
          'Connection Failed', 
          'Could not connect to ${device.name}. Please make sure the printer is turned on and try again.',
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
          mainButton: TextButton(
            onPressed: () => _connectToDevice(device),
            child: Text('Retry', style: TextStyle(color: Colors.red.shade800, fontWeight: FontWeight.bold)),
          ),
        );
        
        // Clear the device reference if connection failed
        if (_device?.address == device.address) {
          setState(() {
            _device = null;
          });
        }
      }
    } catch (e) {
      print('Error connecting to printer: $e');
      
      // Show error message with retry option
      Get.snackbar(
        'Connection Error', 
        'Error connecting to ${device.name}: ${e.toString().substring(0, Math.min(e.toString().length, 100))}',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        mainButton: TextButton(
          onPressed: () => _connectToDevice(device),
          child: Text('Retry', style: TextStyle(color: Colors.red.shade800, fontWeight: FontWeight.bold)),
        ),
      );
      
      // Clear the device reference if connection failed
      if (_device?.address == device.address) {
        setState(() {
          _device = null;
        });
      }
    }
  }
  


  // Enhanced scan with progress indicator and better error handling
  Future<void> onScanPressed() async {
    try {
      // Clear previous scan results first - now handled by controller
      setState(() {
        _scanResults = [];
      });
      
      // Check if Bluetooth is on
      if (!(await BluetoothPrintPlus.isBlueOn)) {
        Get.snackbar(
          'Bluetooth Off',
          'Please turn on Bluetooth to scan for printers',
          backgroundColor: Colors.amber.shade100,
          colorText: Colors.amber.shade900,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );
        return;
      }
      
      // Show a scanning indicator
      Get.snackbar(
        'Scanning', 
        'Looking for nearby Bluetooth printers...',
        backgroundColor: Colors.blue.shade50,
        colorText: Colors.blue.shade800,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
      
      // Use the printer controller to start scanning with longer timeout
      await _printerController.startScan(timeout: const Duration(seconds: 12));
      
      // After scan completes, check if we found any devices
      Future.delayed(const Duration(seconds: 13), () {
        if (mounted && _scanResults.isEmpty && !BluetoothPrintPlus.isScanningNow) {
          Get.snackbar(
            'No Printers Found', 
            'Make sure your printer is turned on and in pairing mode.',
            backgroundColor: Colors.amber.shade50,
            colorText: Colors.amber.shade800,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          );
        }
      });
    } catch (e) {
      print("onScanPressed error: $e");
      Get.snackbar(
        'Scan Error', 
        'Could not scan for printers: ${e.toString().substring(0, Math.min(e.toString().length, 100))}',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        mainButton: TextButton(
          onPressed: onScanPressed,
          child: Text('Retry', style: TextStyle(color: Colors.red.shade800, fontWeight: FontWeight.bold)),
        ),
      );
    }
  }

  Future onStopPressed() async {
    try {
      // Use the printer controller to stop scanning
      await _printerController.stopScan();
    } catch (e) {
      print("onStopPressed error: $e");
    }
  }

}