import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bettingapp/utils/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:bettingapp/routes/app_routes.dart';

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
                    height: 100,
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
                        const Text(
                          'TOTAL SALES',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₱${NumberFormat('#,###').format(controller.totalSales)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    )),
                  ),
                ),
                const SizedBox(width: 16),
                // Total Hits Card
                Expanded(
                  child: Container(
                    height: 100,
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
                        const Text(
                          'TOTAL HITS',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₱${NumberFormat('#,###').format(controller.totalHits)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
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
          
          // Teller List Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.grey.shade200,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Teller Name',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Total Sales',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                const Expanded(
                  flex: 1,
                  child: SizedBox(),
                ),
              ],
            ),
          ),
          
          // Teller List
          Expanded(
            child: Obx(() => ListView.builder(
              itemCount: controller.filteredTellers.length,
              itemBuilder: (context, index) {
                final teller = controller.filteredTellers[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.shade200,
                      ),
                    ),
                  ),
                  child: ListTile(
                    title: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            teller['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '₱${NumberFormat('#,###').format(teller['sales'])}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            onPressed: () => controller.viewTellerDetails(teller),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryRed,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child: const Text(
                              'View',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate()
                  .fadeIn(duration: 300.ms, delay: (index * 50).ms)
                  .slideY(begin: 0.1, end: 0, duration: 300.ms);
              },
            )),
          ),
        ],
      ),
    );
  }
}
