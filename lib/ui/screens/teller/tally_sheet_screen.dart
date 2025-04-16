import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bettingapp/utils/app_colors.dart';
import 'package:bettingapp/widgets/stats_table.dart';
import 'package:bettingapp/widgets/location_dropdown.dart';
import 'package:bettingapp/widgets/date_dropdown.dart';

class TallySheetController extends GetxController {
  final RxString selectedLocation = 'All Locations'.obs;
  final RxString selectedTimeframe = 'THIS MONTH'.obs;
  
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
    'TODAY',
    'YESTERDAY',
    'THIS WEEK',
    'THIS MONTH',
    'CUSTOM'
  ];
  
  // Sample data for the tally sheet table
  final List<String> columns = ['BET', 'HITS', 'TAPAL'];
  
  final List<String> rowLabels = [
    'TOTAL',
    'S2',
    'S3',
    'L2',
    'L3',
    '4D',
    'P3'
  ];
  
  final List<List<String>> rows = [
    ['PHP 348,903', 'PHP 348,903', 'PHP 348,903'],
    ['PHP 348,903', 'PHP 348,903', 'PHP 348,903'],
    ['PHP 348,903', 'PHP 348,903', 'PHP 348,903'],
    ['PHP 348,903', 'PHP 348,903', 'PHP 348,903'],
    ['PHP 348,903', 'PHP 348,903', 'PHP 348,903'],
    ['PHP 348,903', 'PHP 348,903', 'PHP 348,903'],
    ['PHP 348,903', 'PHP 348,903', 'PHP 348,903'],
  ];
}

class TallySheetScreen extends StatelessWidget {
  const TallySheetScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TallySheetController());
    
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('TALLY SHEETS'),
        backgroundColor: AppColors.tallyColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Filters Section
          Obx(() => Column(
            children: [
              // Location Dropdown
              LocationDropdown(
                value: controller.selectedLocation.value,
                onChanged: (value) => controller.selectedLocation.value = value,
                locations: controller.locations,
                label: 'SELECT LOCATION',
              ),
              
              // Timeframe Dropdown
              DateDropdown(
                value: controller.selectedTimeframe.value,
                onChanged: (value) => controller.selectedTimeframe.value = value,
                options: controller.timeframes,
                label: 'SELECT DATE RANGE',
              ),
            ],
          )),
          
          // Section Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                controller.selectedTimeframe.value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
            ),
          ),
          
          // Tally Sheet Table
          Expanded(
            child: SingleChildScrollView(
              child: StatsTable(
                columns: controller.columns,
                rows: controller.rows,
                rowLabels: controller.rowLabels,
                headerColor: AppColors.tallyColor,
                showTotal: false, // Total is already included in the data
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
