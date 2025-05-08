import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bettingapp/utils/app_colors.dart';
import 'package:bettingapp/widgets/stats_table.dart';
// import 'package:intl/intl.dart'; // Preserved for future reference
import 'package:bettingapp/controllers/sales_controller.dart';
import 'package:bettingapp/widgets/common/local_lottie_image.dart';
// import 'package:bettingapp/models/draw.dart'; // Preserved for future reference if we switch back to dropdown
// Removed cupertino import as we're using Material date picker


class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final SalesController controller = Get.put(SalesController());
  
  @override
  void initState() {
    super.initState();
    _loadSalesData();
    // _loadAvailableDates(); // Not needed with direct date picker
  }
  
  Future<void> _loadSalesData() async {
    await controller.fetchTodaySalesReport();
  }
  
  // Not needed with direct date picker approach
  // Future<void> _loadAvailableDates() async {
  //   await controller.fetchAvailableDates();
  // }
  
  // Helper method preserved for future reference if we switch back to dropdown
  /*
  String? _findValueInList(DateTime? dateValue, List<dynamic> items) {
    if (dateValue == null || items.isEmpty) return null;
    
    // Format the selected date to match the format in the list
    String normalizedValue = DateFormat('yyyy-MM-dd').format(dateValue);
    
    // Find a matching date in the list and return its ID
    for (var item in items) {
      String itemDate = item.drawDate ?? '';
      if (itemDate.contains('T')) {
        itemDate = itemDate.split('T')[0];
      }
      
      if (itemDate == normalizedValue) {
        return item.id?.toString();
      }
    }
    
    // If no match found, return the first item's ID as fallback
    return items.isNotEmpty ? items.first.id?.toString() : null;
  }
  */

  // Build empty state widget with animation
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LocalLottieImage(
            path: 'assets/animations/empty_state.json',
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 16),
          Text(
            'No sales data available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try selecting a different date',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 300.ms)
      .slideY(begin: 0.1, end: 0, duration: 300.ms);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('SALES'),
        backgroundColor: AppColors.primaryRed, // Changed to red color scheme
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,color: Colors.white,),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              _loadSalesData();
              Get.snackbar(
                'Refreshing',
                'Updating sales data...',
                backgroundColor: Colors.white,
                colorText: AppColors.primaryRed,
                duration: const Duration(seconds: 1),
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingSalesReport.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryRed),
            ),
          );
        }

        return Column(
          children: [
            // Date Picker - Smaller container
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  // Date Picker - Using Material DatePicker with cool calendar icon
                  Obx(() => InkWell(
                    onTap: () async {
                      // Make sure the lastDate is after the current date
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: controller.selectedDate.value,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: AppColors.primaryRed,
                                onPrimary: Colors.white,
                                onSurface: Colors.black,
                              ),
                              dialogBackgroundColor: Colors.white,
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
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            controller.formattedDate,
                            style: const TextStyle(fontSize: 16),
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryRed.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(Icons.calendar_month, color: AppColors.primaryRed, size: 20),
                          ),
                        ],
                      ),
                    ),
                  )),
                  
                  /* Dropdown approach preserved for future reference
                  Obx(() {
                    final availableDates = controller.availableDates;
                    if (availableDates.isEmpty) {
                      return InkWell(
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
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                controller.formattedDate,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const Icon(Icons.calendar_today, size: 20),
                            ],
                          ),
                        ),
                      );
                    }

                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        underline: const SizedBox.shrink(),
                        icon: const Icon(Icons.arrow_drop_down),
                        isExpanded: true,
                        hint: const Text('Select date'),
                        // Use the date ID as the value
                        value: _findValueInList(controller.selectedDate.value, availableDates),
                        items: availableDates.map((date) {
                          // Use the ID as the value to ensure uniqueness
                          final value = date.id?.toString() ?? '';
                          // Create a better combined display string with date and time
                          String displayText;
                          if (date.drawDateFormatted != null && date.drawTimeFormatted != null) {
                            displayText = '${date.drawDateFormatted} ';
                          } else if (date.drawDateFormatted != null) {
                            displayText = date.drawDateFormatted!;
                          } else if (date.drawTimeFormatted != null) {
                            displayText = date.drawTimeFormatted!;
                          } else {
                            displayText = value;
                          }
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(displayText),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            // Find the selected date object to get the full date string
                            final selectedDate = availableDates.firstWhere(
                              (date) => date.id?.toString() == value,
                              orElse: () => Draw(),
                            );

                            if (selectedDate.drawDate != null) {
                              // Parse the date string to DateTime
                              String dateToFetch = selectedDate.drawDate!;
                              if (dateToFetch.contains('T')) {
                                dateToFetch = dateToFetch.split('T')[0];
                              }
                              final parsedDate = DateFormat('yyyy-MM-dd').parse(dateToFetch);
                              controller.changeDate(parsedDate);
                            }
                          }
                        },
                      ),
                    );
                  }),
                  */

                  // Schedule Filter removed as it's redundant with the date filter
                ],
              ),
            ).animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.1, end: 0, duration: 300.ms),

            // Sales Stats Table
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primaryRed,
                onRefresh: () async {
                  await _loadSalesData();
                  Get.snackbar(
                    'Refreshed',
                    'Sales data updated',
                    backgroundColor: Colors.white,
                    colorText: AppColors.primaryRed,
                    duration: const Duration(seconds: 1),
                  );
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: controller.rows.isEmpty
                    ? _buildEmptyState()
                    : StatsTable(
                        columns: controller.columns,
                        rows: controller.rows,
                        rowLabels: controller.rowLabels,
                        headerColor: AppColors.primaryRed, // Changed to red color scheme
                        showTotal: false,
                        boldColumns: [0], // Make the "Sales" column header bold
                        highlightColumns: [0], // Highlight the "Sales" column values
                      ).animate()
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: 0.1, end: 0, duration: 300.ms),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
