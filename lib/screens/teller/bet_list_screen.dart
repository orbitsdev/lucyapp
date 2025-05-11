import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:bettingapp/controllers/betting_controller.dart';
import 'package:bettingapp/controllers/report_controller.dart';
import 'package:bettingapp/controllers/dropdown_controller.dart';
import 'package:bettingapp/models/draw.dart';
import 'package:bettingapp/utils/app_colors.dart';
import 'package:bettingapp/widgets/common/local_lottie_image.dart';
import 'package:bettingapp/widgets/common/modal.dart';

class BetListScreen extends StatefulWidget {
  const BetListScreen({super.key});

  @override
  State<BetListScreen> createState() => _BetListScreenState();
}

/// Defines the fixed column widths for the bet list table
class TableColumnWidths {
  static const double betTypeWidth = 80.0;
  static const double betNumberWidth = 120.0;
  static const double amountWidth = 100.0;
  static const double ticketIdWidth = 130.0;
  static const double drawTimeWidth = 160.0;
  static const double dateWidth = 200.0;
  static const double statusWidth = 100.0;
  static const double actionWidth = 80.0;
  
  // Total width of all columns (drawTimeWidth removed)
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
                                                          Text(
                                                            bet.gameType?.code ?? 'Unknown',
                                                            style: const TextStyle(fontWeight: FontWeight.w500),
                                                          ),
                                                          if ((bet.draw?.drawTimeFormatted ?? '').isNotEmpty)
                                                            Padding(
                                                              padding: const EdgeInsets.only(top: 2.0),
                                                              child: Text(
                                                                bet.draw?.drawTimeFormatted ?? '',
                                                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                                              ),
                                                            ),
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
                                                  // Cancel Button
                                                  SizedBox(
                                                    width: TableColumnWidths.actionWidth,
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                                      child: bet.isRejected != true && bet.isClaimed != true
                                                        ? IconButton(
                                                            icon: const Icon(Icons.cancel_outlined, size: 20),
                                                            color: AppColors.primaryRed,
                                                            onPressed: () => _cancelBet(bet.id!),
                                                            tooltip: 'Cancel Bet',
                                                            padding: EdgeInsets.zero,
                                                            constraints: const BoxConstraints(),
                                                          )
                                                        : const SizedBox(),
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
}
          
          // Bet list
          