import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/betting_controller.dart';
import '../../controllers/dropdown_controller.dart';
import '../../utils/app_colors.dart';
import '../../models/bet.dart';
import '../../models/draw.dart';
import '../../models/game_type.dart';
import '../../widgets/common/modal.dart';
import '../../widgets/common/local_lottie_image.dart';
import '../../widgets/common/qr_scanner.dart';

/// Defines the fixed column widths for the winning bet list table
class TableColumnWidths {
  static const double typeWidth = 120.0;
  static const double betNumberWidth = 120.0;
  static const double amountWidth = 100.0;
  static const double winningAmountWidth = 120.0;
  static const double ticketIdWidth = 130.0;
  static const double dateWidth = 150.0;
  static const double statusWidth = 100.0;
    
  // Total width of all columns
  static const double totalWidth = typeWidth + betNumberWidth + amountWidth + winningAmountWidth + ticketIdWidth + dateWidth + statusWidth;
}

class HitsAndClaimScreen extends StatefulWidget {
  const HitsAndClaimScreen({Key? key}) : super(key: key);

  @override
  State<HitsAndClaimScreen> createState() => _HitsAndClaimScreenState();
}

class _HitsAndClaimScreenState extends State<HitsAndClaimScreen> {
  final BettingController bettingController = Get.find<BettingController>();
  final DropdownController dropdownController = Get.find<DropdownController>();
  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();
  final TextEditingController ticketIdController = TextEditingController();
  final Rx<String?> selectedDate = Rx<String?>(null);
  final RxInt selectedDrawId = RxInt(-1);
  final RxInt selectedGameTypeId = RxInt(-1);
  final RxString selectedD4SubSelection = ''.obs; // D4 sub-selection filter
  final RxBool showOnlyUnclaimed = RxBool(false);
  final ScrollController scrollController = ScrollController();
  final ScrollController horizontalScrollController = ScrollController();
  
  // Track the currently selected row for highlighting
  final RxInt selectedRowIndex = RxInt(-1);
  
  // Debounce worker for search
  Worker? _searchDebounce;

  @override
  void initState() {
    super.initState();
    // Fetch available draws and game types for filtering
    bettingController.fetchAvailableDraws();
    dropdownController.fetchGameTypes();
    _fetchWinningBets();
    
    // Add scroll listener for pagination
    scrollController.addListener(_scrollListener);
  }
  
  @override
  void dispose() {
    ticketIdController.dispose();
    searchController.dispose();
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    horizontalScrollController.dispose();
    _searchDebounce?.dispose();
    super.dispose();
  }
  
