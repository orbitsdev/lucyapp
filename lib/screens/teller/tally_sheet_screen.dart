import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bettingapp/utils/app_colors.dart';
import 'package:bettingapp/controllers/report_controller.dart';
import 'package:bettingapp/models/detailed_tallysheet.dart';
import 'package:bettingapp/widgets/common/local_lottie_image.dart';
import 'package:intl/intl.dart';

class TallySheetScreen extends StatefulWidget {
  const TallySheetScreen({Key? key}) : super(key: key);

  @override
  State<TallySheetScreen> createState() => _TallySheetScreenState();
}

class _TallySheetScreenState extends State<TallySheetScreen> with SingleTickerProviderStateMixin {
  final ReportController reportController = Get.find<ReportController>();
  final ScrollController scrollController = ScrollController();
  late TabController _tabController;
  final RxInt _currentTabIndex = 0.obs;
  // Start with default tabs that will be shown before data loads
  final RxList<String> _tabs = <String>['ALL', 'S2', 'S3', 'D4'].obs;
  
  // Track the selected date for immediate UI updates
  final RxString selectedDateFormatted = 'Today'.obs;
  
  @override
  void initState() {
    super.initState();
    _loadData();
    _loadAvailableDates();
    
    // Initialize tab controller with initial value
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      _currentTabIndex.value = _tabController.index;
    });
    
    // Add scroll listener for pagination
    scrollController.addListener(_scrollListener);
    
    // Initialize with today's date
    final today = DateTime.now();
    selectedDateFormatted.value = DateFormat('MMMM d, yyyy').format(today);
  }
  
  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }
  
  // Scroll listener for pagination
  void _scrollListener() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      reportController.loadMoreDetailedTallysheet();
    }
  }
  
  Future<void> _loadData() async {
    await reportController.fetchTodayDetailedTallysheet();
    _updateTabsFromResponse();
  }
  
  // Update tabs based on the API response
  void _updateTabsFromResponse() {
    final report = reportController.detailedTallysheet.value;
    
    // Only update tabs if we have valid data
    if (report?.betsByGameType != null && report!.betsByGameType!.isNotEmpty) {
      // Start with 'ALL' tab
      final newTabs = <String>['ALL'];
      
      // Add tabs for each game type in the response
      report.betsByGameType!.keys.forEach((gameTypeCode) {
        newTabs.add(gameTypeCode);
      });
      
      // Only update if the tabs have changed
      if (!_areTabsEqual(_tabs, newTabs)) {
        // Update tabs list
        _tabs.value = newTabs;
        
        // Recreate tab controller with new length
        _tabController.dispose();
        _tabController = TabController(length: _tabs.length, vsync: this);
        _tabController.addListener(() {
          _currentTabIndex.value = _tabController.index;
        });
      }
    }
  }
  
  // Helper to compare two lists of tabs
  bool _areTabsEqual(List<String> tabs1, List<String> tabs2) {
    if (tabs1.length != tabs2.length) return false;
    for (int i = 0; i < tabs1.length; i++) {
      if (tabs1[i] != tabs2[i]) return false;
    }
    return true;
  }
  
  Future<void> _loadAvailableDates() async {
    await reportController.fetchAvailableDates();
  }
  
  // Build tab views dynamically based on available game types
  List<Widget> _buildTabViews(DetailedTallysheet report) {
    final tabViews = <Widget>[];
    
    // First tab is always ALL
    tabViews.add(_buildBetsGrid(report.bets ?? []));
    
    // Add tab views for each game type
    for (int i = 1; i < _tabs.length; i++) {
      final gameTypeCode = _tabs[i];
      tabViews.add(_buildBetsGrid(report.betsByGameType?[gameTypeCode] ?? []));
    }
    
    return tabViews;
  }
  
  // Build a table of bets
  Widget _buildBetsGrid(List<BetDetail> bets) {
    if (bets.isEmpty) {
      return Center(
        child: Text(
          'No bets available for this game type',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Table header
            Container(
              decoration: BoxDecoration(
                color: AppColors.primaryRed,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Bet Number',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Amount',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Game Type',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Table body
            Container(
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
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: bets.length,
                itemBuilder: (context, index) {
                  final bet = bets[index];
                  return _buildBetRow(bet, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Build a row for each bet
  Widget _buildBetRow(BetDetail bet, int index) {
    final betNumber = bet.betNumber?.toString() ?? '';
    final amount = bet.amountFormatted ?? '0.00';
    final gameTypeCode = bet.gameTypeCode ?? '';
    
    // Different colors for different game types
    Color gameTypeColor;
    switch (gameTypeCode) {
      case 'S2':
        gameTypeColor = Colors.blue;
        break;
      case 'S3':
        gameTypeColor = Colors.green;
        break;
      case 'D4':
        gameTypeColor = Colors.purple;
        break;
      default:
        gameTypeColor = AppColors.primaryRed;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: index.isEven ? Colors.grey.shade50 : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        children: [
          // Bet number
          Expanded(
            flex: 2,
            child: Text(
              betNumber,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ),
          
          // Amount
          Expanded(
            flex: 2,
            child: Text(
              '₱$amount',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.primaryRed,
              ),
            ),
          ),
          
          // Game type
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: gameTypeColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    gameTypeCode,
                    style: TextStyle(
                      color: gameTypeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: (index * 30).ms);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('DETAILED TALLYSHEET'),
        backgroundColor: AppColors.primaryRed,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              _loadData();
              Get.snackbar(
                'Refreshing',
                'Updating tallysheet data...',
                backgroundColor: Colors.white,
                colorText: AppColors.primaryRed,
                duration: const Duration(seconds: 1),
              );
            },
          ),
          
        ],
      ),
      body: Obx(() {
        final report = reportController.detailedTallysheet.value;
        final isLoading = reportController.isLoadingDetailedTallysheet.value;
        
        // Use values from the API response (or defaults if null)
        final gameType = report?.gameType?.name ?? 'All Bet';
        final totalAmount = report?.totalAmountFormatted ?? '0.00';
        
        return Column(
          children: [
            // Header with date and game type info
            Container(
              width: double.infinity,
              color: AppColors.primaryRed,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date and Game Type display
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.category, color: Colors.white, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  'Bet Type: $gameType',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Total Amount',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '₱$totalAmount',
                              style: const TextStyle(
                                color: AppColors.primaryRed,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  // Date selection button
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: report?.date != null ? DateTime.parse(report!.date!) : DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: AppColors.primaryRed,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          // Format date for API (yyyy-MM-dd)
                          final apiDateFormat = DateFormat('yyyy-MM-dd').format(picked);
                          
                          // Format date for display (Month d, yyyy)
                          final displayDateFormat = DateFormat('MMMM d, yyyy').format(picked);
                          
                          // Immediately update the displayed date
                          selectedDateFormatted.value = displayDateFormat;
                          
                          // Clear any existing data to show loading state
                          reportController.isLoadingDetailedTallysheet.value = true;
                          
                          // Update the date parameter only, don't pass drawId
                          await reportController.fetchDetailedTallysheet(
                            date: apiDateFormat,
                            gameTypeId: reportController.selectedGameTypeId.value,
                            page: 1,
                            perPage: reportController.perPage.value,
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today, color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Obx(() => Text(
                              selectedDateFormatted.value,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Tab Bar for game types
            Container(
              color: Colors.white,
              child: Obx(() => TabBar(
                controller: _tabController,
                labelColor: AppColors.primaryRed,
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: AppColors.primaryRed,
                isScrollable: true,
                tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
              )),
            ),
            
            // Bet list with tabs
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primaryRed,
                onRefresh: () async {
                  // Refresh data with current filters
                  if (report?.date != null) {
                    await reportController.fetchDetailedTallysheet(
                      date: report!.date!,
                      gameTypeId: reportController.selectedGameTypeId.value,
                      page: 1,
                      perPage: reportController.perPage.value,
                    );
                  } else {
                    await _loadData();
                  }
                },
                child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryRed),
                      ),
                    )
                  : report?.bets != null && report!.bets!.isNotEmpty
                    ? TabBarView(
                        controller: _tabController,
                        children: _buildTabViews(report),
                      )
                    : Center(
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Container(
                            height: 300,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Use Lottie animation for empty state
                                LocalLottieImage(
                                  path: 'assets/animations/empty_state.json',
                                  width: 180,
                                  height: 180,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No bet details available',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'for ${report?.dateFormatted ?? selectedDateFormatted.value}',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
