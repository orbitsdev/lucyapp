import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bettingapp/utils/app_colors.dart';
import 'package:bettingapp/widgets/stats_table.dart';
import 'package:intl/intl.dart';

class SalesController extends GetxController {
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxString selectedSchedule = 'All'.obs;
  
  // Available schedule options
  final List<String> schedules = ['All', '2 pm', '5 pm', '9 pm'];
  
  // Updated columns for the sales table
  final List<String> columns = ['Gross', 'Sales', 'Bet', 'Hits'];
  
  final List<String> rowLabels = [
    '2 PM',
    '5 PM',
    '9 PM'
  ];
  
  // Updated data: Only 2 PM, 5 PM, 9 PM rows, each with 4 columns
  final List<List<String>> rows = [
    ['1000', '500', '500', '200'],    // 2 PM data
    ['1200', '500', '500', '150'],    // 5 PM data
    ['1100', '500', '500', '150'],    // 9 PM data
  ];
  
  // Get formatted date
  String get formattedDate {
    return DateFormat('MMM dd, yyyy').format(selectedDate.value);
  }
  
  // Change date
  void changeDate(DateTime date) {
    selectedDate.value = date;
    // In a real app, you would fetch data for the selected date here
  }
  
  // Set schedule filter
  void setScheduleFilter(String schedule) {
    selectedSchedule.value = schedule;
    // In a real app, you would filter data based on the selected schedule
  }
  
  // Calculate profit
  int calculateProfit() {
    // In a real app, this would calculate based on actual data
    // For now, using the sample data: Bet - Hits
    int totalBet = 1500;
    int totalHits = 500;
    return totalBet - totalHits;
  }
}

class SalesScreen extends StatelessWidget {
  const SalesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SalesController());
    
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('SALES'),
        backgroundColor: AppColors.primaryRed, // Changed to red color scheme
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Date Picker and Schedule Filter
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
                // Date Picker
                InkWell(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: controller.selectedDate.value,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2025),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: AppColors.primaryRed, // Changed to red color scheme
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      controller.changeDate(picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(() => Text(
                          controller.formattedDate,
                          style: const TextStyle(fontSize: 16),
                        )),
                        const Icon(Icons.calendar_today, size: 20),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Schedule Filter
                Row(
                  children: [
                    const Text(
                      'Schedule Filter:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Obx(() => DropdownButton<String>(
                        value: controller.selectedSchedule.value,
                        isExpanded: true,
                        underline: const SizedBox(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            controller.setScheduleFilter(newValue);
                          }
                        },
                        items: controller.schedules
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      )),
                    ),
                  ],
                ),
              ],
            ),
          ).animate()
            .fadeIn(duration: 300.ms)
            .slideY(begin: 0.1, end: 0, duration: 300.ms),
          
          // Sales Stats Tablep
          Expanded(
            child: SingleChildScrollView(
              child: StatsTable(
                columns: controller.columns,
                rows: controller.rows,
                rowLabels: controller.rowLabels,
                headerColor: AppColors.primaryRed, // Changed to red color scheme
                showTotal: false,
                boldColumns: [0], // Make the "Sales" column header (index 1) bold
                highlightColumns: [0], // Highlight the "Sales" column values (index 1)
              ).animate()
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.1, end: 0, duration: 300.ms),
            ),
          ),
        ],
      ),
    );
  }
}
