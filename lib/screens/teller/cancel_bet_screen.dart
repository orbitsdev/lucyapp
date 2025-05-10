import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/betting_controller.dart';
import '../../utils/app_colors.dart';
import '../../models/bet.dart';
import '../../models/draw.dart';
import '../../widgets/common/modal.dart';
import '../../widgets/common/local_lottie_image.dart';

/// Defines the fixed column widths for the cancelled bet list table
class TableColumnWidths {
  static const double ticketIdWidth = 130.0;
  static const double betNumberWidth = 120.0;
  static const double amountWidth = 100.0;
  static const double drawTimeWidth = 100.0;
  static const double dateWidth = 150.0;
  
  // Total width of all columns
  static const double totalWidth = ticketIdWidth + betNumberWidth + amountWidth + 
                                  drawTimeWidth + dateWidth;
}

class CancelBetScreen extends StatefulWidget {
  const CancelBetScreen({Key? key}) : super(key: key);

  @override
  State<CancelBetScreen> createState() => _CancelBetScreenState();
}

class _CancelBetScreenState extends State<CancelBetScreen> {
  final BettingController bettingController = Get.find<BettingController>();
  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();
  final Rx<String?> selectedDate = Rx<String?>(null);
  final RxInt? selectedDrawId = RxInt(-1);
  final ScrollController scrollController = ScrollController();
  final ScrollController horizontalScrollController = ScrollController();
  
  // Track the currently selected row for highlighting
  final RxInt selectedRowIndex = RxInt(-1);
  
  // Debounce worker for search
  Worker? _searchDebounce;

  @override
  void initState() {
    super.initState();
    // Fetch available draws for filtering
    bettingController.fetchAvailableDraws();
    _fetchCancelledBets();
    
    // Setup debounce for search
    _searchDebounce = debounce(
      searchQuery, 
      (_) => _fetchCancelledBets(),
      time: const Duration(milliseconds: 500),
    );
    
    // Add scroll listener for pagination
    scrollController.addListener(_scrollListener);
  }
  
