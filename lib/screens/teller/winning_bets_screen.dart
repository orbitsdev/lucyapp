import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:bettingapp/controllers/betting_controller.dart';
import 'package:bettingapp/controllers/dropdown_controller.dart';
import 'package:bettingapp/models/bet.dart';
import 'package:bettingapp/utils/app_colors.dart';
import 'package:bettingapp/widgets/common/local_lottie_image.dart';
import 'package:bettingapp/widgets/common/modal.dart';
import 'package:bettingapp/widgets/common/qr_scanner.dart';

/// Defines the fixed column widths for the winning bet list table
class TableColumnWidths {
  static const double typeWidth = 100.0;
  static const double betNumberWidth = 120.0;
  static const double amountWidth = 100.0;
  static const double ticketIdWidth = 130.0;
  static const double dateWidth = 150.0;
  static const double statusWidth = 100.0;
    
  // Total width of all columns
  static const double totalWidth = typeWidth + betNumberWidth + amountWidth + ticketIdWidth + dateWidth + statusWidth;
}

class WinningBetsScreen extends StatefulWidget {
  const WinningBetsScreen({Key? key}) : super(key: key);

  @override
  State<WinningBetsScreen> createState() => _WinningBetsScreenState();
}

class _WinningBetsScreenState extends State<WinningBetsScreen> {
  final BettingController bettingController = Get.find<BettingController>();
  final DropdownController dropdownController = Get.find<DropdownController>();
  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();
  final TextEditingController ticketIdController = TextEditingController();
  final Rx<String?> selectedDate = Rx<String?>(null);
  final RxInt selectedDrawId = RxInt(-1);
  final RxInt selectedGameTypeId = RxInt(-1);
  final RxBool showOnlyUnclaimed = RxBool(true);
  final ScrollController scrollController = ScrollController();
  final ScrollController horizontalScrollController = ScrollController();
  
  // Track the currently selected row for highlighting
  final RxInt selectedRowIndex = RxInt(-1);

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
          _buildDetailRow('Ticket ID', bet.ticketId ?? 'Unknown'),
          _buildDetailRow('Bet Number', bet.betNumber ?? 'Unknown'),
          _buildDetailRow('Date', bet.betDateFormatted ?? 'Unknown'),
          _buildDetailRow('Draw Time', bet.draw?.drawTimeFormatted ?? 'Unknown'),
          _buildDetailRow('Amount', '₱ ${bet.amount?.toInt() ?? bet.amount}'),
          _buildDetailRow('Status', bet.isClaimed == true ? 'Claimed' : 'Unclaimed', 
            textColor: bet.isClaimed == true ? Colors.green : Colors.blue),
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
                      backgroundColor: Colors.green,
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
                      foregroundColor: Colors.grey.shade800,
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
          _showClaimConfirmation();
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
      appBar: AppBar(
        backgroundColor: AppColors.primaryRed,
        title: const Text(
          'Winning Bets (Hits)',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter Bets',
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
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by ticket ID or bet number',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    ),
                    onSubmitted: (value) {
                      searchQuery.value = value;
                      _fetchWinningBets();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    searchQuery.value = searchController.text;
                    _fetchWinningBets();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Search'),
                ),
              ],
            ),
          ),
          
          // Active filters
          _buildActiveFilters(),
          
          // Winning bets list
          Expanded(
            child: Obx(() {
              if (bettingController.isLoadingWinningBets.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              
              if (bettingController.winningBets.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LocalLottieImage(
                        path: 'assets/animations/empty.json',
                        width: 200,
                        height: 200,
                        repeat: false,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No winning bets found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _fetchWinningBets,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryRed,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              return Column(
                children: [
                  // Table header
                  Container(
                    color: Colors.grey.shade100,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      controller: horizontalScrollController,
                      child: Row(
                        children: [
                          SizedBox(width: TableColumnWidths.typeWidth, child: const Text('Type', style: TextStyle(fontWeight: FontWeight.bold))),
                          SizedBox(width: TableColumnWidths.betNumberWidth, child: const Text('Bet Number', style: TextStyle(fontWeight: FontWeight.bold))),
                          SizedBox(width: TableColumnWidths.amountWidth, child: const Text('Amount', style: TextStyle(fontWeight: FontWeight.bold))),
                          SizedBox(width: TableColumnWidths.ticketIdWidth, child: const Text('Ticket ID', style: TextStyle(fontWeight: FontWeight.bold))),
                          SizedBox(width: TableColumnWidths.dateWidth, child: const Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                          SizedBox(width: TableColumnWidths.statusWidth, child: const Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ),
                  ),
                  
                  // Table body
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: bettingController.winningBets.length + (bettingController.hasMoreWinningBets.value ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Show loading indicator at the bottom when loading more
                        if (index == bettingController.winningBets.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        
                        final bet = bettingController.winningBets[index];
                        final isSelected = selectedRowIndex.value == index;
                        
                        return InkWell(
                          onTap: () {
                            selectedRowIndex.value = index;
                            _showBetDetails(bet);
                          },
                          child: Container(
                            color: isSelected
                                ? AppColors.primaryRed.withOpacity(0.1)
                                : (index % 2 == 0 ? Colors.white : Colors.grey.shade50),
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              controller: horizontalScrollController,
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: TableColumnWidths.typeWidth,
                                    child: Text(bet.gameType?.name ?? 'Unknown'),
                                  ),
                                  SizedBox(
                                    width: TableColumnWidths.betNumberWidth,
                                    child: Text(
                                      bet.betNumber ?? 'Unknown',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryRed,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: TableColumnWidths.amountWidth,
                                    child: Text('₱ ${bet.amount?.toInt() ?? bet.amount}'),
                                  ),
                                  SizedBox(
                                    width: TableColumnWidths.ticketIdWidth,
                                    child: Text(bet.ticketId ?? 'Unknown'),
                                  ),
                                  SizedBox(
                                    width: TableColumnWidths.dateWidth,
                                    child: Text(bet.betDateFormatted ?? 'Unknown'),
                                  ),
                                  SizedBox(
                                    width: TableColumnWidths.statusWidth,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: bet.isClaimed == true
                                            ? Colors.green.withOpacity(0.1)
                                            : Colors.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        bet.isClaimed == true ? 'Claimed' : 'Unclaimed',
                                        style: TextStyle(
                                          color: bet.isClaimed == true ? Colors.green : Colors.blue,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
