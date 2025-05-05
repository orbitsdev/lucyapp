import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bettingapp/utils/app_colors.dart';
import 'package:intl/intl.dart';

class TellerSalesController extends GetxController {
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxBool isLoading = false.obs;
  final RxList<Map<String, dynamic>> salesData = <Map<String, dynamic>>[].obs;
  final RxDouble totalSales = 0.0.obs;
  
  @override
  void onInit() {
    super.onInit();
    fetchSalesData();
  }
  
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
      fetchSalesData();
    }
  }
  
  Future<void> fetchSalesData() async {
    isLoading.value = true;
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Sample data
    salesData.value = [
      {
        'time': '2 pm',
        'betNumber': '123',
        'amount': 50.0,
        'timestamp': '${DateFormat('MMM dd, yyyy').format(selectedDate.value)} 11:23 AM',
      },
      {
        'time': '2 pm',
        'betNumber': '456',
        'amount': 100.0,
        'timestamp': '${DateFormat('MMM dd, yyyy').format(selectedDate.value)} 11:45 AM',
      },
      {
        'time': '5 pm',
        'betNumber': '789',
        'amount': 200.0,
        'timestamp': '${DateFormat('MMM dd, yyyy').format(selectedDate.value)} 12:15 PM',
      },
      {
        'time': '5 pm',
        'betNumber': '234',
        'amount': 50.0,
        'timestamp': '${DateFormat('MMM dd, yyyy').format(selectedDate.value)} 01:30 PM',
      },
      {
        'time': '9 pm',
        'betNumber': '567',
        'amount': 100.0,
        'timestamp': '${DateFormat('MMM dd, yyyy').format(selectedDate.value)} 02:45 PM',
      },
    ];
    
    // Calculate total sales
    totalSales.value = salesData.fold(0, (sum, item) => sum + (item['amount'] as double));
    
    isLoading.value = false;
  }
}

class TellerSalesScreen extends StatelessWidget {
  const TellerSalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TellerSalesController());
    
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('SALES'),
        backgroundColor: AppColors.primaryRed,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Date Selector
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Obx(() => Text(
                    'Sales for ${DateFormat('MMMM dd, yyyy').format(controller.selectedDate.value)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
                ),
                ElevatedButton.icon(
                  onPressed: () => controller.selectDate(context),
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: const Text('Change Date'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Total Sales Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryRed,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.attach_money,
                  color: Colors.white,
                  size: 40,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Sales',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    Obx(() => Text(
                      '₱${NumberFormat('#,##0.00').format(controller.totalSales.value)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                  ],
                ),
              ],
            ),
          ).animate()
            .fadeIn(duration: 300.ms)
            .slideY(begin: 0.1, end: 0, duration: 300.ms),
          
          // Sales List
          Expanded(
            child: Obx(() => controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : controller.salesData.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No sales data for this date',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: controller.salesData.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final sale = controller.salesData[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
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
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primaryRed.withOpacity(0.1),
                            child: Text(
                              sale['time'],
                              style: TextStyle(
                                color: AppColors.primaryRed,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          title: Text(
                            'Bet Number: ${sale['betNumber']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'Timestamp: ${sale['timestamp']}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          trailing: Text(
                            '₱${NumberFormat('#,##0.00').format(sale['amount'])}',
                            style: TextStyle(
                              color: AppColors.primaryRed,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ).animate()
                        .fadeIn(duration: 300.ms, delay: Duration(milliseconds: 50 * index))
                        .slideY(begin: 0.1, end: 0, duration: 300.ms);
                    },
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
