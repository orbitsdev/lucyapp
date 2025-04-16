import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bettingapp/utils/app_colors.dart';
import 'package:intl/intl.dart';

class HistoryController extends GetxController {
  final RxList<Map<String, dynamic>> historyItems = <Map<String, dynamic>>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    // Load sample history data
    loadHistoryData();
  }
  
  void loadHistoryData() {
    // Sample history data
    final now = DateTime.now();
    historyItems.value = List.generate(
      20,
      (index) => {
        'id': 'DOC-${10000 + index}',
        'timestamp': now.subtract(Duration(hours: index * 2)),
        'amount': (index + 1) * 50,
        'betNumber': '${(index * 123) % 1000}'.padLeft(3, '0'),
        'schedule': index % 4 == 0
            ? '11AM'
            : index % 4 == 1
                ? '3P'
                : index % 4 == 2
                    ? '4PM'
                    : '9PM',
      },
    );
  }
  
  void viewHistoryDetails(String id) {
    final item = historyItems.firstWhere((item) => item['id'] == id);
    
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bet Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Document No.', item['id']),
            _buildDetailRow('Date & Time', DateFormat('MMM dd, yyyy hh:mm a').format(item['timestamp'])),
            _buildDetailRow('Bet Number', item['betNumber']),
            _buildDetailRow('Amount', 'PHP ${item['amount']}'),
            _buildDetailRow('Schedule', item['schedule']),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.historyColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'CLOSE',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.secondaryText,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HistoryController());
    
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('HISTORY'),
        backgroundColor: AppColors.historyColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.historyItems.length,
        itemBuilder: (context, index) {
          final item = controller.historyItems[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: InkWell(
              onTap: () => controller.viewHistoryDetails(item['id']),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Left side - Document ID and timestamp
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['id'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('MMM dd, yyyy hh:mm a').format(item['timestamp']),
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Right side - Amount and arrow
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'PHP ${item['amount']}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['schedule'],
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(width: 8),
                    
                    Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.secondaryText,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ).animate()
            .fadeIn(duration: 300.ms, delay: (index * 30).ms)
            .slideX(begin: 0.1, end: 0, duration: 300.ms);
        },
      )),
    );
  }
}
