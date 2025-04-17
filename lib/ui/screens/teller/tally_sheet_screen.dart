import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bettingapp/utils/app_colors.dart';
import 'package:intl/intl.dart';

class TallySheetController extends GetxController {
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxString selectedLocation = 'S2'.obs; // Default to first location
  
  // Available locations
  final List<String> locations = ['S2', 'S3', 'L2', 'L3'];
  
  // Get formatted date
  String get formattedDate {
    return DateFormat('yyyy-MM-dd').format(selectedDate.value);
  }
  
  // Get formatted date with time
  String get formattedDateWithTime {
    return "${DateFormat('yyyy-MM-dd').format(selectedDate.value)} - 2PM";
  }
  
  // Change date
  void changeDate(DateTime date) {
    selectedDate.value = date;
    // In a real app, you would fetch data for the selected date here
  }
  
  // Change location
  void changeLocation(String location) {
    selectedLocation.value = location;
    // In a real app, you would fetch data for the selected location here
  }
  
  // Get the current location's data
  Map<String, dynamic>? get currentLocationData {
    try {
      return tallySheetData.firstWhere(
        (data) => data['location'] == selectedLocation.value
      );
    } catch (e) {
      return null;
    }
  }
  
  // Sample data for the detailed tally sheet
  final List<Map<String, dynamic>> tallySheetData = [
    {
      'location': 'S2',
      'total': '₱12,950.00',
      'betNumbers': [
        {'number': '00', 'amount': 270.00},
        {'number': '01', 'amount': 50.00},
        {'number': '02', 'amount': 185.00},
        {'number': '03', 'amount': 60.00},
        {'number': '04', 'amount': 170.00},
        {'number': '05', 'amount': 325.00},
        {'number': '06', 'amount': 335.00},
        {'number': '07', 'amount': 105.00},
        {'number': '08', 'amount': 225.00},
        {'number': '09', 'amount': 140.00},
        {'number': '10', 'amount': 310.00},
        {'number': '11', 'amount': 275.00},
        {'number': '12', 'amount': 435.00},
        {'number': '13', 'amount': 145.00},
        {'number': '14', 'amount': 220.00},
        {'number': '15', 'amount': 145.00},
        {'number': '16', 'amount': 0.00},
        {'number': '17', 'amount': 705.00},
        {'number': '18', 'amount': 375.00},
        {'number': '19', 'amount': 325.00},
        {'number': '20', 'amount': 390.00},
        {'number': '21', 'amount': 360.00},
        {'number': '22', 'amount': 255.00},
        {'number': '23', 'amount': 315.00},
        {'number': '25', 'amount': 445.00},
        {'number': '26', 'amount': 70.00},
        {'number': '27', 'amount': 0.00},
        {'number': '28', 'amount': 0.00},
        {'number': '29', 'amount': 420.00},
        {'number': '30', 'amount': 0.00},
      ]
    },
    {
      'location': 'S3',
      'total': '₱6,255.00',
      'betNumbers': [
        {'number': '197', 'amount': 10.00},
        {'number': '612', 'amount': 20.00},
        {'number': '613', 'amount': 15.00},
        {'number': '616', 'amount': 5.00},
        {'number': '618', 'amount': 50.00},
        {'number': '011', 'amount': 10.00},
        {'number': '012', 'amount': 20.00},
        {'number': '013', 'amount': 15.00},
        {'number': '032', 'amount': 10.00},
        {'number': '033', 'amount': 15.00},
        {'number': '036', 'amount': 10.00},
        {'number': '038', 'amount': 20.00},
        {'number': '041', 'amount': 5.00},
        {'number': '044', 'amount': 50.00},
        {'number': '050', 'amount': 10.00},
        {'number': '059', 'amount': 15.00},
        {'number': '064', 'amount': 10.00},
        {'number': '080', 'amount': 20.00},
        {'number': '082', 'amount': 5.00},
        {'number': '098', 'amount': 10.00},
      ]
    },
    {
      'location': 'L2',
      'total': '₱8,750.00',
      'betNumbers': [
        {'number': '31', 'amount': 50.00},
        {'number': '32', 'amount': 160.00},
        {'number': '33', 'amount': 150.00},
        {'number': '34', 'amount': 90.00},
        {'number': '35', 'amount': 45.00},
        {'number': '36', 'amount': 40.00},
        {'number': '37', 'amount': 65.00},
        {'number': '38', 'amount': 145.00},
        {'number': '39', 'amount': 35.00},
        {'number': '40', 'amount': 140.00},
      ]
    },
    {
      'location': 'L3',
      'total': '₱7,320.00',
      'betNumbers': [
        {'number': '41', 'amount': 120.00},
        {'number': '42', 'amount': 20.00},
        {'number': '43', 'amount': 55.00},
        {'number': '44', 'amount': 60.00},
        {'number': '45', 'amount': 140.00},
        {'number': '46', 'amount': 25.00},
        {'number': '47', 'amount': 50.00},
        {'number': '48', 'amount': 125.00},
      ]
    }
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
          // Date and Location Picker
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
                              primary: AppColors.tallyColor,
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
                
                // Location Selector
                Row(
                  children: [
                    const Text(
                      'Location:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Obx(() => DropdownButton<String>(
                        value: controller.selectedLocation.value,
                        isExpanded: true,
                        underline: const SizedBox(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            controller.changeLocation(newValue);
                          }
                        },
                        items: controller.locations
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
          
          // Tally Sheet Content
          Expanded(
            child: Obx(() {
              final locationData = controller.currentLocationData;
              
              if (locationData == null) {
                return const Center(
                  child: Text('No data available for this location'),
                );
              }
              
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location Header
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.tallyColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${locationData['location']} TALLY SHEET',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Tally Sheet Title and Total
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tally Sheet - ${controller.formattedDateWithTime}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${locationData['location']} : ${locationData['total']}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Table Header
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.tallyColor.withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Row(
                        children: const [
                          Expanded(
                            flex: 1,
                            child: Text(
                              'Bet #',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'Amount',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'Bet #',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'Amount',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Bet Numbers Table
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _buildBetNumbersTable(locationData['betNumbers']),
                    ),
                  ],
                ),
              ).animate()
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.1, end: 0, duration: 300.ms);
            }),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBetNumbersTable(List<dynamic> betNumbers) {
    // Create pairs of bet numbers for two-column layout
    final List<List<dynamic>> pairs = [];
    
    for (int i = 0; i < betNumbers.length; i += 2) {
      if (i + 1 < betNumbers.length) {
        pairs.add([betNumbers[i], betNumbers[i + 1]]);
      } else {
        pairs.add([betNumbers[i], null]);
      }
    }
    
    return Column(
      children: pairs.map((pair) {
        return Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // First bet number
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          '${pair[0]['number']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          '${pair[0]['amount']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Second bet number (if exists)
              Expanded(
                flex: 2,
                child: pair[1] != null
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text(
                                '${pair[1]['number']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                '${pair[1]['amount']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
