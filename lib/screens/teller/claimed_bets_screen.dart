

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:bettingapp/controllers/betting_controller.dart';
import 'package:bettingapp/controllers/dropdown_controller.dart';
import 'package:bettingapp/models/draw.dart';
import 'package:bettingapp/models/bet.dart';
import 'package:bettingapp/utils/app_colors.dart';
import 'package:bettingapp/widgets/common/local_lottie_image.dart';
import 'package:bettingapp/widgets/common/modal.dart';
import 'package:bettingapp/widgets/common/qr_scanner.dart';

/// Defines the fixed column widths for the claimed bet list table
class TableColumnWidths {
  static const double typeWidth = 100.0;
  static const double betNumberWidth = 120.0;
  static const double amountWidth = 100.0;
  static const double ticketIdWidth = 130.0;
  static const double dateWidth = 150.0;
  static const double claimedAtWidth = 150.0;
    
  // Total width of all columns
  static const double totalWidth = typeWidth + betNumberWidth + amountWidth + ticketIdWidth + dateWidth + claimedAtWidth;
}

class ClaimedBetsScreen extends StatefulWidget {
  const ClaimedBetsScreen({Key? key}) : super(key: key);

  @override
  State<ClaimedBetsScreen> createState() => _ClaimedBetsScreenState();
}

