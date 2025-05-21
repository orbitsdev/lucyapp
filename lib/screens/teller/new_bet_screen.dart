import 'package:bettingapp/controllers/dropdown_controller.dart';
import 'package:bettingapp/controllers/betting_controller.dart';
import 'package:bettingapp/controllers/report_controller.dart';
import 'package:bettingapp/widgets/common/modal.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bettingapp/utils/app_colors.dart';
import 'package:flutter/services.dart';

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
    // Fetch game types and available draws
    await Future.wait([
      dropdownController.fetchGameTypes(),
      bettingController.fetchAvailableDraws(),
    ]);

    // Ensure selectedDrawId is valid
    if (!bettingController.availableDraws.any((draw) => draw.id == bettingController.selectedDrawId.value)) {
      bettingController.selectedDrawId.value = bettingController.availableDraws.isNotEmpty
          ? bettingController.availableDraws.first.id
          : null;
    }

    // Ensure selectedGameTypeId is valid
    if (!dropdownController.gameTypes.any((gameType) => gameType.id == bettingController.selectedGameTypeId.value)) {
      bettingController.selectedGameTypeId.value = null;
    }
  }
  
  // Get the max length for bet number based on game type and 4D sub-selection
  int _getMaxBetNumberLength() {
    if (bettingController.selectedGameTypeId.value == null) return 3; // Default

    final gameType = dropdownController.getGameTypeById(bettingController.selectedGameTypeId.value!);
    if (gameType == null) return 3;

    final code = gameType.code?.toUpperCase();
    final isD4 = code == 'D4' || code == '4D' || (gameType.isD4 ?? false);
    final d4Sub = bettingController.d4SubSelection.value;
    if (isD4) {
      if (d4Sub == 'S2') return 2;
      if (d4Sub == 'S3') return 3;
      // pure 4D
      return 4;
    }

    // For other types, fallback to digitCount or pattern
    if (gameType.digitCount != null) {
      return gameType.digitCount!;
    }
    if (code == null) return 3;
    if (code.length >= 2 && (code.startsWith('S') || code.startsWith('D'))) {
      final digitPart = code.substring(1);
      final parsedDigits = int.tryParse(digitPart);
      if (parsedDigits != null) {
        return parsedDigits;
      }
    }
    switch (code) {
      case 'S2': return 2;
      case 'S3': return 3;
      case 'S4': return 4;
      case 'D4': return 4;
      default: return 3;
    }
  }
  
  // Validate bet number based on game type and 4D sub-selection
  bool _isValidBetNumber(String number) {
    if (number.isEmpty) return false;

    final gameType = bettingController.selectedGameTypeId.value != null
        ? dropdownController.getGameTypeById(bettingController.selectedGameTypeId.value!)
        : null;
    final code = gameType?.code?.toUpperCase();
    final isD4 = code == 'D4' || code == '4D' || (gameType?.isD4 ?? false);
    final d4Sub = bettingController.d4SubSelection.value;

    if (isD4) {
      if (d4Sub == 'S2') {
        return number.length == 2 && int.tryParse(number) != null;
      } else if (d4Sub == 'S3') {
        return number.length == 3 && int.tryParse(number) != null;
      } else {
        // pure 4D
        return number.length == 4 && int.tryParse(number) != null;
      }
    }
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
        title: 'Bet Type Required',
        message: 'Please select a bet type',
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
          'Draw: ${bettingController.availableDraws.firstWhereOrNull((d) => d.id == bettingController.selectedDrawId.value)?.drawTimeFormatted ?? ''} (${bettingController.availableDraws.firstWhereOrNull((d) => d.id == bettingController.selectedDrawId.value)?.drawDateFormatted ?? bettingController.availableDraws.firstWhereOrNull((d) => d.id == bettingController.selectedDrawId.value)?.drawDate ?? ''})'
          '${bettingController.d4SubSelection.value != null && bettingController.d4SubSelection.value != '' ? '\nD4 Sub-selection: ${bettingController.d4SubSelection.value}' : ''}',
      confirmText: 'Place Bet',
      onConfirm: () async {
        final betData = await bettingController.placeBet();
        if (betData != null) {
          // Printing is now handled in BettingController
          
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
              'Bet types and draw schedules updated',
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
                // Draw Selection
                Row(
                  children: const [
                    Text(
                      'Draw Schedule',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(' *', style: TextStyle(color: AppColors.primaryRed, fontSize: 18)),
                  ],
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

  // After changing draw, check if D4/4D is still valid
  final selectedDraw = bettingController.availableDraws.firstWhereOrNull(
    (draw) => draw.id == value
  );
  final is9PMDraw = selectedDraw?.drawTimeSimple == '9PM';
  final selectedGameType = bettingController.selectedGameTypeId.value != null
      ? dropdownController.getGameTypeById(bettingController.selectedGameTypeId.value!)
      : null;
  final code = selectedGameType?.code?.toUpperCase() ?? '';
  if ((code == 'D4' || code == '4D') && !is9PMDraw) {
    // Reset game type if D4/4D is selected and draw is not 9PM
    bettingController.selectedGameTypeId.value = null;
  }
  // Reset D4 sub-selection if not 9PM or not D4
  if (!(selectedGameType?.isD4 ?? false) || !is9PMDraw) {
    bettingController.d4SubSelection.value = null;
  }
},
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),

                // Game Type Selection
                Row(
                  children: const [
                    Text(
                      'Bet Type',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(' *', style: TextStyle(color: AppColors.primaryRed, fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
  child: Builder(
    builder: (context) {
      final selectedDraw = bettingController.availableDraws.firstWhereOrNull(
        (draw) => draw.id == bettingController.selectedDrawId.value
      );
      final is9PMDraw = selectedDraw?.drawTimeSimple == '9PM';
      final filteredGameTypes = dropdownController.gameTypes.where((gameType) {
        final code = gameType.code?.toUpperCase() ?? '';
        if (code == 'D4' || code == '4D') {
          return is9PMDraw;
        }
        return true;
      }).toList();
      return DropdownButton<int>(
        isExpanded: true,
        hint: const Text('Select Bet Type'),
        value: bettingController.selectedGameTypeId.value,
        items: filteredGameTypes.map((gameType) {
          return DropdownMenuItem<int>(
            value: gameType.id,
            child: Text('${gameType.name} (${gameType.code})'),
          );
        }).toList(),
        onChanged: (value) {
          bettingController.selectedGameTypeId.value = value;
          // Clear bet number when game type changes
          betNumberController.clear();
          // Reset D4 sub-selection when game type changes
          bettingController.d4SubSelection.value = null;
        },
      );
    }
  ),
),
                ),
                
                const SizedBox(height: 24),
                
                // D4 Sub-selection (only shown for D4 game type and 9PM draw)
                Obx(() {
                  // Check if we need to show the D4 sub-selection dropdown
                  final selectedGameType = bettingController.selectedGameTypeId.value != null
                      ? dropdownController.getGameTypeById(bettingController.selectedGameTypeId.value!)
                      : null;
                  final selectedDraw = bettingController.availableDraws.firstWhereOrNull(
                    (draw) => draw.id == bettingController.selectedDrawId.value
                  );
                  
                  final bool isD4 = selectedGameType?.isD4 ?? false;
                  final bool is9PMDraw = selectedDraw?.drawTimeSimple == '9PM';
                  
                  if (isD4 && is9PMDraw) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Text(
                              '4D Bet Type',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              hint: const Text('Select Sub-type'),
                              value: bettingController.d4SubSelection.value ?? '',
                              items: const [
                                DropdownMenuItem<String>(
                                  value: '',
                                  child: Text('4D'),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'S2',
                                  child: Text('4D-S2 (2-digit)'),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'S3',
                                  child: Text('4D-S3 (3-digit)'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value == '') {
                                  bettingController.d4SubSelection.value = null;
                                } else {
                                  bettingController.d4SubSelection.value = value;
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    );
                  } else {
                    // Reset D4 sub-selection when not applicable
                    if (bettingController.d4SubSelection.value != null) {
                      bettingController.d4SubSelection.value = null;
                    }
                    return const SizedBox.shrink();
                  }
                }),
                
                // Bet Number Input
                Row(
                  children: const [
                    Text(
                      'Bet Number',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(' *', style: TextStyle(color: AppColors.primaryRed, fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: betNumberController,
                  keyboardType: TextInputType.number,
                  maxLength: _getMaxBetNumberLength(),
                  style: const TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    hintText: () {
                      final gameType = bettingController.selectedGameTypeId.value != null
                        ? dropdownController.getGameTypeById(bettingController.selectedGameTypeId.value!)
                        : null;
                      final code = gameType?.code?.toUpperCase();
                      final isD4 = code == 'D4' || code == '4D' || (gameType?.isD4 ?? false);
                      final d4Sub = bettingController.d4SubSelection.value;
                      if (isD4) {
                        if (d4Sub == 'S2') return 'Enter 2-digit number';
                        if (d4Sub == 'S3') return 'Enter 3-digit number';
                        return 'Enter 4-digit number';
                      }
                      return 'Enter ${_getMaxBetNumberLength()}-digit number';
                    }(),
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
                Row(
                  children: const [
                    Text(
                      'Bet Amount',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(' *', style: TextStyle(color: AppColors.primaryRed, fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    // Only allow digits and a single decimal point, up to 2 decimal places
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
                  ],
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
  
  // Printing is now handled directly in BettingController
  
  @override
  void dispose() {
    betNumberController.dispose();
    amountController.dispose();
    super.dispose();
  }
}
