import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:bluetooth_print_plus/bluetooth_print_plus.dart';

import '../../controllers/betting_controller.dart';
import '../../controllers/report_controller.dart';
import '../../controllers/dropdown_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/draw.dart';
import '../../utils/app_colors.dart';
import '../../widgets/common/local_lottie_image.dart';
import '../../widgets/common/modal.dart';
import '../teller/printer_setup_screen.dart';

class BetListScreen extends StatefulWidget {
  const BetListScreen({super.key});

  @override

  
  State<BetListScreen> createState() => _BetListScreenState();
}

/// Defines the fixed column widths for the bet list table
class TableColumnWidths {
  static const double betTypeWidth = 100.0;
  static const double betNumberWidth = 120.0;
  static const double amountWidth = 100.0;
  static const double ticketIdWidth = 130.0;
  static const double drawTimeWidth = 160.0;
  static const double dateWidth = 200.0;
  static const double statusWidth = 100.0;
  
  // Total width of all columns (drawTimeWidth removed)
  static const double actionWidth = 100.0;
  static const double totalWidth = betTypeWidth + betNumberWidth + amountWidth + ticketIdWidth + dateWidth + statusWidth + actionWidth;
}

class _BetListScreenState extends State<BetListScreen> {
  final BettingController bettingController = Get.find<BettingController>();
  final DropdownController dropdownController = Get.find<DropdownController>();
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final ScrollController horizontalScrollController = ScrollController();
  
  // Track the currently selected row for highlighting
  final RxInt selectedRowIndex = RxInt(-1);
  final RxInt selectedGameTypeId = RxInt(-1);
  
  @override
  void initState() {
    super.initState();
    // Fetch game types for filter dropdown
    dropdownController.fetchGameTypes();
    _fetchBets();
    
    // Add scroll listener for pagination
    scrollController.addListener(_scrollListener);
  }
  
  @override
  void dispose() {
    searchController.dispose();
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    horizontalScrollController.dispose();
    super.dispose();
  }
  
