import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bettingapp/utils/app_colors.dart';

class CancelDocController extends GetxController {
  final RxString docNumber = ''.obs;
  final RxBool isLoading = false.obs;
  final RxList<Map<String, dynamic>> cancelledDocs = <Map<String, dynamic>>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    // Load sample cancelled documents
    loadCancelledDocs();
  }
  
  void loadCancelledDocs() {
    // Sample cancelled documents
    cancelledDocs.value = List.generate(
      5,
      (index) => {
        'id': 'DOC-${10000 + index}',
        'timestamp': DateTime.now().subtract(Duration(days: index)),
        'amount': (index + 1) * 100,
        'reason': index % 2 == 0 ? 'Wrong entry' : 'Customer request',
      },
    );
  }
  
  Future<void> cancelDocument() async {
    if (docNumber.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a document number',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    // Show confirmation dialog
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirm Cancellation'),
        content: Text('Are you sure you want to cancel document ${docNumber.value}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('NO'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.cancelColor,
            ),
            child: const Text('YES'),
          ),
        ],
      ),
    );
    
    if (result != true) return;
    
    isLoading.value = true;
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    // Add to cancelled documents
    cancelledDocs.insert(0, {
      'id': docNumber.value,
      'timestamp': DateTime.now(),
      'amount': 150,
      'reason': 'Customer request',
    });
    
    isLoading.value = false;
    docNumber.value = '';
    
    // Show success message
    Get.snackbar(
      'Success',
      'Document cancelled successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
  
  void showReasonDialog(String id) {
    final doc = cancelledDocs.firstWhere((doc) => doc['id'] == id);
    
    Get.dialog(
      AlertDialog(
        title: const Text('Cancellation Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Document No.', doc['id']),
            _buildDetailRow('Date', '${doc['timestamp'].day}/${doc['timestamp'].month}/${doc['timestamp'].year}'),
            _buildDetailRow('Amount', 'PHP ${doc['amount']}'),
            _buildDetailRow('Reason', doc['reason']),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('CLOSE'),
          ),
        ],
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
            width: 100,
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

class CancelDocScreen extends StatelessWidget {
  const CancelDocScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CancelDocController());
    
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('CANCEL DOCUMENT'),
        backgroundColor: AppColors.cancelColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Cancel Document Form
          Container(
            margin: const EdgeInsets.all(16),
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
                  'Document Number',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() => TextField(
                  onChanged: (value) => controller.docNumber.value = value,
                  controller: TextEditingController(text: controller.docNumber.value),
                  decoration: InputDecoration(
                    hintText: 'Enter document number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                )),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.cancelDocument(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cancelColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      disabledBackgroundColor: AppColors.cancelColor.withOpacity(0.6),
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'CANCEL DOCUMENT',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  )),
                ),
              ],
            ),
          ).animate()
            .fadeIn(duration: 300.ms)
            .slideY(begin: 0.1, end: 0, duration: 300.ms),
          
          // Recently Cancelled Documents
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text(
                  'Recently Cancelled Documents',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Obx(() => Text(
                    '${controller.cancelledDocs.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  )),
                ),
              ],
            ),
          ),
          
          // Cancelled Documents List
          Expanded(
            child: Obx(() => ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.cancelledDocs.length,
              itemBuilder: (context, index) {
                final doc = controller.cancelledDocs[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: InkWell(
                    onTap: () => controller.showReasonDialog(doc['id']),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Cancel Icon
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.cancelColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.cancel,
                              color: AppColors.cancelColor,
                              size: 24,
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          // Document Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doc['id'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryText,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${doc['timestamp'].day}/${doc['timestamp'].month}/${doc['timestamp'].year}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Amount
                          Text(
                            'PHP ${doc['amount']}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryText,
                            ),
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
          ),
        ],
      ),
    );
  }
}
