import 'dart:typed_data';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:bluetooth_print_plus/bluetooth_print_plus.dart';
import 'package:bettingapp/utils/app_colors.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/printer_service.dart';

class PrinterSetupScreen extends StatefulWidget {
  const PrinterSetupScreen({super.key});

  @override
  State<PrinterSetupScreen> createState() => _PrinterSetupScreenState();
}

class _PrinterSetupScreenState extends State<PrinterSetupScreen> {
  BluetoothDevice? _device;
  late StreamSubscription<bool> _isScanningSubscription;
  late StreamSubscription<BlueState> _blueStateSubscription;
  late StreamSubscription<ConnectState> _connectStateSubscription;
  late StreamSubscription<Uint8List> _receivedDataSubscription;
  late StreamSubscription<List<BluetoothDevice>> _scanResultsSubscription;
  List<BluetoothDevice> _scanResults = [];
  
  // Track connection state
  bool _isConnecting = false;
  bool _isConnected = false;
  String _lastConnectedAddress = "";

  @override
  void initState() {
    super.initState();
    initBluetoothPrintPlusListen();
    _loadSavedPrinter();
  }
  
  // Load saved printer from SharedPreferences
  Future<void> _loadSavedPrinter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedAddress = prefs.getString('printer_address');
      final savedName = prefs.getString('printer_name');
      
      if (savedAddress != null && savedAddress.isNotEmpty) {
        setState(() {
          _lastConnectedAddress = savedAddress;
        });
        
        // Try to connect to the saved printer
        if (await BluetoothPrintPlus.isBlueOn) {
          // Start scanning for printers
          await BluetoothPrintPlus.startScan(timeout: const Duration(seconds: 5));
          
          // Wait for scan results and then try to connect to the saved printer
          await Future.delayed(const Duration(seconds: 2));
          
          // Create a device with the saved address and name
          // This is a workaround since we can't easily iterate through the scan results
          final savedDevice = BluetoothDevice(
            savedName ?? 'Unknown Printer',
            savedAddress,
          );
          
          // Try to connect to the saved printer
          _connectToDevice(savedDevice);
        }
      }
    } catch (e) {
      print('Error loading saved printer: $e');
    }
  }
  
  // Save printer to SharedPreferences
  Future<void> _savePrinter(BluetoothDevice device) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('printer_address', device.address);
      await prefs.setString('printer_name', device.name);
      
      // Update the saved printer info
      setState(() {
        _lastConnectedAddress = device.address;
      });
    } catch (e) {
      print('Error saving printer: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
    _isScanningSubscription.cancel();
    _blueStateSubscription.cancel();
    _connectStateSubscription.cancel();
    _receivedDataSubscription.cancel();
    _scanResultsSubscription.cancel();
    _scanResults.clear();
  }

  Future<void> initBluetoothPrintPlusListen() async {
    /// listen scanResults
    _scanResultsSubscription = BluetoothPrintPlus.scanResults.listen((event) {
      if (mounted) {
        setState(() {
          _scanResults = event;
        });
        
        // If we have a saved printer in the scan results, try to auto-connect
        if (_lastConnectedAddress.isNotEmpty && !_isConnected && !_isConnecting) {
          final savedDevice = event.firstWhereOrNull(
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
        setState(() {});
      }
    });

    /// listen connect state
    _connectStateSubscription = BluetoothPrintPlus.connectState.listen((event) {
      print('********** connectState change: $event **********');
      if (event == ConnectState.connected) {
        if (_device != null) {
          // Save the connected printer
          _savePrinter(_device!);
          
          // Update connection state
          setState(() {
            _isConnected = true;
            _isConnecting = false;
            _lastConnectedAddress = _device!.address;
          });
          
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
      } else {
        // Any other state means not connected
        setState(() {
          _isConnected = false;
          _isConnecting = false;
        });
      }
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
          _isConnected
            ? IconButton(
                icon: const Icon(Icons.print),
                onPressed: () => PrinterService().printTestPage(),
                tooltip: 'Test Print',
              )
            : const SizedBox.shrink(),
          BluetoothPrintPlus.isScanningNow
              ? Container(
                  margin: const EdgeInsets.only(right: 16),
                  width: 20,
                  height: 20,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ))
              : IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: onScanPressed,
                  tooltip: 'Scan for printers',
                ),
        ],
      ),
      body: Column(
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
                  'Make sure your Bluetooth printer is turned on and in pairing mode. Select your printer from the list below to connect.',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                  ),
                ),
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
                      final bool isConnected = _device?.address == device.address;
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: (_isConnected && device.address == _lastConnectedAddress)
                            ? AppColors.primaryRed 
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        _connectToDevice(device);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Printer Icon
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.printerColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.print,
                                color: AppColors.printerColor,
                                size: 24,
                              ),
                            ),
                            
                            const SizedBox(width: 16),
                            
                            // Printer Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    device.name.isEmpty ? 'Unknown Device' : device.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    device.address,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Connection Status
                            Builder(builder: (context) {
                              if (_isConnected && device.address == _lastConnectedAddress) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.green.shade700,
                                        size: 16,
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
                              } else if (_isConnecting && _device?.address == device.address) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.amber.shade700,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Connecting...',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.amber.shade700,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              } else if (!_isConnected && device.address == _lastConnectedAddress) {
                                return OutlinedButton(
                                  onPressed: () => _connectToDevice(device),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.amber.shade800,
                                    side: BorderSide(color: Colors.amber.shade800),
                                  ),
                                  child: const Text('Reconnect'),
                                );
                              } else {
                                return OutlinedButton(
                                  onPressed: () => _connectToDevice(device),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primaryRed,
                                    side: BorderSide(color: AppColors.primaryRed),
                                  ),
                                  child: const Text('Connect'),
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
      floatingActionButton: BluetoothPrintPlus.isBlueOn && !BluetoothPrintPlus.isScanningNow
          ? FloatingActionButton(
              onPressed: onScanPressed,
              backgroundColor: AppColors.primaryRed,
              child: Icon(Icons.refresh),
            )
          : null,
    );
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

  // Connect to a device with loading state
  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      // Set connecting state
      setState(() {
        _isConnecting = true;
        _device = device;
      }); // Update UI to show connecting state
      
      // Try to connect
      await BluetoothPrintPlus.connect(device);
      
      // Connection state will be updated by the listener
    } catch (e) {
      print('Error connecting to printer: $e');
      setState(() {
        _isConnecting = false;
      });
      
      // Show error message
      Get.snackbar(
        'Connection Failed', 
        'Could not connect to ${device.name}. Please try again.',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }
  


  Future onScanPressed() async {
    try {
      await BluetoothPrintPlus.startScan(timeout: Duration(seconds: 10));
    } catch (e) {
      print("onScanPressed error: $e");
      Get.snackbar(
        'Scan Error', 
        'Could not scan for printers: $e',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.all(16),
      );
    }
  }

  Future onStopPressed() async {

    try {
      BluetoothPrintPlus.stopScan();
    } catch (e) {
      print("onStopPressed error: $e");
    }
    
  }

}