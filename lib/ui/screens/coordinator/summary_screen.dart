import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bettingapp/utils/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:bettingapp/routes/app_routes.dart';
import 'package:bettingapp/ui/screens/coordinator/tally_sheet_screen.dart';

class SummaryController extends GetxController {
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;
  
  // Sample data for tellers
  final RxList<Map<String, dynamic>> tellers = <Map<String, dynamic>>[
    {'name': 'Ma. Theresa', 'sales': 12500, 'hits': 3500, 'profit': 9000},
    {'name': 'Tina', 'sales': 5000, 'hits': 1200, 'profit': 3800},
    {'name': 'John', 'sales': 8700, 'hits': 2300, 'profit': 6400},
    {'name': 'Mike', 'sales': 6800, 'hits': 1800, 'profit': 5000},
    {'name': 'Sarah', 'sales': 9500, 'hits': 2500, 'profit': 7000},
  ].obs;
  
  // Computed properties
  int get totalSales => tellers.fold(0, (sum, teller) => sum + teller['sales'] as int);
  int get totalHits => tellers.fold(0, (sum, teller) => sum + teller['hits'] as int);
  int get totalGross => tellers.fold(0, (sum, teller) => sum + teller['profit'] as int);
  
  List<Map<String, dynamic>> get filteredTellers {
    if (searchQuery.isEmpty) {
      return tellers;
    }
    
    return tellers.where((teller) => 
      teller['name'].toString().toLowerCase().contains(searchQuery.value.toLowerCase())
    ).toList();
  }
  
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }
  
  void viewTellerDetails(Map<String, dynamic> teller) {
    Get.toNamed(AppRoutes.summaryDetail, arguments: teller);
  }
}

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({Key? key}) : super(key: key);
  
  // Helper method to build header cells
  Widget _buildHeaderCell(String text, {required double width}) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
  
  // Helper method to build data cells
  Widget _buildDataCell(String text, {
    required double width,
    required TextStyle style,
    required bool isLastRow,
    bool isFirstColumn = false,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isLastRow ? Colors.transparent : Colors.grey.shade200,
            width: 1,
          ),
        ),
        borderRadius: isLastRow && isFirstColumn
            ? const BorderRadius.only(bottomLeft: Radius.circular(8))
            : null,
      ),
      child: Text(text, style: style),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SummaryController());
    
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Summary Reports'),
        backgroundColor: AppColors.primaryRed,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            margin: const EdgeInsets.all(16),
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
            child: TextField(
              onChanged: controller.updateSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search teller...',
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ).animate()
            .fadeIn(duration: 300.ms)
            .slideY(begin: 0.1, end: 0, duration: 300.ms),
          
          // Summary Cards
           Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Total Sales Card
                Expanded(
                  child: Container(
                    height: 70,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryRed,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Obx(() => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('TOTAL SALES', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                        const SizedBox(height: 4),
                        Text('₱${NumberFormat('#,###').format(controller.totalSales)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    )),
                  ),
                ),
                // Total Hits Card
                Expanded(
                  child: Container(
                    height: 70,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryRed,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Obx(() => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('TOTAL HITS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                        const SizedBox(height: 4),
                        Text('₱${NumberFormat('#,###').format(controller.totalHits)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    )),
                  ),
                ),
                // Total Gross Card
                Expanded(
                  child: Container(
                    height: 70,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade700,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Obx(() => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('TOTAL GROSS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                        const SizedBox(height: 4),
                        Text('₱${NumberFormat('#,###').format(controller.totalGross)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    )),
                  ),
                ),
              ],
            ),
          ).animate()
            .fadeIn(duration: 300.ms, delay: 100.ms)
            .slideY(begin: 0.1, end: 0, duration: 300.ms),
          
          const SizedBox(height: 16),
          
          // Custom table with horizontal scrolling like StatsTable
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                child: Obx(() => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryRed,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                        child: Row(
                          children: [
                            _buildHeaderCell('Teller Name', width: 150),
                            _buildHeaderCell('Total Sales', width: 120),
                            _buildHeaderCell('Total Gross', width: 120),
                            _buildHeaderCell('Actions', width: 220),
                          ],
                        ),
                      ),
                      
                      // Data rows
                      ...controller.filteredTellers.asMap().entries.map((entry) {
                        final index = entry.key;
                        final teller = entry.value;
                        final isLastRow = index == controller.filteredTellers.length - 1;
                        
                        return Container(
                          decoration: BoxDecoration(
                            color: index.isEven ? Colors.grey.shade50 : Colors.white,
                            borderRadius: isLastRow
                                ? const BorderRadius.only(
                                    bottomLeft: Radius.circular(8),
                                    bottomRight: Radius.circular(8),
                                  )
                                : null,
                          ),
                          child: Row(
                            children: [
                              _buildDataCell(
                                teller['name'],
                                width: 150,
                                style: const TextStyle(fontWeight: FontWeight.w500),
                                isLastRow: isLastRow,
                                isFirstColumn: true,
                              ),
                              _buildDataCell(
                                '₱${NumberFormat('#,###').format(teller['sales'])}',
                                width: 120,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                isLastRow: isLastRow,
                              ),
                              _buildDataCell(
                                '₱${NumberFormat('#,###').format(teller['profit'])}',
                                width: 120,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                                isLastRow: isLastRow,
                              ),
                              Container(
                                width: 220,
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: isLastRow ? Colors.transparent : Colors.grey.shade200,
                                      width: 1,
                                    ),
                                  ),
                                  borderRadius: isLastRow
                                      ? const BorderRadius.only(bottomRight: Radius.circular(8))
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () => controller.viewTellerDetails(teller),
                                      icon: const Icon(Icons.visibility, size: 16, color: Colors.red),
                                      label: const Text(
                                        'View',
                                        style: TextStyle(fontSize: 12, color: Colors.red),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: AppColors.primaryRed, width: 1),
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        Get.to(() => TallySheetScreen(
                                          tellerName: teller['name'],
                                          summaryData: {
                                            'gross': '44,870',
                                            'hits': '5,950',
                                            'kabig': '38,920',
                                            'voided': '765',
                                          },
                                          drawData: [
                                            {
                                              'draw': '2S2: 35',
                                              'gross': '11,040',
                                              'hits': '350',
                                              'kabig': '10,690',
                                              'color': Color(0xFFFFD54F),
                                            },
                                            {
                                              'draw': '2S3: 835',
                                              'gross': '5,295',
                                              'hits': '0',
                                              'kabig': '5,295',
                                              'color': Color(0xFFFFD54F),
                                            },
                                            {
                                              'draw': '5S2: 80',
                                              'gross': '7,375',
                                              'hits': '0',
                                              'kabig': '7,375',
                                              'color': Color(0xFFFFD54F),
                                            },
                                            {
                                              'draw': '5S3: 180',
                                              'gross': '2,910',
                                              'hits': '0',
                                              'kabig': '2,910',
                                              'color': Color(0xFFFFD54F),
                                            },
                                            {
                                              'draw': '94D: 9839',
                                              'gross': '2,730',
                                              'hits': '0',
                                              'kabig': '2,730',
                                              'color': Color(0xFFFFD54F),
                                            },
                                            {
                                              'draw': '9L2: 39',
                                              'gross': '10,365',
                                              'hits': '5,600',
                                              'kabig': '4,765',
                                              'color': Color(0xFFFFD54F),
                                            },
                                            {
                                              'draw': '9L3: 839',
                                              'gross': '60',
                                              'hits': '0',
                                              'kabig': '60',
                                              'color': Color(0xFFFFD54F),
                                            },
                                            {
                                              'draw': '9S2: 57',
                                              'gross': '1,950',
                                              'hits': '0',
                                              'kabig': '1,950',
                                              'color': Color(0xFFFFD54F),
                                            },
                                            {
                                              'draw': '9S3: 957',
                                              'gross': '3,145',
                                              'hits': '0',
                                              'kabig': '3,145',
                                              'color': Color(0xFFFFD54F),
                                            },
                                          ],
                                        ));
                                      },
                                      icon: const Icon(Icons.receipt_long, size: 16, color: Colors.orange),
                                      label: const Text(
                                        'Tally Sheet',
                                        style: TextStyle(fontSize: 12, color: Colors.orange),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: Colors.orange.shade700, width: 1),
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ).animate()
                          .fadeIn(duration: 300.ms, delay: (index * 50).ms)
                          .slideY(begin: 0.1, end: 0, duration: 300.ms);
                      }).toList(),
                    ],
                  ),
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
