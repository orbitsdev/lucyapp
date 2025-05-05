import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bettingapp/utils/app_colors.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class CombinationController extends GetxController {
  final RxString selectedFilter = 'Top 10'.obs;
  final RxList<Map<String, dynamic>> combinations = <Map<String, dynamic>>[].obs;
  
  final List<String> filters = [
    'Top 10',
    'Top 20',
    'Top 50',
    'All'
  ];
  
  @override
  void onInit() {
    super.onInit();
    // Load sample combinations
    loadCombinations();
  }
  
  void loadCombinations() {
    // Sample combinations data
    combinations.value = List.generate(
      20,
      (index) => {
        'id': 'combo${index + 1}',
        'schedule': index % 4 == 0
            ? '11AM'
            : index % 4 == 1
                ? '3P'
                : index % 4 == 2
                    ? '4PM'
                    : '9PM',
        'combination': '${(index * 123) % 1000}'.padLeft(3, '0'),
        'amount': (index + 1) * 50,
        // Add a random height factor for staggered grid
        'popularity': index % 3 == 0 ? 'High' : index % 3 == 1 ? 'Medium' : 'Low',
      },
    );
  }
  
  void filterCombinations(String filter) {
    selectedFilter.value = filter;
    
    // In a real app, we would filter the combinations based on the selected filter
    // For this demo, we'll just simulate it by limiting the number of items
    loadCombinations();
    
    if (filter == 'Top 10') {
      combinations.value = combinations.take(10).toList();
    } else if (filter == 'Top 20') {
      combinations.value = combinations.take(20).toList();
    } else if (filter == 'Top 50') {
      // We only have 20 sample items, so no change needed
    }
  }
}

class CombinationScreen extends StatelessWidget {
  const CombinationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CombinationController());
    
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('COMBINATION'),
        backgroundColor: const Color(0xFF004D40), // Match teller dashboard color
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Filter Dropdown
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
            child: Obx(() => DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: controller.selectedFilter.value,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down),
                iconSize: 24,
                elevation: 16,
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 16,
                ),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    controller.filterCombinations(newValue);
                  }
                },
                items: controller.filters
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            )),
          ),
          
          // Combinations Staggered Grid
          Expanded(
            child: Obx(() => MasonryGridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              itemCount: controller.combinations.length,
              itemBuilder: (context, index) {
                final combo = controller.combinations[index];
                // Get color based on popularity
                Color cardColor;
                if (combo['popularity'] == 'High') {
                  cardColor = const Color(0xFF004D40);
                } else if (combo['popularity'] == 'Medium') {
                  cardColor = const Color(0xFF00796B);
                } else {
                  cardColor = const Color(0xFF009688);
                }
                
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          cardColor,
                          cardColor.withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Schedule
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            combo['schedule'],
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Combination
                        Text(
                          combo['combination'],
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Popularity
                        Row(
                          children: [
                            Icon(
                              combo['popularity'] == 'High' 
                                ? Icons.trending_up 
                                : combo['popularity'] == 'Medium' 
                                  ? Icons.trending_flat 
                                  : Icons.trending_down,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              combo['popularity'],
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Amount
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Amount:',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              '₱ ${combo['amount']}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ).animate()
                  .fadeIn(duration: 300.ms, delay: (index * 30).ms)
                  .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), duration: 300.ms);
              },
            )),
          ),
        ],
      ),
    );
  }
}
