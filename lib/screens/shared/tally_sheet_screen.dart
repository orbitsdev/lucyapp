import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bettingapp/utils/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:bettingapp/controllers/report_controller.dart';
import 'package:bettingapp/widgets/common/local_lottie_image.dart';

class TallySheetScreen extends StatefulWidget {
  const TallySheetScreen({super.key});

  @override
  State<TallySheetScreen> createState() => _TallySheetScreenState();
}

class _TallySheetScreenState extends State<TallySheetScreen> {
  final ReportController reportController = Get.find<ReportController>();
  
  @override
  void initState() {
    super.initState();
    _loadTallysheetData();
    _loadAvailableDates();
  }
  
  Future<void> _loadAvailableDates() async {
    await reportController.fetchAvailableDates();
  }
  
  // No longer needed as we're using the calendar directly
  
  Future<void> _loadTallysheetData() async {
    await reportController.fetchTodayTallysheetReport();
  }
  
  String getDisplayValue(String? formattedValue, double? rawValue) {
    // If we have a formatted value, use it directly
    if (formattedValue != null && formattedValue.isNotEmpty) {
      return formattedValue;
    }
    
    // If no formatted value, just use the raw value
    return rawValue?.toString() ?? '0';
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('TALLYSHEET'),
        backgroundColor: AppColors.primaryRed,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              _loadTallysheetData();
              Get.snackbar(
                'Refreshing',
                'Updating tallysheet data...',
                backgroundColor: Colors.white,
                colorText: AppColors.primaryRed,
                duration: const Duration(seconds: 1),
              );
            },
          ),
          // IconButton(
          //   icon: const Icon(Icons.calendar_today, color: Colors.white),
          //   onPressed: () async {
          //     final DateTime? picked = await showDatePicker(
          //       context: context,
          //       initialDate: DateTime.now(),
          //       firstDate: DateTime(2020),
          //       lastDate: DateTime(2030),
          //       builder: (context, child) {
          //         return Theme(
          //           data: Theme.of(context).copyWith(
          //             colorScheme: ColorScheme.light(
          //               primary: AppColors.primaryRed,
          //             ),
          //           ),
          //           child: child!,
          //         );
          //       },
          //     );
          //     if (picked != null) {
          //       final date = DateFormat('yyyy-MM-dd').format(picked);
          //       reportController.fetchTallysheetReport(date: date);
          //     }
          //   },
          // ),
        ],
      ),
      body: Obx(() {
        if (reportController.isLoadingTallysheet.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryRed),
            ),
          );
        }
        
        final report = reportController.tallysheetReport.value;
        if (report == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Use Lottie animation for empty state
                LocalLottieImage(
                  path: 'assets/animations/empty_state.json',
                  width: 180,
                  height: 180,
                ),
                const SizedBox(height: 16),
                Text(
                  'No tallysheet data available',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try selecting a different date',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _loadTallysheetData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }
        
        // Use the formatted date from the API response
        final dateStr = report.dateFormatted ?? 'Today';
            
        return RefreshIndicator(
          color: AppColors.primaryRed,
          onRefresh: _loadTallysheetData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            // Date Display
            Container(
              width: double.infinity,
              color: AppColors.primaryRed,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date display row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Date: $dateStr',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  
                  // // Date navigation buttons row
                  // Container(
                  //   margin: const EdgeInsets.only(top: 8),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     mainAxisSize: MainAxisSize.min,
                  //     children: [
                  //       // Previous day button
                  //       IconButton(
                  //         padding: EdgeInsets.zero,
                  //         constraints: const BoxConstraints(),
                  //         icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 16),
                  //         onPressed: () {
                  //           // Get the current date from the report or use today
                  //           DateTime currentDate;
                  //           try {
                  //             // Handle both ISO and simple date formats
                  //             String dateStr = report.date ?? '';
                  //             if (dateStr.contains('T')) {
                  //               dateStr = dateStr.split('T')[0];
                  //             }
                  //             currentDate = DateFormat('yyyy-MM-dd').parse(dateStr);
                  //           } catch (e) {
                  //             currentDate = DateTime.now();
                  //           }
                            
                  //           // Go to previous day
                  //           final previousDay = currentDate.subtract(const Duration(days: 1));
                  //           final date = DateFormat('yyyy-MM-dd').format(previousDay);
                  //           reportController.fetchTallysheetReport(date: date);
                  //         },
                  //       ),
                  //       const SizedBox(width: 16),
                  //       // Next day button (disabled if current date is today)
                  //       IconButton(
                  //         padding: EdgeInsets.zero,
                  //         constraints: const BoxConstraints(),
                  //         icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                  //         onPressed: () {
                  //           // Get the current date from the report or use today
                  //           DateTime currentDate;
                  //           try {
                  //             // Handle both ISO and simple date formats
                  //             String dateStr = report.date ?? '';
                  //             if (dateStr.contains('T')) {
                  //               dateStr = dateStr.split('T')[0];
                  //             }
                  //             currentDate = DateFormat('yyyy-MM-dd').parse(dateStr);
                  //           } catch (e) {
                  //             currentDate = DateTime.now();
                  //           }
                            
                  //           // Check if current date is today
                  //           final today = DateTime.now();
                  //           final isToday = currentDate.year == today.year && 
                  //                           currentDate.month == today.month && 
                  //                           currentDate.day == today.day;
                            
                  //           // Only go to next day if not today
                  //           if (!isToday) {
                  //             final nextDay = currentDate.add(const Duration(days: 1));
                  //             // Don't go beyond today
                  //             if (nextDay.isBefore(today) || 
                  //                 (nextDay.year == today.year && nextDay.month == today.month && nextDay.day == today.day)) {
                  //               final date = DateFormat('yyyy-MM-dd').format(nextDay);
                  //               reportController.fetchTallysheetReport(date: date);
                  //             }
                  //           }
                  //         },
                  //       ),
                  //       const SizedBox(width: 16),
                  //       // Today button - only show if not already on today's date
                  //       Builder(builder: (context) {
                  //         // Get the current date from the report
                  //         DateTime currentDate;
                  //         try {
                  //           // Handle both ISO and simple date formats
                  //           String dateStr = report.date ?? '';
                  //           if (dateStr.contains('T')) {
                  //             dateStr = dateStr.split('T')[0];
                  //           }
                  //           currentDate = DateFormat('yyyy-MM-dd').parse(dateStr);
                  //         } catch (e) {
                  //           currentDate = DateTime.now();
                  //         }
                          
                  //         // Check if current date is today
                  //         final today = DateTime.now();
                  //         final bool isToday = currentDate.year == today.year && 
                  //                         currentDate.month == today.month && 
                  //                         currentDate.day == today.day;
                          
                  //         print('Current date: $currentDate, Today: $today, Is Today: $isToday');
                          
                  //         // Only show the Today button if not already on today's date
                  //         if (isToday) {
                  //           return const SizedBox.shrink();
                  //         }
                          
                  //         return TextButton(
                  //           style: TextButton.styleFrom(
                  //             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  //             backgroundColor: Colors.white.withOpacity(0.2),
                  //             shape: RoundedRectangleBorder(
                  //               borderRadius: BorderRadius.circular(12),
                  //             ),
                  //             minimumSize: Size.zero,
                  //           ),
                  //           onPressed: () {
                  //             reportController.fetchTodayTallysheetReport();
                  //           },
                  //           child: const Text(
                  //             'Today',
                  //             style: TextStyle(
                  //               color: Colors.white,
                  //               fontSize: 12,
                  //               fontWeight: FontWeight.bold,
                  //             ),
                  //           ),
                  //         );
                  //       }),
                  //     ],
                  //   ),
                  // ),
                  
                  // Date selection with calendar button
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(
                        dateStr,
                        style: const TextStyle(fontSize: 14),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: AppColors.primaryRed,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        
                        if (picked != null) {
                          final date = DateFormat('yyyy-MM-dd').format(picked);
                          
                          // Find if there's a matching draw ID for this date
                          final availableDates = reportController.availableDates.value;
                          String? drawId;
                          
                          for (var draw in availableDates) {
                            if (draw.drawDate != null && draw.drawDate!.contains(date)) {
                              drawId = draw.id?.toString();
                              break;
                            }
                          }
                          
                          if (drawId != null) {
                            // If we found a matching draw ID, use it
                            print('Found draw ID $drawId for date $date');
                            reportController.fetchTallysheetReport(drawId: drawId);
                          } else {
                            // Otherwise fall back to using the date
                            print('No draw ID found for date $date, using date directly');
                            reportController.fetchTallysheetReport(date: date);
                          }
                        }
                      },
                    ),
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
                            getDisplayValue(report.grossFormatted, report.gross),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.primaryRed,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            getDisplayValue(report.salesFormatted, report.sales),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            getDisplayValue(report.hitsFormatted, report.hits),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.primaryRed,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            getDisplayValue(report.voidedFormatted, report.voided),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
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
                    flex: 1,
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
            SizedBox(
              height: 300, // Fixed height for the list container
              child: RefreshIndicator(
                color: AppColors.primaryRed,
                onRefresh: _loadTallysheetData,
                child: report.perDraw == null || report.perDraw!.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Use Lottie animation for empty state
                                LocalLottieImage(
                                  path: 'assets/animations/empty_state.json',
                                  width: 120,
                                  height: 120,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No draw data available',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'for ${report.dateFormatted ?? dateStr}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: report.perDraw!.length,
                        itemBuilder: (context, index) {
                          final draw = report.perDraw![index];
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
                                // Draw Label and Winning Number
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                    alignment: Alignment.center,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFD54F),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '${draw.drawTimeFormatted}',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                
                                // Gross
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: Text(
                                      getDisplayValue(draw.grossFormatted, draw.gross),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                
                                // Sales
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    getDisplayValue(draw.salesFormatted, draw.sales),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: (draw.sales ?? 0) > 0 ? Colors.red : Colors.grey,
                                      fontWeight: (draw.sales ?? 0) > 0 ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                
                                // Hits
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    getDisplayValue(draw.hitsFormatted, draw.hits),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
      }),
    );
  }
}