  @override
  void dispose() {
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
      bettingController.loadMoreCancelledBets();
    }
  }

  Future<void> _fetchCancelledBets() async {
    await bettingController.fetchCancelledBets(
      search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
      date: selectedDate.value,
      drawId: selectedDrawId?.value != -1 ? selectedDrawId?.value : null,
    );
  }

  void _showFilterDialog() {
    // Save current filter values to restore if cancelled
    final currentDate = selectedDate.value;
    final currentDrawId = selectedDrawId?.value;
    
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Filter Cancelled Bets',
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
                value: selectedDrawId?.value == -1 ? null : selectedDrawId?.value,
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
                  selectedDrawId?.value = value ?? -1;
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
              selectedDrawId?.value = currentDrawId ?? -1;
              Get.back();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _fetchCancelledBets();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use resizeToAvoidBottomInset to handle keyboard properly
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Cancel Bet'),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
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
                    _fetchCancelledBets();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onSubmitted: (_) => _fetchCancelledBets(),
              onChanged: (value) => searchQuery.value = value,
            ),
          ),
          
          // Active filters display
          Obx(() {
            final hasFilters = selectedDate.value != null ||
                selectedDrawId?.value != -1;
                
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
                          selectedDate.value = null;
                          selectedDrawId?.value = -1;
                          _fetchCancelledBets();
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
                            _fetchCancelledBets();
                          },
                        ),
                      if (selectedDrawId?.value != -1 && selectedDrawId?.value != null)
                        Chip(
                          label: Text(
                            'Draw: ${bettingController.availableDraws
                              .firstWhere(
                                (draw) => draw.id == selectedDrawId?.value,
                                orElse: () => Draw(id: 0, drawTimeFormatted: 'Unknown')
                              ).drawTimeFormatted ?? 'Unknown'}'
                          ),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () {
                            selectedDrawId?.value = -1;
                            _fetchCancelledBets();
                          },
                        ),
                    ],
                  ),
                ],
              ),
            );
          }),
          
          // Cancelled Bets count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                const Text(
                  'Cancelled Bets',
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
                    '${bettingController.cancelledBets.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  )),
                ),
              ],
            ),
          ),
          
          // Cancelled Bets List
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primaryRed,
              onRefresh: _fetchCancelledBets,
              child: Obx(() {
                if (bettingController.isLoadingCancelledBets.value && 
                    bettingController.cancelledBets.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                
                if (bettingController.cancelledBets.isEmpty) {
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
                              'No cancelled bets found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Cancelled bets will appear here',
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
                                        SizedBox(width: TableColumnWidths.ticketIdWidth, child: Padding(
                                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                          child: Text('Ticket ID', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                        )),
                                        SizedBox(width: TableColumnWidths.betNumberWidth, child: Padding(
                                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                          child: Text('Bet Number', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                        )),
                                        SizedBox(width: TableColumnWidths.amountWidth, child: Padding(
                                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                          child: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                        )),
                                        SizedBox(width: TableColumnWidths.drawTimeWidth, child: Padding(
                                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                          child: Text('Draw Time', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                        )),
                                        SizedBox(width: TableColumnWidths.dateWidth, child: Padding(
                                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                          child: Text('Date', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                        )),
                                      ],
                                    ),
                                  ),
                                  
                                  // Table body
                                  Container(
                                    width: TableColumnWidths.totalWidth,
                                    height: MediaQuery.of(context).viewInsets.bottom > 0
                                        ? MediaQuery.of(context).size.height * 0.25 // Smaller when keyboard is shown
                                        : MediaQuery.of(context).size.height * 0.45, // Normal height when keyboard is hidden
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
                                      itemCount: bettingController.cancelledBets.length + 
                                        (bettingController.cancelledBetsCurrentPage.value < bettingController.cancelledBetsTotalPages.value ? 1 : 0),
                                      itemBuilder: (context, index) {
                                        if (index == bettingController.cancelledBets.length) {
                                          return const Center(
                                            child: Padding(
                                              padding: EdgeInsets.all(16.0),
                                              child: CircularProgressIndicator(),
                                            ),
                                          );
                                        }
                                        
                                        final bet = bettingController.cancelledBets[index];
                                        final isLastRow = index == bettingController.cancelledBets.length - 1;
                                        
                                        return Obx(() => Column(
                                          children: [
                                            // Add a separator line except for the first row
                                            if (index > 0)
                                              Divider(height: 1, color: Colors.grey.shade300),
                                            Container(
                                              decoration: BoxDecoration(
                                                // Use a reactive color based on selection state
                                                color: selectedRowIndex.value == index 
                                                    ? AppColors.primaryRed.withOpacity(0.1) // Highlight selected row
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
                                                  // Toggle row selection
                                                  if (selectedRowIndex.value == index) {
                                                    selectedRowIndex.value = -1; // Deselect
                                                  } else {
                                                    selectedRowIndex.value = index; // Select
                                                    _showBetDetails(bet);
                                                  }
                                                },
                                                child: Row(
                                                  children: [
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
                                                          '₱${bet.amount?.toStringAsFixed(2) ?? '0.00'}',
                                                          style: const TextStyle(fontWeight: FontWeight.w500),
                                                        ),
                                                      ),
                                                    ),
                                                    // Draw Time
                                                    SizedBox(
                                                      width: TableColumnWidths.drawTimeWidth,
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                                        child: Text(
                                                          bet.draw?.drawTimeFormatted ?? 'Unknown',
                                                          style: const TextStyle(fontWeight: FontWeight.w500),
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
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ));
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Loading indicator at the bottom
                            if (bettingController.isLoadingCancelledBets.value && bettingController.cancelledBets.isNotEmpty)
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
                'Cancellation Details',
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
          _buildDetailRow('Amount', '₱ ${bet.amount?.toStringAsFixed(2) ?? '0.00'}'),
          _buildDetailRow('Status', 'Cancelled'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                foregroundColor: Colors.white,
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
}
