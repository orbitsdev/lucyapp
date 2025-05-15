import 'package:bettingapp/controllers/dropdown_controller.dart';
import 'package:bettingapp/controllers/betting_controller.dart';
import 'package:bettingapp/controllers/report_controller.dart';
import 'package:bettingapp/widgets/common/modal.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bettingapp/utils/app_colors.dart';
import 'package:bettingapp/services/printer_service.dart';
import 'package:intl/intl.dart';

class NewBetScreen extends StatefulWidget {
  const NewBetScreen({super.key});

  @override
  State<NewBetScreen> createState() => _NewBetScreenState();
}

class _NewBetScreenState extends State<NewBetScreen> {
  final DropdownController dropdownController = Get.find<DropdownController>();
  final BettingController bettingController = Get.find<BettingController>();
  final TextEditingController betNumberController = TextEditingController();
  final TextEditingController amountController = TextEditingController(text: '10');
  
  @override
  void initState() {
    super.initState();
    // Fetch dropdown data when screen is loaded
    _loadData();
  }
  
  Future<void> _loadData() async {
    // Reset selected values before fetching new data
    bettingController.selectedDrawId.value = null;
    
    // Fetch game types and available draws
    await Future.wait([
      dropdownController.fetchGameTypes(),
      bettingController.fetchAvailableDraws(),
    ]);
    
    // Set default draw ID if available and none is selected
    if (bettingController.selectedDrawId.value == null && 
        bettingController.availableDraws.isNotEmpty) {
      bettingController.selectedDrawId.value = bettingController.availableDraws.first.id;
    }
  }
  
  // Get the max length for bet number based on game type
  int _getMaxBetNumberLength() {
    if (bettingController.selectedGameTypeId.value == null) return 3; // Default
    
    final gameType = dropdownController.getGameTypeById(bettingController.selectedGameTypeId.value!);
    if (gameType == null) return 3;
    
    // First check if digitCount is available
    if (gameType.digitCount != null) {
      return gameType.digitCount!;
    }
    
    // Fallback logic based on game type code
    final code = gameType.code;
    if (code == null) return 3;
    
    // Check if code follows pattern like S2, S3, D4, etc.
    if (code.length >= 2 && (code.startsWith('S') || code.startsWith('D'))) {
      final digitPart = code.substring(1);
      final parsedDigits = int.tryParse(digitPart);
      if (parsedDigits != null) {
        return parsedDigits;
      }
    }
    
    // Default fallback
    switch (code) {
      case 'S2': return 2;
      case 'S3': return 3;
      case 'S4': return 4;
      case 'D4': return 4;
      default: return 3;
    }
  }
  
  // Validate bet number based on game type
  bool _isValidBetNumber(String number) {
    if (number.isEmpty) return false;
    
    final maxLength = _getMaxBetNumberLength();
    return number.length == maxLength && int.tryParse(number) != null;
  }
  
  // Place bet with confirmation
  void _placeBet() {
    if (!_isValidBetNumber(betNumberController.text)) {
      Modal.showErrorModal(
        title: 'Invalid Bet Number',
        message: 'Please enter a valid ${_getMaxBetNumberLength()}-digit bet number',
      );
      return;
    }
    
    if (bettingController.selectedGameTypeId.value == null) {
      Modal.showErrorModal(
        title: 'Game Type Required',
        message: 'Please select a game type',
      );
      return;
    }
    
    if (bettingController.selectedDrawId.value == null) {
      Modal.showErrorModal(
        title: 'Draw Required',
        message: 'Please select a draw schedule',
      );
      return;
    }
    
    final amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      Modal.showErrorModal(
        title: 'Invalid Amount',
        message: 'Please enter a valid bet amount',
      );
      return;
    }
    
    // Set values in betting controller
    bettingController.betNumber.value = betNumberController.text;
    bettingController.betAmount.value = amount;
    
