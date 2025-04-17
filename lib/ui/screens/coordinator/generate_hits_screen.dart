import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bettingapp/utils/app_colors.dart';
import 'package:intl/intl.dart';

class ViewHitsController extends GetxController {
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxString selectedSchedule = 'All Schedules'.obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool hasResults = true.obs; // Default to true to show sample data
  
  final List<String> schedules = [
    'All Schedules',
    '11AM',
    '2PM',
    '4PM',
    '9PM',
  ];
  
  // Sample data for hits
  final RxList<Map<String, dynamic>> hits = <Map<String, dynamic>>[
    {'winningCombination': '225', 'schedule': '2PM', 'date': '2025-04-17', 'totalBets': 42, 'totalAmount': 8400},
    {'winningCombination': '118', 'schedule': '11AM', 'date': '2025-04-17', 'totalBets': 36, 'totalAmount': 7200},
    {'winningCombination': '345', 'schedule': '4PM', 'date': '2025-04-16', 'totalBets': 28, 'totalAmount': 5600},
    {'winningCombination': '678', 'schedule': '9PM', 'date': '2025-04-16', 'totalBets': 31, 'totalAmount': 6200},
    {'winningCombination': '901', 'schedule': '2PM', 'date': '2025-04-16', 'totalBets': 25, 'totalAmount': 5000},
  ].obs;
  
  List<Map<String, dynamic>> get filteredHits {
    return hits.where((hit) {
      // Filter by date
      final hitDate = DateTime.parse(hit['date']);
      final selectedDateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);
      final hitDateStr = DateFormat('yyyy-MM-dd').format(hitDate);
      
      final matchesDate = hitDateStr == selectedDateStr;
      
      // Filter by schedule
      final matchesSchedule = selectedSchedule.value == 'All Schedules' || 
                             hit['schedule'] == selectedSchedule.value;
      
      // Filter by search query
      final matchesSearch = searchQuery.isEmpty || 
                           hit['winningCombination'].contains(searchQuery.value);
      
      return matchesDate && matchesSchedule && matchesSearch;
    }).toList();
  }
  
  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryRed,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != selectedDate.value) {
      selectedDate.value = picked;
    }
  }
  
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }
  
  void updateSelectedSchedule(String schedule) {
    selectedSchedule.value = schedule;
  }
}

class GenerateHitsScreen extends StatelessWidget {
  const GenerateHitsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ViewHitsController());
    
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('View Generate Hits'),
        backgroundColor: AppColors.primaryRed,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Filter Section
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
                // Info Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primaryRed,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Generating hits is for super admin only. Coordinators can only view hits.',
                          style: TextStyle(
                            color: AppColors.primaryRed,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // First row: Date and Schedule
                Row(
                  children: [
                    // Date Picker
                    Expanded(
                      child: Obx(() => InkWell(
                        onTap: () => controller.selectDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: AppColors.primaryRed,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('MMM dd, yyyy').format(controller.selectedDate.value),
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                    ),
                    const SizedBox(width: 12),
                    
                    // Schedule Dropdown
                    Expanded(
                      child: Obx(() => Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: controller.selectedSchedule.value,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                            elevation: 16,
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                            ),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                controller.updateSelectedSchedule(newValue);
                              }
                            },
                            items: controller.schedules
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      )),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Second row: Search
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: TextField(
                    onChanged: controller.updateSearchQuery,
                    decoration: InputDecoration(
                      hintText: 'Search combination...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey.shade600, size: 20),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ).animate()
            .fadeIn(duration: 300.ms)
            .slideY(begin: 0.1, end: 0, duration: 300.ms),
          
          // Results Table
          Obx(() {
            final filteredHits = controller.filteredHits;
            return Expanded(
              child: filteredHits.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hits found',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                      children: [
                        // Table Header and Body in a single scrollable container
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width: 360, // Set a minimum width that works on most phones
                              child: Column(
                                children: [
                                  // Table Header
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryRed,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        topRight: Radius.circular(8),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 120,
                                          padding: EdgeInsets.only(left: 16),
                                          child: Text(
                                            'Winning',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 80,
                                          child: Text(
                                            'Schedule',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 60,
                                          child: Text(
                                            'Bets',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 100,
                                          padding: EdgeInsets.only(right: 16),
                                          child: Text(
                                            'Amount',
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
                                  
                                  // Table Body
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: filteredHits.length,
                                      itemBuilder: (context, index) {
                                        final hit = filteredHits[index];
                                        return Container(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
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
                                              // Winning Combination
                                              Container(
                                                width: 120,
                                                padding: EdgeInsets.only(left: 16),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 36,
                                                      height: 36,
                                                      decoration: BoxDecoration(
                                                        color: AppColors.primaryRed.withOpacity(0.1),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          hit['winningCombination'],
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 16,
                                                            color: AppColors.primaryRed,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      hit['winningCombination'],
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              
                                              // Schedule
                                              Container(
                                                width: 80,
                                                child: Center(
                                                  child: Container(
                                                    padding: EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.primaryRed.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Text(
                                                      hit['schedule'],
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w500,
                                                        color: AppColors.primaryRed,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              
                                              // Total Bets
                                              Container(
                                                width: 60,
                                                child: Text(
                                                  hit['totalBets'].toString(),
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                              
                                              // Total Amount
                                              Container(
                                                width: 100,
                                                padding: EdgeInsets.only(right: 16),
                                                child: Text(
                                                  '₱${NumberFormat('#,###').format(hit['totalAmount'])}',
                                                  textAlign: TextAlign.right,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ).animate()
                                          .fadeIn(duration: 300.ms, delay: (index * 30).ms)
                                          .slideY(begin: 0.1, end: 0, duration: 300.ms);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
            );
          }),
        ],
      ),
    );
  }
}