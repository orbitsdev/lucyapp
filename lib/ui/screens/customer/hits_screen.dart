import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bettingapp/utils/app_colors.dart';
import 'package:bettingapp/widgets/stats_table.dart';
import 'package:bettingapp/widgets/date_dropdown.dart';

class HitsController extends GetxController {
  final RxString selectedTimeframe = 'This Month'.obs;
  
  final List<String> timeframes = [
    'Today', 
    'Yesterday', 
    'This Week', 
    'This Month'
  ];
  
  // Sample data for the hits table
  final List<String> columns = ['BET', 'HITS', 'TAPAL'];
  
  final List<String> rowLabels = [
    'Davao',
    'Isulan',
    'Tacurong'
  ];
  
  final List<List<String>> rows = [
    ['PHP 221,035', 'PHP 142,425', 'PHP 78,610'],
    ['PHP 221,035', 'PHP 142,425', 'PHP 78,610'],
    ['PHP 221,035', 'PHP 142,425', 'PHP 78,610'],
  ];
}

class HitsScreen extends StatelessWidget {
  const HitsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HitsController());
    
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('HITS'),
        backgroundColor: AppColors.hitsColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Timeframe Dropdown
          Obx(() => DateDropdown(
            value: controller.selectedTimeframe.value,
            onChanged: (value) => controller.selectedTimeframe.value = value,
            options: controller.timeframes,
          )),
          
          // Hits Stats Table
          Expanded(
            child: SingleChildScrollView(
              child: StatsTable(
                columns: controller.columns,
                rows: controller.rows,
                rowLabels: controller.rowLabels,
                headerColor: AppColors.hitsColor,
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
