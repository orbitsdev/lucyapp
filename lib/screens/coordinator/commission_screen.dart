import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bettingapp/utils/app_colors.dart';
import 'package:intl/intl.dart';

class CoordinatorCommissionController extends GetxController {
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxBool isLoading = false.obs;
  
  // Commission data
  final RxDouble commissionPercentage = 15.0.obs;
  final RxDouble commissionPerCashier = 5.0.obs;
  final RxDouble totalCommissionPercentage = 20.0.obs;
  final RxDouble totalCommissionAmount = 25000.0.obs;
  
  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryRed,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != selectedDate.value) {
      selectedDate.value = picked;
      // In a real app, you would fetch commission data for the selected date
      fetchCommissionData();
    }
  }
  
  Future<void> fetchCommissionData() async {
    isLoading.value = true;
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // In a real app, this would fetch data from a backend
    // For now, we'll just use the sample data
    
    isLoading.value = false;
  }
  
  @override
  void onInit() {
    super.onInit();
    fetchCommissionData();
  }
}

class CommissionScreen extends StatelessWidget {
  const CommissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CoordinatorCommissionController());
    
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Commission'),
        backgroundColor: AppColors.primaryRed,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Commission Information Card
              Container(
                padding: const EdgeInsets.all(20),
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
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.primaryRed,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Commission Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryRed,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'This function allows coordinators to view the commission percentage set by the super admin. The system automatically computes a 15% commission whenever each draw is assigned to a coordinator.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Note: Kindly add also this function to teller',
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ).animate()
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.1, end: 0, duration: 300.ms),
              
              const SizedBox(height: 24),
              
              // Date Picker
              Container(
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
                    const Text(
                      'Select Date',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () => controller.selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: AppColors.primaryRed,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Obx(() => Text(
                              DateFormat('MMMM dd, yyyy').format(controller.selectedDate.value),
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            )),
                            const Spacer(),
                            Icon(
                              Icons.arrow_drop_down,
                              color: Colors.grey.shade600,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate()
                .fadeIn(duration: 300.ms, delay: 100.ms)
                .slideY(begin: 0.1, end: 0, duration: 300.ms),
              
              const SizedBox(height: 24),
              
              // Commission Details
              Container(
                padding: const EdgeInsets.all(20),
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
                    Text(
                      'Commission Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryRed,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildCommissionRow(
                      'Commission Percentage standard:',
                      '${controller.commissionPercentage.value.toStringAsFixed(0)}%',
                    ),
                    const SizedBox(height: 12),
                    _buildCommissionRow(
                      'Commission Each vs Cashier:',
                      '${controller.commissionPerCashier.value.toStringAsFixed(0)}%',
                    ),
                    const SizedBox(height: 12),
                    _buildCommissionRow(
                      'Total Commission Percentage:',
                      '${controller.totalCommissionPercentage.value.toStringAsFixed(0)}%',
                      isTotal: true,
                    ),
                    const SizedBox(height: 16),
                    Divider(color: Colors.grey.shade200),
                    const SizedBox(height: 16),
                    _buildCommissionRow(
                      'Total Commission Amount:',
                      '₱${NumberFormat('#,##0.00').format(controller.totalCommissionAmount.value)}',
                      isTotal: true,
                      isAmount: true,
                    ),
                  ],
                ),
              ).animate()
                .fadeIn(duration: 300.ms, delay: 200.ms)
                .slideY(begin: 0.1, end: 0, duration: 300.ms),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCommissionRow(String label, String value, {bool isTotal = false, bool isAmount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isAmount ? AppColors.primaryRed : Colors.black87,
          ),
        ),
      ],
    );
  }
}
