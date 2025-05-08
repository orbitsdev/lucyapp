import 'package:get/get.dart';
import 'package:bettingapp/config/api_config.dart';
import 'package:bettingapp/core/dio/dio_base.dart';
import 'package:bettingapp/models/sales_report.dart';
import 'package:bettingapp/models/draw.dart';
import 'package:bettingapp/widgets/common/modal.dart';
import 'package:intl/intl.dart';

class SalesController extends GetxController {
  static SalesController get to => Get.find<SalesController>();
  
  final DioService _dioService = DioService();
  
  // Observable report data
  final Rx<SalesReport?> salesReport = Rx<SalesReport?>(null);
  final RxList<Draw> availableDates = <Draw>[].obs;
  
  // Loading states
  final RxBool isLoadingSalesReport = false.obs;
  final RxBool isLoadingAvailableDates = false.obs;
  
  // Filter parameters
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  
  // Table data
  final RxList<String> columns = <String>['Gross', 'Sales', 'Bet', 'Hits'].obs;
  final RxList<String> rowLabels = <String>[].obs;
  final RxList<List<String>> rows = <List<String>>[].obs;
  
  // Getters
  String get formattedDate => DateFormat('MMMM dd, yyyy').format(selectedDate.value);
  
  // Change date and fetch report
  void changeDate(DateTime date) {
    selectedDate.value = date;
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    fetchSalesReport(date: formattedDate);
  }
  
  // Schedule filter removed as it's redundant with date filter
  
  // Fetch sales report
  Future<void> fetchSalesReport({
    required String date,
    int? drawId,
  }) async {
    isLoadingSalesReport.value = true;
    
    try {
      final queryParams = {
        'date': date,
      };
      
      if (drawId != null) queryParams['draw_id'] = drawId.toString();
      
      final result = await _dioService.authGet<SalesReport>(
        ApiConfig.salesReport,
        queryParameters: queryParams,
        fromJson: (data) {
          if (data is Map && data.containsKey('data')) {
            return SalesReport.fromJson(data['data']);
          }
          return SalesReport();
        },
      );
      
      result.fold(
        (error) {
          Modal.showErrorModal(
            title: 'Error Loading Sales Report',
            message: error.message,
          );
        },
        (report) {
          salesReport.value = report;
          updateTableData(report);
        },
      );
    } catch (e) {
      Modal.showErrorModal(
        title: 'Error',
        message: 'Failed to load sales report: ${e.toString()}',
      );
    } finally {
      isLoadingSalesReport.value = false;
    }
  }
  
  // Fetch today's sales report
  Future<void> fetchTodaySalesReport({
    int? drawId,
  }) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    await fetchSalesReport(date: today, drawId: drawId);
  }
  
  // Fetch available dates
  Future<void> fetchAvailableDates() async {
    isLoadingAvailableDates.value = true;
    
    try {
      final result = await _dioService.authGet<List<Draw>>(
        ApiConfig.availableDates,
        fromJson: (data) {
          if (data is Map && data.containsKey('data') && data['data'] is Map) {
            // Check for both possible field names in the API response
            final String fieldName = data['data'].containsKey('available_draws') 
                ? 'available_draws' 
                : (data['data'].containsKey('available_dates') ? 'available_dates' : '');
            
            if (fieldName.isNotEmpty) {
              final List<dynamic> datesList = data['data'][fieldName];
              return datesList.map((item) => Draw.fromJson(item)).toList();
            }
          }
          return <Draw>[];
        },
      );
      
      result.fold(
        (error) {
          Modal.showErrorModal(
            title: 'Error Loading Available Dates',
            message: error.message,
          );
        },
        (dates) {
          availableDates.value = dates;
        },
      );
    } catch (e) {
      Modal.showErrorModal(
        title: 'Error',
        message: 'Failed to load available dates: ${e.toString()}',
      );
      availableDates.value = [];
    } finally {
      isLoadingAvailableDates.value = false;
    }
  }
  
  // Update table data from sales report
  void updateTableData(SalesReport report) {
    if (report.draws == null || report.draws!.isEmpty) {
      rows.value = [];
      rowLabels.value = [];
      return;
    }
    
    final newRows = <List<String>>[];
    final newRowLabels = <String>[];
    for (final draw in report.draws!) {
      // Use the time formatted field if available, otherwise use the time field
      final timeLabel = draw.timeFormatted ?? draw.time ?? 'Unknown';
      newRowLabels.add(timeLabel);
      
      // Format values for display with thousand separators
      String formatTotal(dynamic value) {
        if (value == null) return '0';
        
        // If it's a string with commas, convert to number
        if (value is String) {
          if (value.contains(',')) {
            try {
              value = double.parse(value.replaceAll(',', ''));
            } catch (e) {
              return value; // Return original if parsing fails
            }
          } else {
            try {
              value = double.parse(value);
            } catch (e) {
              return value; // Return original if parsing fails
            }
          }
        }
        
        // Now value should be a number (double or int)
        if (value is num) {
          // Convert to integer if it's a whole number
          final intValue = (value == value.toInt()) ? value.toInt() : value;
          
          // Format with thousand separators
          final formatter = NumberFormat('#,###');
          if (intValue >= 1000) {
            return formatter.format(intValue);
          } else {
            // For smaller numbers, just convert to string without commas
            return intValue.toString();
          }
        }
        
        return value.toString();
      }
      
      // Use the numeric values directly when available, otherwise use formatted values
      newRows.add([
        formatTotal(draw.gross ?? draw.grossFormatted),
        formatTotal(draw.sales ?? draw.salesFormatted),
        formatTotal(draw.sales ?? draw.salesFormatted), // Same as sales for the "Bet" column
        formatTotal(draw.hits ?? draw.hitsFormatted),
      ]);
    }
    
    // Schedule filter removed
    
    rowLabels.value = newRowLabels;
    rows.value = newRows;
  }
}