class _ClaimedBetsScreenState extends State<ClaimedBetsScreen> {
  final BettingController bettingController = Get.find<BettingController>();
  final DropdownController dropdownController = Get.find<DropdownController>();
  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();
  final TextEditingController ticketIdController = TextEditingController();
  final Rx<String?> selectedDate = Rx<String?>(null);
  final RxInt selectedDrawId = RxInt(-1);
  final RxInt selectedGameTypeId = RxInt(-1);
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
    _fetchClaimedBets();
    
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
      bettingController.loadMoreClaimedBets();
    }
  }

  Future<void> _fetchClaimedBets() async {
    await bettingController.fetchClaimedBets(
      search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
      date: selectedDate.value,
      drawId: selectedDrawId.value != -1 ? selectedDrawId.value : null,
      gameTypeId: selectedGameTypeId.value != -1 ? selectedGameTypeId.value : null,
    );
  }

  void _showFilterDialog() {
    // Save current filter values to restore if cancelled
    final currentDate = selectedDate.value;
    final currentDrawId = selectedDrawId.value;
    final currentGameTypeId = selectedGameTypeId.value;
    
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Filter Claimed Bets',
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
              Get.back();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _fetchClaimedBets();
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
                Icons.info_outline,
                color: AppColors.primaryRed,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Claimed Bet Details',
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
          _buildDetailRow('Amount', bet.formattedAmount),
          _buildDetailRow('Claimed At', bet.claimedAtFormatted ?? 'Unknown'),
          _buildDetailRow('Winner', bet.isWinner == true ? 'Yes' : 'No', 
          textColor: bet.isWinner == true ? Colors.green : null),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Claimed Bets'),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchClaimedBets,
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
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              // --- FORM CARD ---
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
                          onPressed: () async {
                            await Get.to(
                              () => QrScannerPage(
                                onScanned: (ticket) {
                                  ticketIdController.text = ticket;
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: Obx(() => ElevatedButton.icon(
                        onPressed: bettingController.isClaimingBet.value
                            ? null
                            : () async {
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
                                        _fetchClaimedBets();
                                        
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
                              },
                        icon: bettingController.isClaimingBet.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.check_circle_outline, size: 20),
                        label: Text(
                          bettingController.isClaimingBet.value ? 'PROCESSING...' : 'CLAIM BET',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          disabledBackgroundColor: Colors.green.withOpacity(0.5),
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
                        _fetchClaimedBets();
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  onSubmitted: (value) {
                    searchQuery.value = value;
                    _fetchClaimedBets();
                  },
                  textInputAction: TextInputAction.search,
                ),
              ),
              
              // --- ACTIVE FILTERS ---
              Obx(() {
                final hasFilters = selectedDate.value != null ||
                    selectedDrawId.value != -1 ||
                    selectedGameTypeId.value != -1 ||
                    searchQuery.value.isNotEmpty;
                    
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
                              searchController.clear();
                              _fetchClaimedBets();
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
                                _fetchClaimedBets();
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
                                _fetchClaimedBets();
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
                                _fetchClaimedBets();
                              },
                            ),
                          if (searchQuery.value.isNotEmpty)
                            Chip(
                              label: Text('Search: ${searchQuery.value}'),
                              deleteIcon: const Icon(Icons.close, size: 18),
                              onDeleted: () {
                                searchQuery.value = '';
                                searchController.clear();
                                _fetchClaimedBets();
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
              
              // --- CLAIMED BETS COUNT ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    const Text(
                      'Claimed Bets',
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
                        '${bettingController.claimedBets.length}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      )),
                    ),
                  ],
                ),
              ),
              
              // --- CLAIMED BETS LIST ---
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primaryRed,
                  onRefresh: () async => _fetchClaimedBets(),
                  child: Obx(() {
                    if (bettingController.isLoadingClaimedBets.value && 
                        bettingController.claimedBets.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (bettingController.claimedBets.isEmpty) {
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
                                  'No claimed bets found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Claimed bets will appear here',
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
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Hint text for scrollable table
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2.0),
                            child: Text(
                              'Scrollable (Horizontal)',
                              style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                            ),
                          ),
                          // Table container
                          Expanded(
                            child: Stack(
                              children: [
                                // Horizontal scrollable table
                                SingleChildScrollView(
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
                                            SizedBox(width: TableColumnWidths.ticketIdWidth, child: Padding(
                                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                              child: Text('Ticket ID', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                            )),
                                            SizedBox(width: TableColumnWidths.dateWidth, child: Padding(
                                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                              child: Text('Date', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                            )),
                                            SizedBox(width: TableColumnWidths.claimedAtWidth, child: Padding(
                                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                              child: Text('Claimed At', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
                                            itemCount: bettingController.claimedBets.length + 
                                              (bettingController.claimedBetsCurrentPage.value < bettingController.claimedBetsTotalPages.value ? 1 : 0),
                                            itemBuilder: (context, index) {
                                              if (index == bettingController.claimedBets.length) {
                                                return const Center(
                                                  child: Padding(
                                                    padding: EdgeInsets.all(16.0),
                                                    child: CircularProgressIndicator(),
                                                  ),
                                                );
                                              }
                                              final bet = bettingController.claimedBets[index];
                                              final isLastRow = index == bettingController.claimedBets.length - 1;
                                              return Obx(() => Column(
                                                children: [
                                                  if (index > 0)
                                                    Divider(height: 1, color: Colors.grey.shade300),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color: selectedRowIndex.value == index 
                                                          ? AppColors.primaryRed.withOpacity(0.1)
                                                          : (bet.isWinner == true 
                                                              ? Colors.green.withOpacity(0.1) 
                                                              : (index.isEven ? Colors.grey.shade50 : Colors.white)),
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
                                                                    bet.gameType?.name ?? 'Unknown',
                                                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                                                  ),
                                                                  Text(
                                                                    bet.draw?.drawTimeSimple ?? 'Unknown',
                                                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
                                                                bet.formattedAmount,
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
                                                          // Claimed At
                                                          SizedBox(
                                                            width: TableColumnWidths.claimedAtWidth,
                                                            child: Padding(
                                                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                                              child: Text(
                                                                bet.claimedAtFormatted ?? 'Unknown',
                                                                style: const TextStyle(fontWeight: FontWeight.w500),
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
                                
                                // Loading indicator at the bottom
                                if (bettingController.isLoadingClaimedBets.value && bettingController.claimedBets.isNotEmpty)
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      color: Colors.black54,
                                      height: 40,
                                      child: const Center(
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ]),
          ),
        ),
      );
    
  }
}
