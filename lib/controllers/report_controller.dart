import 'package:get/get.dart';
import 'package:bettingapp/config/api_config.dart';
import 'package:bettingapp/core/dio/dio_base.dart';
import 'package:bettingapp/models/tallysheet_report.dart';
import 'package:bettingapp/models/sales_report.dart';
import 'package:bettingapp/models/draw.dart';
import 'package:bettingapp/widgets/common/modal.dart';

class ReportController extends GetxController {
  static ReportController get to => Get.find<ReportController>();
  
  final DioService _dioService = DioService();
  
  // Observable report data
  final Rx<TallysheetReport?> tallysheetReport = Rx<TallysheetReport?>(null);
  final Rx<SalesReport?> salesReport = Rx<SalesReport?>(null);
  final Rx<List<Draw>> availableDates = Rx<List<Draw>>([]);
  
  // Today's sales data
  final RxString salesFormatted = '₱ 0'.obs;
  final RxString commissionRateFormatted = '0%'.obs;
  final RxString cancellationsFormatted = '0'.obs;
  final RxBool isLoadingTodaySales = false.obs;
  
  // Loading states
  final RxBool isLoadingTallysheet = false.obs;
  final RxBool isLoadingSalesReport = false.obs;
  final RxBool isLoadingAvailableDates = false.obs;
  
  // Filter parameters
  final Rx<String?> selectedDate = Rx<String?>(null);
  final Rx<int?> selectedTellerId = Rx<int?>(null);
  final Rx<int?> selectedLocationId = Rx<int?>(null);
  final Rx<int?> selectedDrawId = Rx<int?>(null);
  
  // Get tallysheet report
  Future<void> fetchTallysheetReport({
    required String date,
    int? tellerId,
    int? locationId,
    int? drawId,
  }) async {
    isLoadingTallysheet.value = true;
    
    try {
      final queryParams = <String, dynamic>{
        'date': date,
      };
      
      if (tellerId != null) queryParams['teller_id'] = tellerId;
      if (locationId != null) queryParams['location_id'] = locationId;
      if (drawId != null) queryParams['draw_id'] = drawId;
      
      final result = await _dioService.authGet<TallysheetReport>(
        ApiConfig.tallySheet,
        queryParameters: queryParams,
        fromJson: (data) {
          if (data is Map && data.containsKey('data')) {
            return TallysheetReport.fromJson(data['data']);
          }
          return TallysheetReport();
        },
      );
      
      result.fold(
        (error) {
          Modal.showErrorModal(
            title: 'Error Loading Tallysheet',
            message: error.message,
          );
        },
        (report) {
          tallysheetReport.value = report;
        },
      );
    } catch (e) {
      Modal.showErrorModal(
        title: 'Error',
        message: 'Failed to load tallysheet report: ${e.toString()}',
      );
    } finally {
      isLoadingTallysheet.value = false;
    }
  }
  
  // Get sales report
  Future<void> fetchSalesReport({
    String? date,
    int? drawId,
  }) async {
    isLoadingSalesReport.value = true;
    
    try {
      final queryParams = <String, dynamic>{};
      
      if (date != null) queryParams['date'] = date;
      if (drawId != null) queryParams['draw_id'] = drawId;
      
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
  
  // Get today's sales report
  Future<void> fetchTodaySalesReport({
    int? drawId,
  }) async {
    // Get today's date in YYYY-MM-DD format
    final today = DateTime.now().toIso8601String().split('T')[0];
    await fetchSalesReport(date: today, drawId: drawId);
  }
  
  // Fetch today's tallysheet report
  Future<void> fetchTodayTallysheetReport() async {
    final today = DateTime.now();
    final formattedDate = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    await fetchTallysheetReport(date: formattedDate);
  }
  
  // Fetch available dates for tallysheet
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
  
  // Reset filters
  void resetFilters() {
    selectedDate.value = null;
    selectedTellerId.value = null;
    selectedLocationId.value = null;
    selectedDrawId.value = null;
  }
  
  // Get commission amount based on sales amount and percentage
  double calculateCommission(double amount, int percentage) {
    return amount * percentage / 100;
  }
  
  // Fetch today's sales data for teller dashboard
  Future<void> fetchTodaySales() async {
    isLoadingTodaySales.value = true;
    
    try {
      final result = await _dioService.authGet(
        ApiConfig.tellerTodaySales,
        fromJson: (data) {
          return data;
        },
      );
      
      result.fold(
        (error) {
          Modal.showErrorModal(
            title: 'Error Loading Today\'s Sales',
            message: error.message,
          );
        },
        (response) {
          if (response is Map && response.containsKey('data')) {
            final data = response['data'];
            salesFormatted.value = data['sales_formatted'] ?? '₱ 0';
            commissionRateFormatted.value = data['commission_rate_formatted'] ?? '0%';
            cancellationsFormatted.value = data['cancellations_formatted'] ?? '0';
          }
        },
      );
    } catch (e) {
      Modal.showErrorModal(
        title: 'Error',
        message: 'Failed to load today\'s sales: ${e.toString()}',
      );
    } finally {
      isLoadingTodaySales.value = false;
    }
  }
}