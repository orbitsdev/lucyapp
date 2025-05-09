import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../controllers/betting_controller.dart';
import '../../utils/app_colors.dart';
import '../../models/bet.dart';
import '../../widgets/common/modal.dart';
import '../../widgets/common/local_lottie_image.dart';
import '../../widgets/common/bet_card.dart';

class CancelBetScreen extends StatefulWidget {
  const CancelBetScreen({Key? key}) : super(key: key);

  @override
  State<CancelBetScreen> createState() => _CancelBetScreenState();
}

class _CancelBetScreenState extends State<CancelBetScreen> {
  final BettingController bettingController = Get.find<BettingController>();
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();
  final TextEditingController betNumberController = TextEditingController();
  final RxString selectedSchedule = 'All'.obs;
  final Rx<String?> selectedDate = Rx<String?>(null);
  final ScrollController scrollController = ScrollController();
  
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
    betNumberController.dispose();
    searchController.dispose();
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
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
    // Convert schedule to drawId if needed
    int? drawId;
    if (selectedSchedule.value != 'All') {
      // Find the draw ID based on the selected schedule
      final draw = bettingController.availableDraws.firstWhereOrNull(
        (draw) => draw.drawTimeFormatted == selectedSchedule.value
      );
      drawId = draw?.id;
    }
    
    await bettingController.fetchCancelledBets(
      search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
      date: selectedDate.value,
      drawId: drawId,
    );
  }

  void _cancelBetByNumber() {
    if (betNumberController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a bet number',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // First, search for the bet by number
    isLoading.value = true;
    
    bettingController.fetchBets(
      search: betNumberController.text,
      refresh: true,
    ).then((value) {
      isLoading.value = false;
      
      if (bettingController.bets.isEmpty) {
        Modal.showErrorModal(
          title: 'Bet Not Found',
          message: 'No active bet found with the number ${betNumberController.text}',
        );
        return;
      }
      
      // Get the first matching bet
      final bet = bettingController.bets.first;
      
      // Check if the bet is already cancelled or claimed
      if (bet.isRejected == true) {
        Modal.showErrorModal(
          title: 'Already Cancelled',
          message: 'This bet has already been cancelled',
        );
        return;
      }
      
      if (bet.isClaimed == true) {
        Modal.showErrorModal(
          title: 'Already Claimed',
          message: 'This bet has already been claimed and cannot be cancelled',
        );
        return;
      }
      
      // Show confirmation dialog
      Modal.showConfirmModal(
        title: 'Cancel Bet',
        message: 'Are you sure you want to cancel bet ${betNumberController.text}?',
        onConfirm: () async {
          isLoading.value = true;
          try {
            if (bet.id != null) {
              final result = await bettingController.cancelBet(bet.id!);
              if (result) {
                betNumberController.clear();
                // Refresh the cancelled bets list
                await _fetchCancelledBets();
              }
            }
          } catch (e) {
            Modal.showErrorModal(
              title: 'Error',
              message: 'Failed to cancel bet: ${e.toString()}',
            );
          } finally {
            isLoading.value = false;
          }
        },
      );
    }).catchError((error) {
      isLoading.value = false;
      Modal.showErrorModal(
        title: 'Error',
        message: 'Failed to search for bet: ${error.toString()}',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('CANCEL BET'),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Cancel Bet Form
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
                  'Bet Number',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: betNumberController,
                  decoration: InputDecoration(
                    hintText: 'Enter bet number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: Obx(() => ElevatedButton.icon(
                    onPressed: isLoading.value
                        ? null
                        : _cancelBetByNumber,
                    icon: isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.cancel_outlined, size: 20),
                    label: Text(
                      isLoading.value ? 'PROCESSING...' : 'CANCEL BET',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF616161), // Dark gray
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      disabledBackgroundColor: const Color(0xFF9E9E9E), // Medium gray when disabled
                      elevation: 1,
                    ),
                  )),
                ),
              ],
            ),
          ).animate()
            .fadeIn(duration: 300.ms)
            .slideY(begin: 0.1, end: 0, duration: 300.ms),
          
          // Filter and Search Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                // Date Filter
                Row(
                  children: [
                    const Text(
                      'Date:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Obx(() => OutlinedButton.icon(
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
                            _fetchCancelledBets();
                          }
                        },
                        icon: const Icon(Icons.calendar_today, size: 18),
                        label: Text(
                          selectedDate.value != null
                              ? DateFormat('MMM dd, yyyy').format(
                                  DateTime.parse(selectedDate.value!))
                              : 'Select Date',
                          style: const TextStyle(fontSize: 14),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryRed,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      )),
                    ),
                    if (selectedDate.value != null)
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          selectedDate.value = null;
                          _fetchCancelledBets();
                        },
                        tooltip: 'Clear date filter',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                // Schedule Filter
                Row(
                  children: [
                    const Text(
                      'Draw Filter:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Obx(() => DropdownButton<String>(
                        value: selectedSchedule.value,
                        isExpanded: true,
                        underline: const SizedBox(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            selectedSchedule.value = newValue;
                            _fetchCancelledBets();
                          }
                        },
                        items: [
                          const DropdownMenuItem<String>(
                            value: 'All',
                            child: Text('All Draws'),
                          ),
                          ...bettingController.availableDraws.map((draw) => 
                            DropdownMenuItem<String>(
                              value: draw.drawTimeFormatted ?? 'Unknown',
                              child: Text(draw.drawTimeFormatted ?? 'Unknown'),
                            ),
                          ),
                        ],
                      )),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Search Bar
                TextField(
                  controller: searchController,
                  onChanged: (value) => searchQuery.value = value,
                  decoration: InputDecoration(
                    hintText: 'Search bet number or ticket ID',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: Obx(() => searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            searchController.clear();
                            searchQuery.value = '';
                          },
                        )
                      : const SizedBox.shrink()),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onSubmitted: (_) => _fetchCancelledBets(),
                ),
              ],
            ),
          ),
          
          // Cancelled Bets Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text(
                  'Cancelled Bets',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Obx(() => Text(
                    '${bettingController.cancelledBets.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  )),
                ),
              ],
            ),
          ),
          
          // Table Header
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.primaryRed.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: const [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Bet Number',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Amount',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Schedule',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                  );
                }
                
                return Stack(
                  children: [
                    ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: bettingController.cancelledBets.length + 
                        (bettingController.cancelledBetsCurrentPage.value < bettingController.cancelledBetsTotalPages.value ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Show loading indicator at the end when more items are being loaded
                        if (index == bettingController.cancelledBets.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        
                        final bet = bettingController.cancelledBets[index];
                        return BetCard(
                          bet: bet,
                          onTap: () => _showBetDetails(bet),
                          showCancelButton: false,
                          isCompactMode: true,
                        );
                      },
                    ),
                    
                    // Loading overlay when refreshing with existing data
                    if (bettingController.isLoadingCancelledBets.value && bettingController.cancelledBets.isNotEmpty)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          color: Colors.black54,
                          child: const Center(
                            child: Text(
                              'Loading more cancelled bets...',
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

