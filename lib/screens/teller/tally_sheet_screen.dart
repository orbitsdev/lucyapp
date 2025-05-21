import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bettingapp/utils/app_colors.dart';
import 'package:bettingapp/controllers/report_controller.dart';
import 'package:bettingapp/models/detailed_tallysheet.dart';
import 'package:bettingapp/widgets/common/local_lottie_image.dart';
import 'package:intl/intl.dart';
import 'package:dynamic_tabbar/dynamic_tabbar.dart';
import 'dart:math';

class TallySheetScreen extends StatefulWidget {
  const TallySheetScreen({Key? key}) : super(key: key);

  @override
  State<TallySheetScreen> createState() => _TallySheetScreenState();
}

class _TallySheetScreenState extends State<TallySheetScreen> {
  final ReportController reportController = Get.find<ReportController>();
  final ScrollController scrollController = ScrollController();
  final RxInt _currentTabIndex = 0.obs;
  final RxList<TabData> _tabs = <TabData>[].obs;
  
  // Track the selected date for immediate UI updates
  final RxString selectedDateFormatted = 'Today'.obs;
  
  // Dynamic game type color map (can be extended or loaded from API/config in the future)
  final Map<String, Color> gameTypeColorMap = {
    'S2': Colors.blue,
    'S3': Colors.green,
    'D4': Colors.purple,
    // Add more as needed, or load from API/config
  };
  
