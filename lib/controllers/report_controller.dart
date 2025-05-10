import 'package:get/get.dart';
import 'package:bettingapp/config/api_config.dart';
import 'package:bettingapp/core/dio/dio_base.dart';
import 'package:bettingapp/models/tallysheet_report.dart';
import 'package:bettingapp/models/sales_report.dart';
import 'package:bettingapp/models/draw.dart';
import 'package:bettingapp/models/detailed_tallysheet.dart';
import 'package:bettingapp/widgets/common/modal.dart';

class ReportController extends GetxController {
  static ReportController get to => Get.find<ReportController>();
  
  final DioService _dioService = DioService();
  
  // Observable report data
  final Rx<TallysheetReport?> tallysheetReport = Rx<TallysheetReport?>(null);
  final Rx<SalesReport?> salesReport = Rx<SalesReport?>(null);
  final Rx<DetailedTallysheet?> detailedTallysheet = Rx<DetailedTallysheet?>(null);
  final Rx<List<Draw>> availableDates = Rx<List<Draw>>([]);
  
  // Today's sales data
  final RxString salesFormatted = '₱ 0'.obs;
  final RxString commissionRateFormatted = '0%'.obs;
  final RxString cancellationsFormatted = '0'.obs;
  final RxBool isLoadingTodaySales = false.obs;
  
  // Loading states
  final RxBool isLoadingTallysheet = false.obs;
  final RxBool isLoadingSalesReport = false.obs;
  final RxBool isLoadingDetailedTallysheet = false.obs;
  final RxBool isLoadingAvailableDates = false.obs;
  
  // Filter parameters
  final Rx<String?> selectedDate = Rx<String?>(null);
  final Rx<int?> selectedTellerId = Rx<int?>(null);
  final Rx<int?> selectedLocationId = Rx<int?>(null);
  final Rx<int?> selectedDrawId = Rx<int?>(null);
  final Rx<int?> selectedGameTypeId = Rx<int?>(null);
  final RxInt currentPage = 1.obs;
  final RxInt perPage = 50.obs;
  
  // Get tallysheet report
  Future<void> fetchTallysheetReport({
    String? date,
    int? tellerId,
    int? locationId,
    String? drawId,
  }) async {
    isLoadingTallysheet.value = true;
    
    try {
      final queryParams = <String, dynamic>{};
      
      // The API requires a date parameter
      if (date != null) {
        queryParams['date'] = date;
      } else {
        // Default to today if no date is provided
        final today = DateTime.now().toIso8601String().split('T')[0];
        queryParams['date'] = today;
      }
      
      // Add draw_id if provided
      if (drawId != null) {
        queryParams['draw_id'] = drawId;
      }
      
      if (tellerId != null) queryParams['teller_id'] = tellerId;
      if (locationId != null) queryParams['location_id'] = locationId;
      
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
  
  // Fetch detailed tallysheet report
  Future<void> fetchDetailedTallysheet({
    required String date,
    int? gameTypeId,
    int? drawId,
    int page = 1,
    int perPage = 50,
    bool all = false,
  }) async {
    isLoadingDetailedTallysheet.value = true;
    
    try {
      final queryParams = <String, dynamic>{
        'date': date,
        'page': page,
        'per_page': perPage,
      };
      
      if (gameTypeId != null) queryParams['game_type_id'] = gameTypeId;
      if (drawId != null) queryParams['draw_id'] = drawId;
      if (all) queryParams['all'] = true;
      
      final result = await _dioService.authGet<DetailedTallysheet>(
        ApiConfig.detailedTallySheet,
        queryParameters: queryParams,
        fromJson: (data) {
          // Direct parsing from the response without looking for a 'data' key
          if (data is Map<String, dynamic>) {
            return DetailedTallysheet.fromJson(data);
          }
          return DetailedTallysheet();
        },
      );
      
      result.fold(
        (error) {
          Modal.showErrorModal(
            title: 'Error Loading Detailed Tallysheet',
            message: error.message,
          );
        },
        (report) {
          // Always update the tallysheet data, even if there are no bets
          detailedTallysheet.value = report;
          currentPage.value = report.currentPage ?? 1;
        },
      );
    } catch (e) {
      Modal.showErrorModal(
        title: 'Error',
        message: 'Failed to load detailed tallysheet: ${e.toString()}',
      );
    } finally {
      isLoadingDetailedTallysheet.value = false;
    }
  }
  
  // Fetch today's detailed tallysheet report
  Future<void> fetchTodayDetailedTallysheet({
    int? gameTypeId,
    int? drawId,
  }) async {
    // Use proper date formatting with intl package
    final today = DateTime.now();
    final formattedDate = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    // Clear any existing draw ID to avoid conflicts
    selectedDrawId.value = null;
    
    await fetchDetailedTallysheet(
      date: formattedDate,
      gameTypeId: gameTypeId,
      // Don't pass drawId here to avoid conflicts with date parameter
      page: 1, // Always start with page 1 for a new date
      perPage: perPage.value,
    );
  }
  
  // Load more detailed tallysheet data (pagination)
  Future<void> loadMoreDetailedTallysheet() async {
    if (isLoadingDetailedTallysheet.value) return;
    if (detailedTallysheet.value == null) return;
    
    final nextPage = (detailedTallysheet.value?.currentPage ?? 0) + 1;
    final totalItems = detailedTallysheet.value?.total ?? 0;
    final itemsPerPage = perPage.value;
    
    // Check if we've reached the end
    if ((nextPage - 1) * itemsPerPage >= totalItems) return;
    
    // Get the current date from the report
    final date = detailedTallysheet.value?.date ?? DateTime.now().toString().split(' ')[0];
    
    await fetchDetailedTallysheet(
      date: date,
      gameTypeId: selectedGameTypeId.value,
      // Don't pass drawId to avoid conflicts with date parameter
      page: nextPage,
      perPage: perPage.value,
    );
  }
}