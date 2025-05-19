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
  final List<TextEditingController> combinationControllers = [];
  final List<TextEditingController> combinationAmountControllers = [];
  
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
  
  // Add a new combination row
  void _addCombination() {
    final subSelection = bettingController.d4SubSelection.value;
    if (subSelection == null) return;
    
    // Determine the digit count based on the sub-selection
    final digitCount = subSelection == 'S2' ? 2 : (subSelection == 'S3' ? 3 : 0);
    if (digitCount == 0) return;
    
    // Create new controllers for this combination
    final comboController = TextEditingController();
    final amountController = TextEditingController(text: '10');
    
    // Add to our lists
    combinationControllers.add(comboController);
    combinationAmountControllers.add(amountController);
    
    // Add to the betting controller's combinations list
    bettingController.combinations.add({
      'combination': '',
      'amount': 10.0,
    });
    
    setState(() {});
  }
  
  // Remove a combination at the specified index
  void _removeCombination(int index) {
    if (index < 0 || index >= combinationControllers.length) return;
    
    // Dispose the controllers
    combinationControllers[index].dispose();
    combinationAmountControllers[index].dispose();
    
    // Remove from our lists
    combinationControllers.removeAt(index);
    combinationAmountControllers.removeAt(index);
    
    // Remove from the betting controller's combinations list
    if (index < bettingController.combinations.length) {
      bettingController.combinations.removeAt(index);
    }
    
    setState(() {});
  }
  
  // Update combination value at the specified index
  void _updateCombination(int index, String value) {
    if (index < 0 || index >= bettingController.combinations.length) return;
    
    final combo = Map<String, dynamic>.from(bettingController.combinations[index]);
    combo['combination'] = value;
    bettingController.combinations[index] = combo;
  }
  
  // Update combination amount at the specified index
  void _updateCombinationAmount(int index, String value) {
    if (index < 0 || index >= bettingController.combinations.length) return;
    
    final amount = double.tryParse(value) ?? 0.0;
    final combo = Map<String, dynamic>.from(bettingController.combinations[index]);
    combo['amount'] = amount;
    bettingController.combinations[index] = combo;
  }
  
  // Clear all combinations
  void _clearCombinations() {
    // Dispose all controllers
    for (final controller in combinationControllers) {
      controller.dispose();
    }
    for (final controller in combinationAmountControllers) {
      controller.dispose();
    }
    
    // Clear the lists
    combinationControllers.clear();
    combinationAmountControllers.clear();
    bettingController.combinations.clear();
    
    setState(() {});
  }
  
  // Validate all combinations
  bool _validateCombinations() {
    final subSelection = bettingController.d4SubSelection.value;
    if (subSelection == null) return false;
    
    // Determine the digit count based on the sub-selection
    final digitCount = subSelection == 'S2' ? 2 : (subSelection == 'S3' ? 3 : 0);
    if (digitCount == 0) return false;
    
    // Check if we have any combinations
    if (bettingController.combinations.isEmpty) {
      Modal.showErrorModal(
        title: 'No Combinations',
        message: 'Please add at least one combination',
      );
      return false;
    }
    
    // Validate each combination
    for (int i = 0; i < bettingController.combinations.length; i++) {
      final combo = bettingController.combinations[i];
      final combination = combo['combination'] as String?;
      final amount = combo['amount'] as double?;
      
      // Check combination format
      if (combination == null || combination.isEmpty || combination.length != digitCount || int.tryParse(combination) == null) {
        Modal.showErrorModal(
          title: 'Invalid Combination',
          message: 'Please enter a valid $digitCount-digit number for all combinations',
        );
        return false;
      }
      
      // Check amount
      if (amount == null || amount <= 0) {
        Modal.showErrorModal(
          title: 'Invalid Amount',
          message: 'Please enter a valid amount for all combinations',
        );
        return false;
      }
    }
    
    return true;
  }
  
  // Place bet with confirmation
  void _placeBet() {
    // Check if game type is selected
    if (bettingController.selectedGameTypeId.value == null) {
      Modal.showErrorModal(
        title: 'Bet Type Required',
        message: 'Please select a bet type',
      );
      return;
    }
    
    // Check if draw is selected
    if (bettingController.selectedDrawId.value == null) {
      Modal.showErrorModal(
        title: 'Draw Required',
        message: 'Please select a draw schedule',
      );
      return;
    }
    
    // Check if this is a combination bet
    final isCombination = bettingController.d4SubSelection.value != null && 
                          bettingController.d4SubSelection.value!.isNotEmpty;
    bettingController.isCombination.value = isCombination;
    
    // Validate based on bet type
    if (isCombination) {
      // For combination bets, validate combinations
      if (!_validateCombinations()) {
        return;
      }
    } else {
      // For regular bets, validate bet number and amount
      if (!_isValidBetNumber(betNumberController.text)) {
        Modal.showErrorModal(
          title: 'Invalid Bet Number',
          message: 'Please enter a valid ${_getMaxBetNumberLength()}-digit bet number',
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
    }
    
    // Prepare confirmation message
    String message = 'Are you sure you want to place a bet with the following details?\n\n';
    
    final gameType = dropdownController.getGameTypeById(bettingController.selectedGameTypeId.value!)?.name ?? '';
    final draw = bettingController.availableDraws.firstWhereOrNull((d) => d.id == bettingController.selectedDrawId.value);
    final drawTime = draw?.drawTimeFormatted ?? '';
    final drawDate = draw?.drawDateFormatted ?? draw?.drawDate ?? '';
    
    if (isCombination) {
      message += 'Bet Type: $gameType\n';
      message += 'Draw: $drawTime ($drawDate)\n';
      message += 'D4 Number: ${betNumberController.text}\n';
      message += 'D4 Sub-selection: ${bettingController.d4SubSelection.value}\n\n';
      message += 'Combinations:\n';
      
      for (final combo in bettingController.combinations) {
        message += '${combo['combination']} - PHP ${combo['amount']}\n';
      }
    } else {
      message += 'Bet Number: ${betNumberController.text}\n';
      message += 'Amount: PHP ${amountController.text}\n';
      message += 'Bet Type: $gameType\n';
      message += 'Draw: $drawTime ($drawDate)';
    }
    
    // Show confirmation modal
    Modal.showConfirmationModal(
      title: 'Confirm Bet',
      message: message,
      confirmText: 'Place Bet',
      onConfirm: () async {
        final betData = await bettingController.placeBet();
        if (betData != null) {
          // Printing is now handled in BettingController
          
          // Clear form fields
          betNumberController.clear();
          amountController.text = '10';
          _clearCombinations();
          
          // Reset dropdown values after a short delay to ensure UI updates properly
          Future.delayed(const Duration(milliseconds: 300), () {
            bettingController.selectedGameTypeId.value = null;
            bettingController.selectedDrawId.value = null;
            bettingController.d4SubSelection.value = null;
            bettingController.isCombination.value = false;
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
                              'D4 Sub-selection',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(' (optional)', style: TextStyle(color: Colors.grey, fontSize: 14)),
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
                                  child: Text('No Sub-selection'),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'S2',
                                  child: Text('S2 (2-digit)'),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'S3',
                                  child: Text('S3 (3-digit)'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value == '') {
                                  bettingController.d4SubSelection.value = null;
                                  _clearCombinations();
                                } else {
                                  // Clear existing combinations when changing sub-selection
                                  _clearCombinations();
                                  bettingController.d4SubSelection.value = value;
                                  
                                  // Add one empty combination row by default
                                  Future.delayed(const Duration(milliseconds: 100), () {
                                    _addCombination();
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Combinations Section (only shown when S2 or S3 is selected)
                        if (bettingController.d4SubSelection.value != null && 
                            bettingController.d4SubSelection.value!.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${bettingController.d4SubSelection.value} Combinations',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: _addCombination,
                                    icon: const Icon(Icons.add, size: 16),
                                    label: const Text('Add'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryRed,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              
                              // Combination list
                              for (int i = 0; i < combinationControllers.length; i++)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      // Combination input
                                      Expanded(
                                        flex: 2,
                                        child: TextField(
                                          controller: combinationControllers[i],
                                          keyboardType: TextInputType.number,
                                          maxLength: bettingController.d4SubSelection.value == 'S2' ? 2 : 3,
                                          decoration: InputDecoration(
                                            hintText: 'Enter ${bettingController.d4SubSelection.value}',
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: BorderSide.none,
                                            ),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                            counterText: '',
                                          ),
                                          onChanged: (value) => _updateCombination(i, value),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      
                                      // Amount input
                                      Expanded(
                                        flex: 2,
                                        child: TextField(
                                          controller: combinationAmountControllers[i],
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
                                          ],
                                          decoration: InputDecoration(
                                            hintText: 'Amount',
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: BorderSide.none,
                                            ),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                            prefixText: 'PHP ',
                                          ),
                                          onChanged: (value) => _updateCombinationAmount(i, value),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      
                                      // Remove button
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle, color: AppColors.primaryRed),
                                        onPressed: () => _removeCombination(i),
                                      ),
                                    ],
                                  ),
                                ),
                              
                              if (combinationControllers.isEmpty)
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Click "Add" to add combinations',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ),
                              
                              const SizedBox(height: 24),
                            ],
                          ),
                      ],
                    );
                  } else {
                    // Reset D4 sub-selection when not applicable
                    if (bettingController.d4SubSelection.value != null) {
                      bettingController.d4SubSelection.value = null;
                      _clearCombinations();
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
    
    // Dispose all combination controllers
    for (final controller in combinationControllers) {
      controller.dispose();
    }
    for (final controller in combinationAmountControllers) {
      controller.dispose();
    }
    
    super.dispose();
  }
}
