import 'package:get/get.dart';
import 'package:bettingapp/config/api_config.dart';
import 'package:bettingapp/core/dio/dio_base.dart';
import 'package:bettingapp/models/tallysheet_report.dart';
import 'package:bettingapp/widgets/common/modal.dart';
import 'package:intl/intl.dart';

class TallySheetController extends GetxController {
  static TallySheetController get to => Get.find<TallySheetController>();
  
  final DioService _dioService = DioService();
  
  // Observable report data
  final Rx<TallysheetReport?> tallysheetReport = Rx<TallysheetReport?>(null);
  
  // Loading state
  final RxBool isLoading = false.obs;
  
  // Selected date
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  
  // Formatted date for display
  String get formattedDate => DateFormat('MMM dd, yyyy').format(selectedDate.value);
  
  @override
  void onInit() {
    super.onInit();
    fetchTallysheetReport();
  }
  
  // Change selected date and fetch new report
  void changeDate(DateTime date) {
    selectedDate.value = date;
    fetchTallysheetReport();
  }
  
  // Get tallysheet report for the selected date
  Future<void> fetchTallysheetReport() async {
    isLoading.value = true;
    
    try {
      final queryParams = <String, dynamic>{
        'date': DateFormat('yyyy-MM-dd').format(selectedDate.value),
      };
      
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
      isLoading.value = false;
    }
  }
}