  // Scroll listener for pagination
  void _scrollListener() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      bettingController.loadMoreBets();
    }
  }
  
  // Fetch bets with optional refresh
  Future<void> _fetchBets({bool refresh = false}) async {
    await bettingController.fetchBets(
      refresh: refresh,
      search: searchController.text.isEmpty ? null : searchController.text,
      date: bettingController.selectedDate.value,
      drawId: bettingController.selectedDrawIdFilter.value,
      is_claimed: bettingController.showClaimed.value ? true : null,
      is_rejected: bettingController.showCancelled.value ? true : null,
      gameTypeId: selectedGameTypeId.value != -1 ? selectedGameTypeId.value : null,
    );
  }
  
  // Handle search
  void _handleSearch() {
    bettingController.searchQuery.value = searchController.text;
    _fetchBets(refresh: true);
  }
  
  // Cancel a bet with confirmation
  Future<void> _cancelBet(int betId) async {
    // Get the bet details for the confirmation message
    final bet = bettingController.bets.firstWhere((bet) => bet.id == betId);
    
    // Format draw time and date for better readability
    final drawTime = bet.draw?.drawTimeFormatted ?? 'Unknown';
    final betDate = bet.betDateFormatted ?? 'Unknown';
    
    // Show confirmation dialog
    Modal.showConfirmationModal(
      title: 'Cancel Bet Confirmation',
      message: 'Are you sure you want to cancel this bet?\n\n' 
              'Ticket ID: ${bet.ticketId}\n'
              'Bet Number: ${bet.betNumber}\n'
              'Amount: ₱${bet.amount?.toInt() ?? bet.amount}\n'
              'Draw Time: $drawTime\n'
              'Date: $betDate\n\n'
              'This action cannot be undone and will update your sales records.', 
      confirmText: 'Yes,Cancel Bet',
      cancelText: 'No,Close',
      isDangerousAction: true,
      animation: 'assets/animations/questionmark.json',
      onConfirm: () async {
        // Show loading indicator
        Modal.showProgressModal(
          title: 'Cancelling Bet',
          message: 'Please wait while we process your request...',
        );
        
        try {
          // Proceed with cancellation
          final result = await bettingController.cancelBet(betId);
          
          // Close the loading modal
          Modal.closeDialog();
          
          if (result) {
            // Refresh the list after cancellation
            _fetchBets(refresh: true);
            
            // Reload today's sales data to reflect the updated cancellation count
            final reportController = Get.find<ReportController>();
            await reportController.fetchTodaySales();
            
            // Show success message
            Modal.showSuccessModal(
              title: 'Bet Cancelled',
              message: 'The bet has been cancelled successfully.',
              showButton: true,
              buttonText: 'OK',
            );
          }
        } catch (e) {
          // Make sure to close the loading modal even if there's an error
          Modal.closeDialog();
          
          // Show error message
          Modal.showErrorModal(
            title: 'Cancellation Failed',
            message: 'Failed to cancel the bet. Please try again.',
          );
        }
      },
    );
  }
  
  // Show filter dialog
  void _showFilterDialog() {
    final currentDate = bettingController.selectedDate.value;
    final currentDrawId = bettingController.selectedDrawIdFilter.value;
    final currentStatus = bettingController.selectedStatus.value;
    final currentGameTypeId = selectedGameTypeId.value;
    
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Filter Bets',
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
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: bettingController.selectedDate.value != null
                        ? DateTime.parse(bettingController.selectedDate.value!)
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
                  
                  if (selectedDate != null) {
                    bettingController.selectedDate.value = 
                        DateFormat('yyyy-MM-dd').format(selectedDate);
                  }
                },
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  bettingController.selectedDate.value != null
                      ? DateFormat('MMM dd, yyyy').format(
                          DateTime.parse(bettingController.selectedDate.value!))
                      : 'Select Date',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryRed,
                ),
              )),
              
              SizedBox(height: 16),
              
              // Draw filter (would need to fetch available draws)
              Text(
                'Draw Time',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 8),
              Obx(() => DropdownButtonFormField<int?>(
                value: bettingController.selectedDrawIdFilter.value,
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
                  bettingController.selectedDrawIdFilter.value = value;
                },
              )),
              
              SizedBox(height: 16),
              
              // Claimed filter
              Obx(() => CheckboxListTile(
                title: Text('Show Claimed'),
                value: bettingController.showClaimed.value,
                onChanged: (val) => bettingController.showClaimed.value = val ?? false,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              )),
              // Cancelled filter
              Obx(() => CheckboxListTile(
                title: Text('Show Cancelled'),
                value: bettingController.showCancelled.value,
                onChanged: (val) => bettingController.showCancelled.value = val ?? false,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              bettingController.selectedDate.value = currentDate;
              bettingController.selectedDrawIdFilter.value = currentDrawId;
              bettingController.selectedStatus.value = currentStatus;
              selectedGameTypeId.value = currentGameTypeId;
              Get.back();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _fetchBets(refresh: true);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Bet List'),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _fetchBets(refresh: true),
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search by ticket ID or bet number',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    _handleSearch();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onSubmitted: (_) => _handleSearch(),
            ),
          ),
          
          // Active filters display
          Obx(() {
            final hasFilters = bettingController.selectedDate.value != null ||
                bettingController.selectedDrawIdFilter.value != null ||
                bettingController.showClaimed.value ||
                bettingController.showCancelled.value;
            if (!hasFilters) return SizedBox.shrink();
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
                          bettingController.resetFilters();
                          _fetchBets(refresh: true);
                        },
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (bettingController.selectedDate.value != null)
                        Chip(
                          label: Text(
                            'Date: ${DateFormat('MMM dd, yyyy').format(DateTime.parse(bettingController.selectedDate.value!))}',
                          ),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () {
                            bettingController.selectedDate.value = null;
                            _fetchBets(refresh: true);
                          },
                        ),
                      if (bettingController.selectedDrawIdFilter.value != null)
                        Chip(
                          label: Text(
                            'Draw: ${bettingController.availableDraws.firstWhere((draw) => draw.id == bettingController.selectedDrawIdFilter.value, orElse: () => Draw(id: 0, drawTimeFormatted: 'Unknown')).drawTimeFormatted ?? 'Unknown'}'
                          ),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () {
                            bettingController.selectedDrawIdFilter.value = null;
                            _fetchBets(refresh: true);
                          },
                        ),
                      if (bettingController.showClaimed.value)
                        Chip(
                          label: const Text('Claimed'),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () {
                            bettingController.showClaimed.value = false;
                            _fetchBets(refresh: true);
                          },
                        ),
                      if (bettingController.showCancelled.value)
                        Chip(
                          label: const Text('Cancelled'),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () {
                            bettingController.showCancelled.value = false;
                            _fetchBets(refresh: true);
                          },
                        ),
                    ],
                  ),
                ],
              ),
            );
          }),
          
          // Bet list
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primaryRed,
              onRefresh: () => _fetchBets(refresh: true),
              child: Obx(() {
                if (bettingController.isLoadingBets.value && bettingController.bets.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                
                if (bettingController.bets.isEmpty) {
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
                              width: 180,
                              height: 180,
                              repeat: true,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No bets found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Try adjusting your filters',
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
                
                // Table with single scrollable area for both header and body
                return Container(
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
                                    SizedBox(width: TableColumnWidths.betTypeWidth, child: Padding(
                                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                      child: Text('Bet Type', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                    )),
                                    SizedBox(width: TableColumnWidths.betNumberWidth, child: Padding(
                                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                      child: Text('Bet Number', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                    )),
                                    SizedBox(width: TableColumnWidths.amountWidth, child: Padding(
                                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                      child: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
                                    SizedBox(width: TableColumnWidths.actionWidth, child: Padding(
                                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                      child: Text('Action', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
                                    itemCount: bettingController.bets.length + 
                                      (bettingController.currentPage.value < bettingController.totalPages.value ? 1 : 0),
                                    itemBuilder: (context, index) {
                                      if (index == bettingController.bets.length) {
                                        return const Center(
                                          child: Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: CircularProgressIndicator(),
                                          ),
                                        );
                                      }
                                      
                                      final bet = bettingController.bets[index];
                                      final isLastRow = index == bettingController.bets.length - 1;
                                      
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
                                                }
                                              },
                                              child: Row(
                                                children: [
                                                  // Bet Type + draw time
                                                  SizedBox(
                                                    width: TableColumnWidths.betTypeWidth,
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          RichText(
                                                            text: TextSpan(
                                                              style:  TextStyle(color: Colors.grey[600]),
                                                              children: <TextSpan>[
                                                                TextSpan(
                                                                  text: bet.draw?.drawTimeSimple ?? 'Unknown',
                                                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                                                ),
                                                                TextSpan(
                                                                  text: bet.gameType?.code ?? 'Unknown',
                                                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          // if ((bet.draw?.drawTimeFormatted ?? '').isNotEmpty)
                                                          //   Padding(
                                                          //     padding: const EdgeInsets.only(top: 2.0),
                                                          //     child: Text(
                                                          //       bet.draw?.drawTimeFormatted ?? '',
                                                          //       style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                                          //     ),
                                                          //   ),
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
                                                        style: const TextStyle(fontWeight: FontWeight.w500),
                                                      ),
                                                    ),
                                                  ),
                                                  // Amount
                                                  SizedBox(
                                                    width: TableColumnWidths.amountWidth,
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                                      child: Text(
                                                        '₱${bet.amount?.toInt() ?? bet.amount}',
                                                        style: const TextStyle(fontWeight: FontWeight.w500),
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
                                                      child: Text(
                                                        bet.isRejected == true ? 'Cancelled' : 
                                                          (bet.isClaimed == true ? 'Claimed' : 'Active'),
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.w500,
                                                          color: bet.isRejected == true ? Colors.red : 
                                                            (bet.isClaimed == true ? Colors.green : Colors.blue),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  // Action - Reprint button
                                                  SizedBox(
                                                    width: TableColumnWidths.actionWidth,
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                                      child: IconButton(
                                                        onPressed: () {
                                                          _printBetTicket(bet);
                                                        },
                                                        icon: Icon(
                                                          Icons.print,
                                                          color: AppColors.printerColor,
                                                          size: 20,
                                                        ),
                                                        tooltip: 'Reprint Ticket',
                                                        style: IconButton.styleFrom(
                                                          backgroundColor: AppColors.printerColor.withOpacity(0.1),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(8),
                                                          ),
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
                      
                      // Loading indicator at the bottom of the table
                      if (bettingController.isLoadingBets.value && bettingController.bets.isNotEmpty)
                        Container(
                          width: TableColumnWidths.totalWidth,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                            ),
                          ),
                          child: const Center(
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ),
          ],
        ),
      ),
    );
  }

  void _showBetDetails(bet) {
    Modal.showCustomModal(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.primaryRed,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Bet Details',
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
          _buildDetailRow('Status', bet.isRejected == true ? 'Cancelled' : (bet.isClaimed == true ? 'Claimed' : 'Active')),
          const SizedBox(height: 16),
          Row(
            children: [
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

  Widget _buildDetailRow(String label, String value) {
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
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Method to handle printing bet ticket
  void _printBetTicket(bet) async {
    // Show confirmation dialog first
    final shouldPrint = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Print Bet Ticket'),
        content: const Text('Do you want to print this bet ticket?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.printerColor,
            ),
            child: const Text('Print'),
          ),
        ],
      ),
    ) ?? false;
    
    if (!shouldPrint) return;
    
    // Check if connected to a printer
    bool isConnected = false;
    try {
      isConnected = await BluetoothPrintPlus.isConnected;
    } catch (e) {
      isConnected = false;
    }
    
    if (!isConnected) {
      Modal.showConfirmationModal(
        title: 'Printer Not Connected',
        message: 'You need to connect to a printer first. Would you like to set up a printer now?',
        confirmText: 'Setup Printer',
        cancelText: 'Cancel',
        animation: 'assets/animations/questionmark.json',
        onConfirm: () async {
          await Get.to(() => const PrinterSetupScreen());
          // Check connection again after returning from setup screen
          try {
            isConnected = await BluetoothPrintPlus.isConnected;
            if (isConnected) {
              // If now connected, try printing again
              _printBetTicket(bet);
            }
          } catch (e) {
            // Error checking connection
            Modal.showErrorModal(
              title: 'Connection Error',
              message: 'Could not verify printer connection. Please try again.',
            );
          }
        },
      );
      return;
    }
    
    try {
      // Show loading dialog
      Modal.showProgressModal(
        title: 'Printing Ticket',
        message: 'Please wait while the ticket is being printed...',
      );
      
      // Get current user info if available
      final authController = Get.find<AuthController>();
      final String tellerName = authController.user.value?.name ?? 'Unknown Teller';
      final String tellerUsername = authController.user.value?.username ?? '';
      final String locationName = authController.user.value?.location?.name ?? 'Unknown Location';
      
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
      final qrData = bet.ticketId ?? 'Unknown';
      bytes.addAll([29, 40, 107, qrData.length + 3, 0, 49, 80, 48]); // GS ( k (data length + 3) 0 49 80 48
      bytes.addAll(utf8.encode(qrData));
      // QR Code - Print symbol data in symbol storage area
      bytes.addAll([29, 40, 107, 3, 0, 49, 81, 48, 0]); // GS ( k 3 0 49 81 48 0
      
      // Add some space after QR code
      bytes.addAll(utf8.encode('\n'));
      
      // Left align for details
      bytes.addAll([27, 97, 0]); // ESC a 0
      
      // Add ticket details
      bytes.addAll(utf8.encode('--------------------------------\n'));
      bytes.addAll(utf8.encode('Ticket ID: ${bet.ticketId}\n'));
      bytes.addAll(utf8.encode('Bet Number: ${bet.betNumber}\n'));
      bytes.addAll(utf8.encode('Amount: ₱${bet.amount?.toInt() ?? bet.amount}\n'));
      bytes.addAll(utf8.encode('Game Type: ${bet.gameType?.name ?? 'Unknown'}\n'));
      bytes.addAll(utf8.encode('Draw Time: ${bet.draw?.drawTimeFormatted ?? 'Unknown'}\n'));
      bytes.addAll(utf8.encode('Date: ${bet.betDateFormatted ?? 'Unknown'}\n'));
      bytes.addAll(utf8.encode('Status: ${bet.isRejected == true ? 'Cancelled' : (bet.isClaimed == true ? 'Claimed' : 'Active')}\n'));
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
      
      // Bold on for watermark
      bytes.addAll([27, 69, 1]); // ESC E 1
      bytes.addAll(utf8.encode('REPRINT - NOT FOR BETTING\n'));
      bytes.addAll([27, 69, 0]); // ESC E 0
      
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
    } catch (e) {
      // Close dialog and show error message
      Modal.closeDialog();
      Modal.showErrorModal(
        title: 'Printing Failed',
        message: 'Failed to print the ticket. Error: $e',
      );
    }
  }
}
          
          // Bet list