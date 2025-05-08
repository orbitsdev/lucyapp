import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bettingapp/utils/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:bettingapp/controllers/report_controller.dart';

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
  }
  
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
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
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
                final date = DateFormat('yyyy-MM-dd').format(picked);
                reportController.fetchTallysheetReport(date: date);
              }
            },
          ),
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
                Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No tallysheet data available',
                  style: TextStyle(
                    fontSize: 16,
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
            
        return Column(
          children: [
            // Date Display
            Container(
              width: double.infinity,
              color: AppColors.primaryRed,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
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
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primaryRed,
                onRefresh: _loadTallysheetData,
                child: report.perDraw == null || report.perDraw!.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                          Center(
                            child: Text(
                              'No draw data available',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
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
        );
      }),
    );
  }
}
