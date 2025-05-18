import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bettingapp/utils/app_colors.dart';
import 'package:bettingapp/controllers/report_controller.dart';
import 'package:bettingapp/widgets/common/local_lottie_image.dart';

class CommissionScreen extends StatefulWidget {
  const CommissionScreen({super.key});

  @override
  State<CommissionScreen> createState() => _CommissionScreenState();
}

class _CommissionScreenState extends State<CommissionScreen> {
  final ReportController reportController = Get.find<ReportController>();
  final RxString selectedDateFormatted = ''.obs;
  final RxString selectedDateApiFormat = ''.obs;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    selectedDateFormatted.value = _displayDateFormat(today);
    selectedDateApiFormat.value = _apiDateFormat(today);
  }

  String _displayDateFormat(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  String _apiDateFormat(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Commission'),
        backgroundColor: AppColors.primaryRed,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final isLoading = reportController.isLoadingCommissionReport.value;
        final commission = reportController.commissionReport.value;
        return RefreshIndicator(
          onRefresh: () async {
            final today = DateTime.now();
            final formattedDate = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
            await reportController.fetchCommissionReport(date: formattedDate);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : commission == null
                      ? Center(
                          child: Obx(() => Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Date selector
                                  GestureDetector(
                                    onTap: () async {
                                      final DateTime? picked = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.tryParse(selectedDateApiFormat.value) ?? DateTime.now(),
                                        firstDate: DateTime(2020),
                                        lastDate: DateTime(2030),
                                        builder: (context, child) {
                                          return Theme(
                                            data: Theme.of(context).copyWith(
                                              colorScheme: const ColorScheme.light(primary: AppColors.primaryRed),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );
                                      if (picked != null) {
                                        selectedDateFormatted.value = _displayDateFormat(picked);
                                        selectedDateApiFormat.value = _apiDateFormat(picked);
                                        reportController.isLoadingCommissionReport.value = true;
                                        await reportController.fetchCommissionReport(date: selectedDateApiFormat.value);
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.calendar_today, color: Colors.grey, size: 18),
                                          const SizedBox(width: 8),
                                          Text(
                                            selectedDateFormatted.value,
                                            style: const TextStyle(
                                              color: Colors.black87,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  LocalLottieImage(
                                    path: 'assets/animations/empty_state.json',
                                    width: 180,
                                    height: 180,
                                    repeat: true,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No commission data available',
                                    style: TextStyle(fontSize: 16, color: Colors.grey),
                                  ),
                                ],
                              )),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Commission Information Card
                            Card(
                              color: Colors.white,
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.info_outline, color: AppColors.primaryRed, size: 32),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: const [
                                          Text('Commission Information',
                                              style: TextStyle(
                                                color: AppColors.primaryRed,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              )),
                                          SizedBox(height: 6),
                                          Text(
                                            'This function allows tellers to view their commission percentage set by the coordinator. The system automatically computes a 10% commission on your total sales.',
                                            style: TextStyle(fontSize: 15, color: Colors.black87),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // 2. Select Date Card
                            Card(
                              color: Colors.white,
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 1,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Select Date',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                        )),
                                    const SizedBox(height: 12),
                                    GestureDetector(
                                      onTap: () async {
                                        final DateTime? picked = await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.tryParse(selectedDateApiFormat.value) ?? DateTime.now(),
                                          firstDate: DateTime(2020),
                                          lastDate: DateTime(2030),
                                          builder: (context, child) {
                                            return Theme(
                                              data: Theme.of(context).copyWith(
                                                colorScheme: const ColorScheme.light(primary: AppColors.primaryRed),
                                              ),
                                              child: child!,
                                            );
                                          },
                                        );
                                        if (picked != null) {
                                          selectedDateFormatted.value = _displayDateFormat(picked);
                                          selectedDateApiFormat.value = _apiDateFormat(picked);
                                          reportController.isLoadingCommissionReport.value = true;
                                          await reportController.fetchCommissionReport(date: selectedDateApiFormat.value);
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey.shade300, width: 1.5),
                                          borderRadius: BorderRadius.circular(8),
                                          color: Colors.grey.shade50,
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            const Icon(Icons.calendar_today, color: AppColors.primaryRed, size: 22),
                                            const SizedBox(width: 10),
                                            Obx(() => Text(
                                                  selectedDateFormatted.value,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 16,
                                                  ),
                                                )),
                                            const Spacer(),
                                            const Icon(Icons.arrow_drop_down, color: Colors.black45, size: 26),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // 3. Commission Details Card
                            Card(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 1,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Commission Details',
                                        style: TextStyle(
                                          color: AppColors.primaryRed,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        )),
                                    const SizedBox(height: 16),
                                    _detailsRow('Commission Percentage standard:', '${commission.commissionRateFormatted ?? (commission.commissionRate != null ? commission.commissionRate!.toStringAsFixed(0) + '%' : '-')}', boldRight: false),
                                    _detailsRow('Total Commission Percentage:', '${commission.commissionRateFormatted ?? (commission.commissionRate != null ? commission.commissionRate!.toStringAsFixed(0) + '%' : '-')}', boldRight: true),
                                    const SizedBox(height: 18),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Total Commission Amount:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        Text(
                                          commission.commissionAmountFormatted ?? (commission.commissionAmount != null ? '₱' + commission.commissionAmount!.toStringAsFixed(2) : '-'),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryRed,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
            ),
          ),
        );
      }
      )
    );
  }

  /// Helper for commission details row
  Widget _detailsRow(String label, String value, {bool boldRight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15)),
          Text(
            value,
            style: TextStyle(
              fontWeight: boldRight ? FontWeight.bold : FontWeight.normal,
              fontSize: 15,
              color: boldRight ? AppColors.primaryRed : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