    // Show confirmation modal
    Modal.showConfirmationModal(
      title: 'Confirm Bet',
      message: 'Are you sure you want to place a bet with the following details?\n\n'  
          'Bet Number: ${betNumberController.text}\n'
          'Amount: PHP ${amountController.text}\n'
          'Bet Type: ${dropdownController.getGameTypeById(bettingController.selectedGameTypeId.value!)?.name ?? ''}\n'
          'Draw: ${bettingController.availableDraws.firstWhereOrNull((d) => d.id == bettingController.selectedDrawId.value)?.drawTimeFormatted ?? ''} (${bettingController.availableDraws.firstWhereOrNull((d) => d.id == bettingController.selectedDrawId.value)?.drawDateFormatted ?? bettingController.availableDraws.firstWhereOrNull((d) => d.id == bettingController.selectedDrawId.value)?.drawDate ?? ''})',
      confirmText: 'Place Bet',
      onConfirm: () async {
        final betData = await bettingController.placeBet();
        if (betData != null) {
          // Print the bet ticket using the response data
          await _printBetTicket(betData);
          
          // Clear form fields
          betNumberController.clear();
          amountController.text = '10';
          
          // Reset dropdown values after a short delay to ensure UI updates properly
          Future.delayed(const Duration(milliseconds: 300), () {
            bettingController.selectedGameTypeId.value = null;
            bettingController.selectedDrawId.value = null;
            setState(() {}); // Ensure UI refreshes
          });
          
          // Refresh dashboard data to update today's sales
          try {
            final reportController = Get.find<ReportController>();
            await reportController.fetchTodaySales();
          } catch (e) {
            // Silently handle any errors - this is just a background refresh
            debugPrint('Error refreshing dashboard: $e');
          }
        }
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('NEW BET'),
        backgroundColor: AppColors.primaryRed,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,color: Colors.white,),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final isLoading = dropdownController.isLoadingGameTypes.value || 
                         bettingController.isLoadingAvailableDraws.value;
        
        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return RefreshIndicator(
          color: AppColors.primaryRed,
          onRefresh: () async {
            await _loadData();
            // Show a snackbar to indicate refresh completed
            Get.snackbar(
              'Refreshed',
              'Game types and draw schedules updated',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.white,
              colorText: AppColors.primaryRed,
              duration: const Duration(seconds: 2),
            );
          },
          child: SingleChildScrollView(
            // This ensures the refresh indicator can be triggered even when content doesn't fill the screen
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Game Type Selection
                const Text(
                  'Bet Type',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      hint: const Text('Select Bet Type'),
                      value: bettingController.selectedGameTypeId.value,
                      items: dropdownController.gameTypes.map((gameType) {
                        return DropdownMenuItem<int>(
                          value: gameType.id,
                          child: Text('${gameType.name} (${gameType.code})'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        bettingController.selectedGameTypeId.value = value;
                        // Clear bet number when game type changes
                        betNumberController.clear();
                      },
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Draw Selection
                const Text(
                  'Draw Schedule',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      hint: const Text('Select Draw Schedule'),
                      value: bettingController.availableDraws.any((draw) => draw.id == bettingController.selectedDrawId.value)
                          ? bettingController.selectedDrawId.value
                          : null,
                      items: bettingController.availableDraws.map((draw) {
                        return DropdownMenuItem<int>(
                          value: draw.id,
                          child: Text('${draw.drawTimeFormatted} (${draw.drawDateFormatted ?? draw.drawDate})'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        bettingController.selectedDrawId.value = value;
                      },
                    ),
                  ),
                ),
                
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
                  controller: betNumberController,
                  keyboardType: TextInputType.number,
                  maxLength: _getMaxBetNumberLength(),
                  style: const TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    hintText: 'Enter ${_getMaxBetNumberLength()}-digit number',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    counterText: '',
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Bet Amount Input
                const Text(
                  'Bet Amount',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Enter bet amount',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    prefixText: 'PHP ',
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Place Bet Button
                SizedBox(
                  width: double.infinity,
                  child: Obx(() => ElevatedButton(
                    onPressed: bettingController.isPlacingBet.value
                        ? null
                        : _placeBet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      disabledBackgroundColor: AppColors.primaryRed.withOpacity(0.6),
                    ),
                    child: bettingController.isPlacingBet.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'PLACE BET',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  )),
                ),
              ],
            ),
          ),
        ).animate()
            .fadeIn(duration: 300.ms)
            .slideY(begin: 0.1, end: 0, duration: 300.ms),
        );
      }),
    );
  }
  
  // Print the bet ticket
  Future<void> _printBetTicket([Map<String, dynamic>? betData]) async {
    try {
      // If we have bet data from the response, use it; otherwise use form values
      final String ticketId;
      final String betNumber;
      final dynamic amount;
      final String gameTypeName;
      final String drawTime;
      final String betDate;
      
      if (betData != null) {
        // Use data directly from the API response
        ticketId = betData['ticket_id']?.toString() ?? 'Unknown';
        betNumber = betData['bet_number']?.toString() ?? 'Unknown';
        amount = betData['amount'];
        
        // Get game type name from the response
        final gameTypeData = betData['game_type'];
        gameTypeName = gameTypeData != null ? gameTypeData['name']?.toString() ?? 'Unknown' : 'Unknown';
        
        // Format the bet date from the response
        betDate = betData['bet_date_formatted']?.toString() ?? 
                 (betData['bet_date']?.toString() ?? 'Unknown');
                 
        // Get draw time - we may need to use the form value if not in response
        drawTime = betData['draw_time']?.toString() ?? 
                  bettingController.availableDraws
                    .firstWhereOrNull((d) => d.id == bettingController.selectedDrawId.value)
                    ?.drawTimeFormatted ?? 'Unknown';
      } else {
        // Fallback to form values
        ticketId = bettingController.lastPlacedTicketId.value;
        betNumber = betNumberController.text;
        amount = double.tryParse(amountController.text) ?? 0.0;
        
        final gameType = dropdownController.getGameTypeById(bettingController.selectedGameTypeId.value!);
        gameTypeName = gameType?.name ?? 'Unknown';
        
        final draw = bettingController.availableDraws.firstWhereOrNull(
          (d) => d.id == bettingController.selectedDrawId.value
        );
        drawTime = draw?.drawTimeFormatted ?? 'Unknown';
        
        // Get current date
        final now = DateTime.now();
        final dateFormatter = DateFormat('yyyy-MM-dd');
        betDate = dateFormatter.format(now);
      }
      
      // Use the printer service to print the ticket
      final printerService = PrinterService();
      await printerService.printBetTicket(
        ticketId: ticketId,
        betNumber: betNumber,
        amount: amount,
        gameTypeName: gameTypeName,
        drawTime: drawTime,
        betDate: betDate,
        status: 'Placed',
        tellerName: 'Current Teller', // Replace with actual teller name if available
        tellerUsername: 'teller', // Replace with actual username if available
        locationName: 'Current Location', // Replace with actual location if available
        isReprint: false, // This is a new bet, not a reprint
      );
    } catch (e) {
      debugPrint('Error printing bet ticket: $e');
      // Show error message but don't block the bet process
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
  
  @override
  void dispose() {
    betNumberController.dispose();
    amountController.dispose();
    super.dispose();
  }
}