  @override
  void initState() {
    super.initState();
    _loadData();
    _loadAvailableDates();
    
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
    
    // Reset tabs if we have no data
    if (report == null || report.bets == null || report.bets!.isEmpty) {
      _tabs.value = <TabData>[
        TabData(
          index: 0,
          title: const Tab(text: 'ALL'),
          content: _buildBetsGrid([]),
        ),
      ];
      return;
    }
    
    // Process tabs if we have valid data
    final newTabs = <TabData>[];
    
    // Add ALL tab
    newTabs.add(
      TabData(
        index: 0,
        title: const Tab(text: 'ALL'),
        content: Obx(() => _buildBetsGrid(reportController.detailedTallysheet.value?.bets ?? [])),
      ),
    );
    
    // Only add game type tabs if we have valid betsByGameType data
    if (report.betsByGameType != null && report.betsByGameType!.isNotEmpty) {
      // Preferred order for game type codes - include D4 sub-selections
      final preferredOrder = ['S2', 'S3', 'D4', 'D4-S2', 'D4-S3', 'D6', 'D8', 'D10'];
      final allCodes = report.betsByGameType!.keys.toList();
      allCodes.sort((a, b) {
        final aIndex = preferredOrder.indexOf(a);
        final bIndex = preferredOrder.indexOf(b);
        if (aIndex == -1 && bIndex == -1) return a.compareTo(b);
        if (aIndex == -1) return 1;
        if (bIndex == -1) return -1;
        return aIndex.compareTo(bIndex);
      });
      for (final gameTypeCode in allCodes) {
        newTabs.add(
          TabData(
            index: newTabs.length,
            title: Tab(text: gameTypeCode),
            content: Obx(() => _buildBetsGrid(
              reportController.detailedTallysheet.value?.betsByGameType?[gameTypeCode] ?? []
            )),
          ),
        );
      }
    }
    
    // Update tabs list
    _tabs.value = newTabs;
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
      final gameTypeCode = _tabs[i].title.text;
      tabViews.add(_tabs[i].content);
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
                        'Type',
                        textAlign: TextAlign.left,
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
  
  // Generate a readable, system-matching color for each game type code
  Color colorFromCode(String code) {
    // Use a palette of system colors for consistency and readability
    final palette = [
      AppColors.primaryBlue,
      AppColors.primaryRed,
      AppColors.historyColor,
      AppColors.hitsColor,
      AppColors.claimColor,
      AppColors.comboColor,
      AppColors.salesColor,
      AppColors.tallyColor,
      AppColors.summaryColor,
      AppColors.betWinColor,
      AppColors.generateColor,
      AppColors.info,
      AppColors.success,
      AppColors.warning,
      AppColors.error,
    ];
    final hash = code.codeUnits.fold(0, (prev, elem) => prev + elem);
    return palette[hash % palette.length];
  }
  
  // Build a row for each bet
  Widget _buildBetRow(BetDetail bet, int index) {
    // Safely handle potentially null or dynamic values
    String betNumber = '';
    if (bet.betNumber != null) {
      try {
        betNumber = bet.betNumber.toString();
      } catch (e) {
        betNumber = 'Error';
      }
    }
    
    final gameTypeCode = bet.gameTypeCode ?? '';
    final drawTimeSimple = bet.drawTimeSimple ?? '';
    // Use the displayType if available, otherwise fallback to gameTypeCode
    final displayType = bet.displayType ?? gameTypeCode;

    // Use system palette for game type color
    final gameTypeColor = colorFromCode(displayType);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Material(
        elevation: 1,
        borderRadius: BorderRadius.circular(8),
        color: index.isEven ? Colors.white : Colors.grey.shade50,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Type (pill style, centered)
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: gameTypeColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      // Ensure we have valid strings to display
                      '$drawTimeSimple${displayType.isNotEmpty ? displayType : "Unknown"}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: gameTypeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
              // Bet number (centered)
              Expanded(
                flex: 2,
                child: Center(
                  child: Text(
                    betNumber,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              // Amount (right aligned and centered vertically)
              Expanded(
                flex: 2,
                child: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    // Safely handle amount formatting
                    '₱${bet.amountFormatted ?? (bet.amount?.toString() ?? '0')}',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.primaryRed,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: (index * 30).ms);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('TALLYSHEET'),
        backgroundColor: AppColors.primaryRed,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
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
        
        return Column(
          children: [
            // Date picker always at the top, like commission screen
           
            // Top Section: Centered White Card and Centered Red Buttons
            Container(
              width: double.infinity,
              color: AppColors.primaryRed,
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Centered White Card
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Total Amount',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '₱${report?.totalAmountFormatted ?? '0'}',
                            style: const TextStyle(
                              color: AppColors.primaryRed,
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Centered Row of Red Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                        margin: const EdgeInsets.only(right: 14),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.category, color: Colors.white, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              gameType,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
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
                            final apiDateFormat = DateFormat('yyyy-MM-dd').format(picked);
                            final displayDateFormat = DateFormat('MMMM d, yyyy').format(picked);
                            selectedDateFormatted.value = displayDateFormat;
                            reportController.isLoadingDetailedTallysheet.value = true;
                            await reportController.fetchDetailedTallysheet(
                              date: apiDateFormat,
                              gameTypeId: reportController.selectedGameTypeId.value,
                              page: 1,
                              perPage: reportController.perPage.value,
                            );
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.calendar_today, color: Colors.white, size: 20),
                              const SizedBox(width: 10),
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
                    ],
                  ),
                ],
              ),
            ),
            // Dynamic TabBar or Empty State
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryRed),
                      ),
                    )
                  : report?.bets != null && report!.bets!.isNotEmpty
                      ? DynamicTabBarWidget(
                          tabAlignment: TabAlignment.center,
                          dynamicTabs: _tabs,
                          isScrollable: true,
                          labelColor: AppColors.primaryRed,
                          unselectedLabelColor: Colors.grey[600],
                          indicatorColor: AppColors.primaryRed,
                          backIcon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryRed, size: 20),
                          nextIcon: Icon(Icons.arrow_forward_ios_rounded, color: AppColors.primaryRed, size: 20),
                          onTabChanged: (index) {
                            _currentTabIndex.value = index ?? 0;
                          },
                          onTabControllerUpdated: (controller) {},
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
          ],
        );
      }),
    );
  }
}
