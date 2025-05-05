import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bettingapp/utils/app_colors.dart';
import 'package:intl/intl.dart';

class TallySheetController extends GetxController {
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  
  // Get formatted date
  String get formattedDate {
    return DateFormat('yyyy-MM-dd').format(selectedDate.value);
  }
  
  // Change date
  void changeDate(DateTime date) {
    selectedDate.value = date;
    // In a real app, you would fetch data for the selected date here
  }
  
  // Sample data for the summary section
  final Map<String, dynamic> summaryData = {
    'gross': '44,870',
    'sales': '5,950',
    'hits': '38,920',
    'voided': '765',
  };
  
  // Sample data for the detailed tally sheet
  final List<Map<String, dynamic>> drawData = [
    {
      'draw': '2S2: 35',
      'gross': '11,040',
      'sales': '350',
      'hits': '10,690',
      'color': Color(0xFFFFD54F),
    },
    {
      'draw': '2S3: 835',
      'gross': '5,295',
      'sales': '0',
      'hits': '5,295',
      'color': Color(0xFFFFD54F),
    },
    {
      'draw': '5S2: 80',
      'gross': '7,375',
      'sales': '0',
      'hits': '7,375',
      'color': Color(0xFFFFD54F),
    },
    {
      'draw': '5S3: 180',
      'gross': '2,910',
      'sales': '0',
      'hits': '2,910',
      'color': Color(0xFFFFD54F),
    },
    {
      'draw': '94D: 9839',
      'gross': '2,730',
      'sales': '0',
      'hits': '2,730',
      'color': Color(0xFFFFD54F),
    },
    {
      'draw': '9L2: 39',
      'gross': '10,365',
      'sales': '5,600',
      'hits': '4,765',
      'color': Color(0xFFFFD54F),
    },
    {
      'draw': '9L3: 839',
      'gross': '60',
      'sales': '0',
      'hits': '60',
      'color': Color(0xFFFFD54F),
    },
    {
      'draw': '9S2: 57',
      'gross': '1,950',
      'sales': '0',
      'hits': '1,950',
      'color': Color(0xFFFFD54F),
    },
    {
      'draw': '9S3: 957',
      'gross': '3,145',
      'sales': '0',
      'hits': '3,145',
      'color': Color(0xFFFFD54F),
    },
  ];
}

class TallySheetScreen extends StatelessWidget {
  const TallySheetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TallySheetController());
    
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('TALLYSHEET'),
        backgroundColor: AppColors.primaryRed,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,color: Colors.white,),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh data
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
      body: Column(
        children: [
          // Date Selector
          Container(
            width: double.infinity,
            color: AppColors.primaryRed,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.white, size: 20),
                const SizedBox(width: 8),
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
                              primary: AppColors.primaryRed,
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
                  child: Obx(() => Text(
                    'Date: ${controller.formattedDate}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  )),
                ),
              ],
            ),
          ),
          
          // Summary Section
          Container(
            width: double.infinity,
            color: AppColors.primaryRed,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                // Summary Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Expanded(
                      child: Text(
                        'GROSS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'SALES',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'HITS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'VOIDED',
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
                
                // Summary Values
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          controller.summaryData['gross'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.primaryRed,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          controller.summaryData['sales'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          controller.summaryData['hits'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.primaryRed,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          controller.summaryData['voided'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Draw Section Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: AppColors.primaryRed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Expanded(
                  flex: 2,
                  child: Text(
                    'DRAW',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'GROSS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'SALES',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'HITS',
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
          
          // Draw Data List
          Expanded(
            child: ListView.builder(
              itemCount: controller.drawData.length,
              itemBuilder: (context, index) {
                final item = controller.drawData[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Draw Number
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                            decoration: BoxDecoration(
                              color: item['color'],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              item['draw'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // Gross
                      Expanded(
                        flex: 1,
                        child: Text(
                          item['gross'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      
                      // Sales
                      Expanded(
                        flex: 1,
                        child: Text(
                          item['sales'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: item['sales'] == '0' ? Colors.grey : Colors.red,
                            fontWeight: item['sales'] == '0' ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
                      ),
                      
                      // Hits
                      Expanded(
                        flex: 1,
                        child: Text(
                          item['hits'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
