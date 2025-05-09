import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:bettingapp/controllers/betting_controller.dart';
import 'package:bettingapp/models/draw.dart';
import 'package:bettingapp/utils/app_colors.dart';
import 'package:bettingapp/widgets/common/local_lottie_image.dart';
import 'package:bettingapp/widgets/common/bet_card.dart';

class BetListScreen extends StatefulWidget {
  const BetListScreen({super.key});

  @override
  State<BetListScreen> createState() => _BetListScreenState();
}

class _BetListScreenState extends State<BetListScreen> {
  final BettingController bettingController = Get.find<BettingController>();
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    // Fetch bets when the screen loads
    _fetchBets();
    
    // Add scroll listener for pagination
    scrollController.addListener(_scrollListener);
  }
  
  @override
  void dispose() {
    searchController.dispose();
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
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
      status: bettingController.selectedStatus.value,
    );
  }
  
  // Handle search
  void _handleSearch() {
    bettingController.searchQuery.value = searchController.text;
    _fetchBets(refresh: true);
  }
  
  // Cancel a bet
  Future<void> _cancelBet(int betId) async {
    final result = await bettingController.cancelBet(betId);
    if (result) {
      // Refresh the list after cancellation
      _fetchBets(refresh: true);
    }
  }
  
  // Show filter dialog
  void _showFilterDialog() {
    // Save current filter values to restore if cancelled
    final currentDate = bettingController.selectedDate.value;
    final currentDrawId = bettingController.selectedDrawIdFilter.value;
    final currentStatus = bettingController.selectedStatus.value;
    
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
              // Date filter
              Text(
                'Date',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
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
              
              const SizedBox(height: 16),
              
              // Draw filter (would need to fetch available draws)
              Text(
                'Draw Time',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
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
              
              const SizedBox(height: 16),
              
              // Status filter
              Text(
                'Status',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Obx(() => DropdownButtonFormField<String?>(
                value: bettingController.selectedStatus.value,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                items: const [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All Statuses'),
                  ),
                  DropdownMenuItem<String?>(
                    value: 'active',
                    child: Text('Active'),
                  ),
                  DropdownMenuItem<String?>(
                    value: 'claimed',
                    child: Text('Claimed'),
                  ),
                  DropdownMenuItem<String?>(
                    value: 'rejected',
                    child: Text('Cancelled'),
                  ),
                ],
                onChanged: (value) {
                  bettingController.selectedStatus.value = value;
                },
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Restore previous values
              bettingController.selectedDate.value = currentDate;
              bettingController.selectedDrawIdFilter.value = currentDrawId;
              bettingController.selectedStatus.value = currentStatus;
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
      appBar: AppBar(
        title: const Text('Bet List'),
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
                bettingController.selectedStatus.value != null;
                
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
                            'Date: ${DateFormat('MMM dd, yyyy').format(
                              DateTime.parse(bettingController.selectedDate.value!)
                            )}',
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
                            'Draw: ${bettingController.availableDraws
                              .firstWhere(
                                (draw) => draw.id == bettingController.selectedDrawIdFilter.value,
                                orElse: () => Draw(id: 0, drawTimeFormatted: 'Unknown')
                              ).drawTimeFormatted ?? 'Unknown'}'
                          ),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () {
                            bettingController.selectedDrawIdFilter.value = null;
                            _fetchBets(refresh: true);
                          },
                        ),
                      if (bettingController.selectedStatus.value != null)
                        Chip(
                          label: Text(
                            'Status: ${bettingController.selectedStatus.value!.capitalizeFirst}'
                          ),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () {
                            bettingController.selectedStatus.value = null;
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const LocalLottieImage(
                          path: 'assets/animations/empty_state.json',
                          width: 180,
                          height: 180,
                          repeat: true,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No bets found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your filters',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return Stack(
                  children: [
                    ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.only(bottom: 16),
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
                        return BetCard(
                          bet: bet,
                          onCancelBet: _cancelBet,
                          showCancelButton: true,
                        );
                      },
                    ),
                    
                    // Loading overlay for additional data
                    if (bettingController.isLoadingBets.value && bettingController.bets.isNotEmpty)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          color: Colors.black54,
                          child: const Center(
                            child: Text(
                              'Loading more bets...',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
  

}
