import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bettingapp/utils/app_colors.dart';
import 'package:bettingapp/widgets/stats_table.dart';

class SalesController extends GetxController {
  final RxString selectedTimeframe = 'Today'.obs;
  
  final List<String> timeframes = [
    'Today', 
    'Yesterday', 
    'This Week', 
    'This Month'
  ];
  
  // Sample data for the sales table
  final List<String> columns = ['BET', 'HITS'];
  
  final List<String> rowLabels = [
    'GRAND TOTAL',
    '11AM',
    '3P',
    '4PM',
    '9PM',
    'x40x'
  ];
  
  final List<List<String>> rows = [
    ['PHP 343,400', 'PHP 155,550'],
    ['PHP 221,035', 'PHP 142,425'],
    ['PHP 221,035', 'PHP 142,425'],
    ['PHP 221,035', 'PHP 142,425'],
    ['PHP 221,035', 'PHP 142,425'],
    ['PHP 221,035', 'PHP 142,425'],
  ];
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
        backgroundColor: AppColors.salesColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Timeframe Dropdown
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
                value: controller.selectedTimeframe.value,
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
                    controller.selectedTimeframe.value = newValue;
                  }
                },
                items: controller.timeframes
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            )),
          ),
          
          // Sales Stats Table
          Expanded(
            child: SingleChildScrollView(
              child: StatsTable(
                columns: controller.columns,
                rows: controller.rows,
                rowLabels: controller.rowLabels,
                headerColor: AppColors.salesColor,
                showTotal: false, // Grand total is already included in the data
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
