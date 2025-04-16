import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bettingapp/utils/app_colors.dart';
import 'package:bettingapp/widgets/date_dropdown.dart';
import 'package:bettingapp/widgets/location_dropdown.dart';
import 'package:intl/intl.dart';

class SummaryController extends GetxController {
  final RxString selectedLocation = 'All Locations'.obs;
  final RxString selectedTimeframe = 'This Month'.obs;
  final RxBool isLoading = false.obs;
  final RxMap<String, dynamic> summaryData = <String, dynamic>{}.obs;
  
  final List<String> locations = [
    'All Locations',
    'Davao',
    'Isulan',
    'Tacurong',
    'S2',
    'S3',
    'L2',
    'L3',
    '4D',
    'P3'
  ];
  
  final List<String> timeframes = [
    'Today',
    'Yesterday',
    'This Week',
    'This Month',
    'Custom'
  ];
  
  @override
  void onInit() {
    super.onInit();
    // Load initial summary data
    loadSummaryData();
  }
  
  Future<void> loadSummaryData() async {
    isLoading.value = true;
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Sample summary data
    summaryData.value = {
      'totalBets': 1245,
      'totalAmount': 348903,
      'totalHits': 287,
      'hitsAmount': 155550,
      'netProfit': 193353,
      'profitPercentage': 55.4,
      'topCombinations': [
        {'combo': '123', 'count': 87, 'amount': 8700},
        {'combo': '456', 'count': 65, 'amount': 6500},
        {'combo': '789', 'count': 54, 'amount': 5400},
        {'combo': '234', 'count': 43, 'amount': 4300},
        {'combo': '567', 'count': 32, 'amount': 3200},
      ],
      'dailyStats': [
        {'date': DateTime.now().subtract(const Duration(days: 6)), 'bets': 178, 'hits': 42, 'profit': 27600},
        {'date': DateTime.now().subtract(const Duration(days: 5)), 'bets': 192, 'hits': 38, 'profit': 31200},
        {'date': DateTime.now().subtract(const Duration(days: 4)), 'bets': 165, 'hits': 35, 'profit': 26000},
        {'date': DateTime.now().subtract(const Duration(days: 3)), 'bets': 201, 'hits': 45, 'profit': 31100},
        {'date': DateTime.now().subtract(const Duration(days: 2)), 'bets': 187, 'hits': 40, 'profit': 29400},
        {'date': DateTime.now().subtract(const Duration(days: 1)), 'bets': 210, 'hits': 47, 'profit': 32600},
        {'date': DateTime.now(), 'bets': 112, 'hits': 40, 'profit': 14453},
      ],
    };
    
    isLoading.value = false;
  }
  
  void updateFilters() {
    // In a real app, this would fetch data based on the selected filters
    loadSummaryData();
  }
}

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SummaryController());
    
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('SUMMARY'),
        backgroundColor: AppColors.summaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Location Dropdown
                Obx(() => LocationDropdown(
                  value: controller.selectedLocation.value,
                  onChanged: (value) {
                    controller.selectedLocation.value = value;
                    controller.updateFilters();
                  },
                  locations: controller.locations,
                )),
                
                // Timeframe Dropdown
                Obx(() => DateDropdown(
                  value: controller.selectedTimeframe.value,
                  onChanged: (value) {
                    controller.selectedTimeframe.value = value;
                    controller.updateFilters();
                  },
                  options: controller.timeframes,
                )),
              ],
            ),
          ),
          
          // Summary Content
          Expanded(
            child: Obx(() => controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => controller.loadSummaryData(),
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Key Stats Cards
                        Row(
                          children: [
                            // Total Bets
                            Expanded(
                              child: _buildStatCard(
                                title: 'Total Bets',
                                value: controller.summaryData['totalBets'].toString(),
                                icon: Icons.confirmation_number,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Total Hits
                            Expanded(
                              child: _buildStatCard(
                                title: 'Total Hits',
                                value: controller.summaryData['totalHits'].toString(),
                                icon: Icons.emoji_events,
                                color: AppColors.hitsColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Financial Stats
                        Row(
                          children: [
                            // Total Amount
                            Expanded(
                              child: _buildStatCard(
                                title: 'Total Amount',
                                value: 'PHP ${NumberFormat('#,###').format(controller.summaryData['totalAmount'])}',
                                icon: Icons.account_balance_wallet,
                                color: AppColors.newBetColor,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Net Profit
                            Expanded(
                              child: _buildStatCard(
                                title: 'Net Profit',
                                value: 'PHP ${NumberFormat('#,###').format(controller.summaryData['netProfit'])}',
                                icon: Icons.trending_up,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Profit Percentage Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
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
                                'Profit Percentage',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              LinearProgressIndicator(
                                value: controller.summaryData['profitPercentage'] / 100,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '${controller.summaryData['profitPercentage']}%',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.success,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ).animate()
                          .fadeIn(duration: 300.ms, delay: 200.ms)
                          .slideY(begin: 0.1, end: 0, duration: 300.ms),
                        const SizedBox(height: 24),
                        
                        // Top Combinations
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
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
                                'Top Combinations',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ...List.generate(
                                controller.summaryData['topCombinations'].length,
                                (index) {
                                  final combo = controller.summaryData['topCombinations'][index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: AppColors.comboColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: Text(
                                              combo['combo'],
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.comboColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${combo['count']} bets',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                'PHP ${NumberFormat('#,###').format(combo['amount'])}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.secondaryText,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Progress indicator
                                        SizedBox(
                                          width: 100,
                                          child: LinearProgressIndicator(
                                            value: combo['count'] / controller.summaryData['topCombinations'][0]['count'],
                                            backgroundColor: Colors.grey.shade200,
                                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.comboColor),
                                            minHeight: 8,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ).animate()
                                    .fadeIn(duration: 300.ms, delay: 300.ms + (index * 50).ms)
                                    .slideX(begin: 0.1, end: 0, duration: 300.ms);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Daily Stats
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
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
                                'Daily Statistics',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ...List.generate(
                                controller.summaryData['dailyStats'].length,
                                (index) {
                                  final stat = controller.summaryData['dailyStats'][index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      children: [
                                        // Date
                                        SizedBox(
                                          width: 100,
                                          child: Text(
                                            DateFormat('MMM dd').format(stat['date']),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        // Bets
                                        Expanded(
                                          child: Text(
                                            '${stat['bets']} bets',
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        // Hits
                                        Expanded(
                                          child: Text(
                                            '${stat['hits']} hits',
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        // Profit
                                        Expanded(
                                          child: Text(
                                            'PHP ${NumberFormat('#,###').format(stat['profit'])}',
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.success,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ).animate()
                                    .fadeIn(duration: 300.ms, delay: 400.ms + (index * 50).ms)
                                    .slideX(begin: 0.1, end: 0, duration: 300.ms);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.more_horiz,
                color: Colors.grey.shade400,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 300.ms, delay: 100.ms)
      .slideY(begin: 0.1, end: 0, duration: 300.ms);
  }
}