  // Scroll listener for pagination
  void _scrollListener() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      bettingController.loadMoreWinningBets();
    }
  }

  Future<void> _fetchWinningBets() async {
    await bettingController.fetchWinningBets(
      search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
      date: selectedDate.value,
      drawId: selectedDrawId.value != -1 ? selectedDrawId.value : null,
      gameTypeId: selectedGameTypeId.value != -1 ? selectedGameTypeId.value : null,
      isClaimed: showOnlyUnclaimed.value ? false : null,
      d4SubSelection: selectedD4SubSelection.value.isNotEmpty ? selectedD4SubSelection.value : null,
    );
  }

  void _showFilterDialog() {
    // Save current filter values to restore if cancelled
    final currentDate = selectedDate.value;
    final currentDrawId = selectedDrawId.value;
    final currentGameTypeId = selectedGameTypeId.value;
    final currentShowOnlyUnclaimed = showOnlyUnclaimed.value;
    
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Filter Winning Bets',
          style: TextStyle(
            color: AppColors.primaryRed,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bet Type filter
              Text(
                'Bet Type',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 8),
              Obx(() => DropdownButtonFormField<int?>(
                value: selectedGameTypeId.value == -1 ? null : selectedGameTypeId.value,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('All Bet Types'),
                  ),
                  ...dropdownController.gameTypes.map((gameType) => 
                    DropdownMenuItem<int?>(
                      value: gameType.id,
                      child: Text(gameType.name ?? 'Unknown'),
                    ),
                  ),
                ],
                onChanged: (value) {
                  selectedGameTypeId.value = value ?? -1;
                },
              )),
              SizedBox(height: 16),
              // D4 Sub-selection filter (only for D4)
              Obx(() {
                final d4GameType = dropdownController.gameTypes.firstWhereOrNull((g) => g.id == selectedGameTypeId.value);
                final code = d4GameType?.code?.toUpperCase() ?? '';
                if (code == 'D4' || code == '4D') {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'D4 Sub-selection',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedD4SubSelection.value.isEmpty ? null : selectedD4SubSelection.value,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        items: const [
                          DropdownMenuItem<String>(value: null, child: Text('All Sub-selections')),
                          DropdownMenuItem<String>(value: 'S2', child: Text('S2 (2-digit)')),
                          DropdownMenuItem<String>(value: 'S3', child: Text('S3 (3-digit)')),
                        ],
                        onChanged: (value) {
                          selectedD4SubSelection.value = value ?? '';
                        },
                      ),
                      SizedBox(height: 16),
                    ],
                  );
                }
                // Clear the filter if not D4
                if (selectedD4SubSelection.value.isNotEmpty) selectedD4SubSelection.value = '';
                return SizedBox.shrink();
              }),
              // Date filter
              Text(
                'Date',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 8),
              Obx(() => OutlinedButton.icon(
                onPressed: () async {
                  final selectedDatePicker = await showDatePicker(
                    context: context,
                    initialDate: selectedDate.value != null
                        ? DateTime.parse(selectedDate.value!)
                        : DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: AppColors.primaryRed,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  
                  if (selectedDatePicker != null) {
                    selectedDate.value = 
                        DateFormat('yyyy-MM-dd').format(selectedDatePicker);
                  }
                },
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  selectedDate.value != null
                      ? DateFormat('MMM dd, yyyy').format(
                          DateTime.parse(selectedDate.value!))
                      : 'Select Date',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryRed,
                ),
              )),
              SizedBox(height: 16),
              // Draw filter
              Text(
                'Draw Time',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 8),
              Obx(() => DropdownButtonFormField<int?>(
                value: selectedDrawId.value == -1 ? null : selectedDrawId.value,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('All Draw Times'),
                  ),
                  ...bettingController.availableDraws.map((draw) => 
                    DropdownMenuItem<int?>(
                      value: draw.id,
                      child: Text(draw.drawTimeFormatted ?? 'Unknown'),
                    ),
                  ),
                ],
                onChanged: (value) {
                  selectedDrawId.value = value ?? -1;
                },
              )),
              SizedBox(height: 16),
              // Claimed status filter
              Obx(() => CheckboxListTile(
                title: Text('Show Only Unclaimed'),
                value: showOnlyUnclaimed.value,
                onChanged: (val) => showOnlyUnclaimed.value = val ?? true,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primaryRed,
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Restore previous values
              selectedDate.value = currentDate;
              selectedDrawId.value = currentDrawId;
              selectedGameTypeId.value = currentGameTypeId;
              showOnlyUnclaimed.value = currentShowOnlyUnclaimed;
              Get.back();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _fetchWinningBets();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
  
  // Show bet details dialog
  void _showBetDetails(Bet bet) {
    Modal.showCustomModal(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.emoji_events,
                color: AppColors.primaryRed,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Winning Bet Details',
                style: TextStyle(
                  color: AppColors.primaryRed,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
            const SizedBox(height: 16),
          // Bet Type + Draw Time + D4 Sub-selection (if any)
          Text(
  bet.betTypeDrawLabel ?? '',
  style: const TextStyle(
    color: Colors.grey,
    fontWeight: FontWeight.w500,
    fontSize: 16,
  ),
),
          const SizedBox(height: 16),
          _buildDetailRow('Ticket ID', bet.ticketId ?? 'Unknown'),
          _buildDetailRow('Bet Number', bet.betNumber ?? 'Unknown'),
          _buildDetailRow('Date', bet.betDateFormatted ?? 'Unknown'),
          _buildDetailRow('Draw Time', bet.draw?.drawTimeFormatted ?? 'Unknown'),
          _buildDetailRow('Amount', bet.formattedAmount),
          _buildDetailRow('Status', bet.isClaimed == true ? 'Claimed' : 'Unclaimed', 
            textColor: bet.isClaimed == true ? AppColors.primaryRed : AppColors.primaryRed),
          if (bet.isClaimed == true && bet.claimedAtFormatted != null)
            _buildDetailRow('Claimed At', bet.claimedAtFormatted!),
          const SizedBox(height: 16),
          Row(
            children: [
              if (bet.isClaimed != true)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      ticketIdController.text = bet.ticketId ?? '';
                      _showClaimConfirmation();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('CLAIM BET'),
                  ),
                )
              else
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: AppColors.primaryRed,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('CLOSE'),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
  
  // Show claim confirmation dialog
  void _showClaimConfirmation() {
    if (ticketIdController.text.isEmpty) {
      Modal.showErrorModal(
        title: 'Validation Error',
        message: 'Please enter a ticket number',
      );
      return;
    }
    
    // Show confirmation dialog
    Modal.showConfirmationModal(
      title: 'Claim Bet Confirmation',
      message: 'Are you sure you want to claim this bet?\n\n' 
              'Ticket Number: ${ticketIdController.text}\n\n'
              'This action will mark the bet as claimed.', 
      confirmText: 'Yes, Claim Bet',
      cancelText: 'No, Close',
      isDangerousAction: false,
      animation: 'assets/animations/questionmark.json',
      onConfirm: () async {
        // Show loading indicator
        Modal.showProgressModal(
          title: 'Claiming Bet',
          message: 'Please wait while we process your request...',
        );
        
        try {
          // Proceed with claiming
          final result = await bettingController.claimBetByTicketId(ticketIdController.text);
          
          if (result) {
            Modal.closeDialog();
            // Clear the input
            ticketIdController.clear();
            
            // Refresh the list
            _fetchWinningBets();
            
            // Show success message
            Modal.showSuccessModal(
              title: 'Bet Claimed',
              message: 'The bet has been claimed successfully.',
              showButton: true,
              buttonText: 'OK',
            );
          }
        } catch (e) {
          // Show error message
          Modal.showErrorModal(
            title: 'Claim Failed',
            message: 'Failed to claim the bet. Please try again.',
          );
        }
      },
    );
  }
  
  Widget _buildDetailRow(String label, String value, {Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Show QR scanner for claiming bets
  Future<void> _showQRScanner() async {
    await Get.to(
      () => QrScannerPage(
        onScanned: (ticket) {
          ticketIdController.text = ticket;
          // The QR scanner will automatically close due to Get.back() in the QrScannerPage
          // We just need to show the claim confirmation after returning
          Future.delayed(const Duration(milliseconds: 300), () {
            _showClaimConfirmation();
          });
        },
        title: 'Scan Winning Ticket',
      ),
    );
  }
  
  // Show manual ticket ID input dialog
  void _showManualInputDialog() {
    ticketIdController.clear();
    Get.dialog(
      AlertDialog(
        title: Text(
          'Enter Ticket ID',
          style: TextStyle(
            color: AppColors.primaryRed,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ticketIdController,
              decoration: InputDecoration(
                labelText: 'Ticket ID',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _showClaimConfirmation();
            },
            child: const Text('Proceed'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryRed,
            ),
          ),
        ],
      ),
    );
  }
  
  // Build active filters display
  Widget _buildActiveFilters() {
    return Obx(() {
      final List<Widget> filters = [];
      
      // Add date filter if selected
      if (selectedDate.value != null) {
        filters.add(_buildFilterChip(
          'Date: ${DateFormat('MMM dd, yyyy').format(DateTime.parse(selectedDate.value!))}',
          onTap: () {
            selectedDate.value = null;
            _fetchWinningBets();
          },
        ));
      }
      
      // Add D4 sub-selection filter if selected
      if (selectedD4SubSelection.value.isNotEmpty) {
        filters.add(_buildFilterChip(
          'D4: ${selectedD4SubSelection.value}',
          onTap: () {
            selectedD4SubSelection.value = '';
            _fetchWinningBets();
          },
        ));
      }
      // Add draw filter if selected
      if (selectedDrawId.value != -1) {
        final drawIndex = bettingController.availableDraws.indexWhere(
          (draw) => draw.id == selectedDrawId.value,
        );
        if (drawIndex != -1) {
          final draw = bettingController.availableDraws[drawIndex];
          filters.add(_buildFilterChip(
            'Draw: ${draw.drawTimeFormatted}',
            onTap: () {
              selectedDrawId.value = -1;
              _fetchWinningBets();
            },
          ));
        }
      }
      
      // Add game type filter if selected
      if (selectedGameTypeId.value != -1) {
        final gameTypeIndex = dropdownController.gameTypes.indexWhere(
          (gameType) => gameType.id == selectedGameTypeId.value,
        );
        if (gameTypeIndex != -1) {
          final gameType = dropdownController.gameTypes[gameTypeIndex];
          filters.add(_buildFilterChip(
            'Type: ${gameType.name}',
            onTap: () {
              selectedGameTypeId.value = -1;
              _fetchWinningBets();
            },
          ));
        }
      }
      
      // Add search filter if present
      if (searchQuery.value.isNotEmpty) {
        filters.add(_buildFilterChip(
          'Search: ${searchQuery.value}',
          onTap: () {
            searchQuery.value = '';
            searchController.clear();
            _fetchWinningBets();
          },
        ));
      }
      
      // Add claimed status filter
      if (showOnlyUnclaimed.value) {
        filters.add(_buildFilterChip(
          'Status: Unclaimed Only',
          onTap: () {
            showOnlyUnclaimed.value = false;
            _fetchWinningBets();
          },
        ));
      }
      
      if (filters.isEmpty) {
        return const SizedBox.shrink();
      }
      
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Text(
              'Active Filters:',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
            ...filters,
            _buildFilterChip(
              'Clear All',
              backgroundColor: AppColors.primaryRed.withOpacity(0.1),
              textColor: AppColors.primaryRed,
              onTap: () {
                selectedDate.value = null;
                selectedDrawId.value = -1;
                selectedGameTypeId.value = -1;
                selectedD4SubSelection.value = '';
                searchQuery.value = '';
                searchController.clear();
                showOnlyUnclaimed.value = true;
                _fetchWinningBets();
              },
            ),
          ],
        ),
      );
    });
  }
  
  // Build filter chip widget
  Widget _buildFilterChip(String label, {Function()? onTap, Color? backgroundColor, Color? textColor}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: textColor ?? Colors.grey.shade800,
                fontSize: 12,
              ),
            ),
            if (onTap != null && label != 'Clear All') ...[  
              const SizedBox(width: 4),
              Icon(
                Icons.close,
                size: 14,
                color: textColor ?? Colors.grey.shade800,
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Hits and Claim'),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchWinningBets,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _showQRScanner,
            tooltip: 'Scan QR Code',
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showManualInputDialog,
            tooltip: 'Manual Input',
          ),
        ],
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
        children: [
          
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ticket Number',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: ticketIdController,
                      decoration: InputDecoration(
                        hintText: 'Enter ticket number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.qr_code_scanner),
                          tooltip: 'Scan QR',
                          onPressed: _showQRScanner,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: Obx(() => ElevatedButton.icon(
                        onPressed: bettingController.isClaimingBet?.value == true
                            ? null
                            : () => _showClaimConfirmation(),
                        icon: bettingController.isClaimingBet?.value == true
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.emoji_events_outlined, size: 20),
                        label: Text(
                          bettingController.isClaimingBet?.value == true ? 'PROCESSING...' : 'CLAIM BET',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          disabledBackgroundColor: AppColors.primaryRed.withOpacity(0.5),
                          elevation: 1,
                        ),
                      )),
                    ),
                  ],
                ),
              ),
              // --- SEARCH BAR ---
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by ticket ID or bet number',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        searchQuery.value = '';
                        _fetchWinningBets();
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  onSubmitted: (value) {
                    searchQuery.value = value;
                    _fetchWinningBets();
                  },
                  textInputAction: TextInputAction.search,
                ),
              ),
          
              Obx(() {
                final hasFilters = selectedDate.value != null ||
                    selectedDrawId.value != -1 ||
                    selectedGameTypeId.value != -1 ||
                    searchQuery.value.isNotEmpty ||
                    showOnlyUnclaimed.value;
                    
                if (!hasFilters) return const SizedBox.shrink();
                
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Active Filters',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              selectedDate.value = null;
                              selectedDrawId.value = -1;
                              selectedGameTypeId.value = -1;
                              searchQuery.value = '';
                              showOnlyUnclaimed.value = true;
                              _fetchWinningBets();
                            },
                            child: const Text('Clear All'),
                          ),
                        ],
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (selectedDate.value != null)
                            Chip(
                              label: Text(
                                'Date: ${DateFormat('MMM dd, yyyy').format(
                                  DateTime.parse(selectedDate.value!)
                                )}',
                              ),
                              deleteIcon: const Icon(Icons.close, size: 18),
                              onDeleted: () {
                                selectedDate.value = null;
                                _fetchWinningBets();
                              },
                            ),
                          if (selectedDrawId.value != -1)
                            Chip(
                              label: Text(
                                'Draw: ${bettingController.availableDraws
                                  .firstWhere(
                                    (draw) => draw.id == selectedDrawId.value,
                                    orElse: () => Draw(id: 0, drawTimeFormatted: 'Unknown')
                                  ).drawTimeFormatted ?? 'Unknown'}'
                              ),
                              deleteIcon: const Icon(Icons.close, size: 18),
                              onDeleted: () {
                                selectedDrawId.value = -1;
                                _fetchWinningBets();
                              },
                            ),
                          if (selectedGameTypeId.value != -1)
                            Chip(
                              label: Text(
                                'Bet Type: ${dropdownController.gameTypes
                                  .firstWhereOrNull((type) => type.id == selectedGameTypeId.value)?.name ?? 'Unknown'}'
                              ),
                              deleteIcon: const Icon(Icons.close, size: 18),
                              onDeleted: () {
                                selectedGameTypeId.value = -1;
                                _fetchWinningBets();
                              },
                            ),
                          if (searchQuery.value.isNotEmpty)
                            Chip(
                              label: Text('Search: ${searchQuery.value}'),
                              deleteIcon: const Icon(Icons.close, size: 18),
                              onDeleted: () {
                                searchQuery.value = '';
                                searchController.clear();
                                _fetchWinningBets();
                              },
                            ),
                          if (showOnlyUnclaimed.value)
                            Chip(
                              label: const Text('Status: Unclaimed Only'),
                              deleteIcon: const Icon(Icons.close, size: 18),
                              onDeleted: () {
                                showOnlyUnclaimed.value = false;
                                _fetchWinningBets();
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
              
              // --- WINNING BETS COUNT ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    const Text(
                      'Winning Bets',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Obx(() => Text(
                        '${bettingController.winningBets.length}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      )),
                    ),
                  ],
                ),
              ),
          
              // --- WINNING BETS LIST ---
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primaryRed,
                  onRefresh: () async => _fetchWinningBets(),
                  child: Obx(() {
                    if (bettingController.isLoadingWinningBets.value && 
                        bettingController.winningBets.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  
                    
                    if (bettingController.winningBets.isEmpty) {
                      return Center(
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const LocalLottieImage(
                                  path: 'assets/animations/empty_state.json',
                                  width: 150,
                                  height: 150,
                                  repeat: true,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No winning bets found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Winning bets will appear here',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                  return  Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hint text for scrollable table
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'Scrollable ->',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                      ),
                    ),
                    // Use a single horizontal scroll view for the entire table
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const ClampingScrollPhysics(),
                        controller: horizontalScrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Table header
                            Container(
                              width: TableColumnWidths.totalWidth,
                              decoration: BoxDecoration(
                                color: AppColors.primaryRed,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(8),
                                ),
                              ),
                              child: Row(
                                children: const [
                                  SizedBox(width: TableColumnWidths.typeWidth, child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                    child: Text('Type', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                  )),
                                  SizedBox(width: TableColumnWidths.betNumberWidth, child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                    child: Text('Bet Number', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                  )),
                                  SizedBox(width: TableColumnWidths.amountWidth, child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                    child: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                  )),
                                  SizedBox(width: TableColumnWidths.winningAmountWidth, child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                    child: Text('Winning', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                  )),
                                  SizedBox(width: TableColumnWidths.ticketIdWidth, child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                    child: Text('Ticket ID', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                  )),
                                  SizedBox(width: TableColumnWidths.dateWidth, child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                    child: Text('Date', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                  )),
                                  SizedBox(width: TableColumnWidths.statusWidth, child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                    child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                  )),
                                ],
                              ),
                            ),
                            
                            // Table body
                            Expanded(
                              child: Container(
                                width: TableColumnWidths.totalWidth,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(8),
                                    bottomRight: Radius.circular(8),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ListView.builder(
                                  controller: scrollController,
                                  padding: EdgeInsets.zero,
                                  itemCount: bettingController.winningBets.length + 
                                    (bettingController.hasMoreWinningBets.value ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index == bettingController.winningBets.length) {
                                      return const Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    }
                                    
                                    final bet = bettingController.winningBets[index];
                                    final isLastRow = index == bettingController.winningBets.length - 1;
                                    
                                    return Obx(() => Column(
                                      children: [
                                        if (index > 0)
                                          Divider(height: 1, color: Colors.grey.shade300),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: selectedRowIndex.value == index 
                                                ? AppColors.primaryRed.withOpacity(0.1)
                                                : (index.isEven ? Colors.grey.shade50 : Colors.white),
                                            borderRadius: isLastRow
                                                ? const BorderRadius.only(
                                                    bottomLeft: Radius.circular(8),
                                                    bottomRight: Radius.circular(8),
                                                  )
                                                : null,
                                          ),
                                          child: InkWell(
                                            onTap: () {
                                              if (selectedRowIndex.value == index) {
                                                selectedRowIndex.value = -1;
                                              } else {
                                                selectedRowIndex.value = index;
                                                _showBetDetails(bet);
                                              }
                                            },
                                            child: Row(
                                              children: [
                                                // Type + draw time
                                                SizedBox(
                                                  width: TableColumnWidths.typeWidth,
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          bet.betTypeDrawLabel ?? '',
                                                          style: TextStyle(
                                                            color: Colors.grey[600],
                                                            fontWeight: FontWeight.w500,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        // D4 Sub-selection (table row)
                                                       
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                // Bet Number
                                                SizedBox(
                                                  width: TableColumnWidths.betNumberWidth,
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                                    child: Text(
                                                      bet.betNumber ?? 'Unknown',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.w500,
                                                        color: AppColors.primaryRed,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                // Amount
                                                SizedBox(
                                                  width: TableColumnWidths.amountWidth,
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                                    child: Text(
                                                      bet.formattedAmount,
                                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                                    ),
                                                  ),
                                                ),
                                                // Winning Amount
                                                SizedBox(
                                                  width: TableColumnWidths.winningAmountWidth,
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                                    child: Text(
                                                      bet.formattedWinningAmount,
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.w500,
                                                        color: bet.winningAmount != null && bet.winningAmount != 0 ? Colors.green : null,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                // Ticket ID
                                                SizedBox(
                                                  width: TableColumnWidths.ticketIdWidth,
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                                    child: Text(
                                                      bet.ticketId ?? 'Unknown',
                                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                                      softWrap: false,
                                                    ),
                                                  ),
                                                ),
                                                // Date
                                                SizedBox(
                                                  width: TableColumnWidths.dateWidth,
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                                    child: Text(
                                                      bet.betDateFormatted ?? 'Unknown',
                                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                                    ),
                                                  ),
                                                ),
                                                // Status
                                                SizedBox(
                                                  width: TableColumnWidths.statusWidth,
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: bet.isClaimed == true
                                                            ? Colors.green.withOpacity(0.1)
                                                            : AppColors.primaryRed.withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      child: Text(
                                                        bet.isClaimed == true ? 'Claimed' : 'Unclaimed',
                                                        style: TextStyle(
                                                          color: bet.isClaimed == true ? Colors.green : AppColors.primaryRed,
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ));
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          )],
      ),
    )));
  }
}
