import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bettingapp/utils/app_colors.dart';

class CancelBetController extends GetxController {
  final RxString betNumber = ''.obs;
  final RxBool isLoading = false.obs;
  final RxList<Map<String, dynamic>> cancelledBets = <Map<String, dynamic>>[].obs;
  final RxString selectedSchedule = 'All'.obs;
  final RxString searchQuery = ''.obs;
  
  // Available schedule options
  final List<String> schedules = ['All', '2 pm', '5 pm', '9 pm'];
  
  @override
  void onInit() {
    super.onInit();
    // Load sample cancelled bets
    loadCancelledBets();
  }
  
  void loadCancelledBets() {
    // Sample cancelled bets with schedule information
    cancelledBets.value = [
      {
        'number': '24',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
        'amount': 20,
        'schedule': '5 PM',
      },
      {
        'number': '17',
        'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
        'amount': 50,
        'schedule': '2 PM',
      },
      {
        'number': '36',
        'timestamp': DateTime.now().subtract(const Duration(hours: 8)),
        'amount': 100,
        'schedule': '9 PM',
      },
      {
        'number': '42',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)),
        'amount': 200,
        'schedule': '5 PM',
      },
      {
        'number': '08',
        'timestamp': DateTime.now().subtract(const Duration(days: 1, hours: 4)),
        'amount': 150,
        'schedule': '2 PM',
      },
    ];
  }
  
  List<Map<String, dynamic>> get filteredBets {
    return cancelledBets.where((bet) {
      // Apply schedule filter if not "All"
      bool matchesSchedule = selectedSchedule.value == 'All' || 
                            bet['schedule'] == selectedSchedule.value;
      
      // Apply search filter if search query exists
      bool matchesSearch = searchQuery.isEmpty || 
                          bet['number'].toString().contains(searchQuery.value);
      
      return matchesSchedule && matchesSearch;
    }).toList();
  }
  
  void setScheduleFilter(String schedule) {
    selectedSchedule.value = schedule;
  }
  
  void search(String query) {
    searchQuery.value = query;
  }
  
  Future<void> cancelBet() async {
    if (betNumber.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a bet number',
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
        content: Text('Are you sure you want to cancel bet ${betNumber.value}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('NO'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryRed,
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
    
    // Add to cancelled bets
    cancelledBets.insert(0, {
      'number': betNumber.value,
      'timestamp': DateTime.now(),
      'amount': 50,
      'schedule': '5 PM',
    });
    
    isLoading.value = false;
    betNumber.value = '';
    
    // Show success message
    Get.snackbar(
      'Success',
      'Bet cancelled successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
  
  void showDetailsDialog(String number) {
    final bet = cancelledBets.firstWhere((bet) => bet['number'] == number);
    
    Get.dialog(
      AlertDialog(
        title: const Text('Cancellation Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Bet Number', bet['number']),
            _buildDetailRow('Date', '${bet['timestamp'].day}/${bet['timestamp'].month}/${bet['timestamp'].year}'),
            _buildDetailRow('Time', '${bet['timestamp'].hour}:${bet['timestamp'].minute.toString().padLeft(2, '0')}'),
            _buildDetailRow('Amount', 'PHP ${bet['amount']}'),
            _buildDetailRow('Schedule', bet['schedule']),
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

class CancelBetScreen extends StatelessWidget {
  const CancelBetScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CancelBetController());
    
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('CANCEL BET'),
        backgroundColor: AppColors.primaryRed,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Cancel Bet Form
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
                  'Bet Number',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() => TextField(
                  onChanged: (value) => controller.betNumber.value = value,
                  controller: TextEditingController(text: controller.betNumber.value),
                  decoration: InputDecoration(
                    hintText: 'Enter bet number',
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
                        : () => controller.cancelBet(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      disabledBackgroundColor: AppColors.primaryRed.withOpacity(0.6),
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
                            'CANCEL BET',
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
          
          // Filter and Search Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                // Schedule Filter
                Row(
                  children: [
                    const Text(
                      'Schedule Filter:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Obx(() => DropdownButton<String>(
                        value: controller.selectedSchedule.value,
                        isExpanded: true,
                        underline: const SizedBox(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            controller.setScheduleFilter(newValue);
                          }
                        },
                        items: controller.schedules
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      )),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Search Bar
                TextField(
                  onChanged: (value) => controller.search(value),
                  decoration: InputDecoration(
                    hintText: 'Search bet number',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
          
          // Cancelled Bets Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text(
                  'Cancelled Bets',
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
                    '${controller.filteredBets.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  )),
                ),
              ],
            ),
          ),
          
          // Table Header
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.primaryRed.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: const [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Bet Number',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Amount',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Schedule',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Cancelled Bets List
          Expanded(
            child: Obx(() => controller.filteredBets.isEmpty
              ? Center(
                  child: Text(
                    'No cancelled bets found',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 16,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.filteredBets.length,
                  itemBuilder: (context, index) {
                    final bet = controller.filteredBets[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: InkWell(
                        onTap: () => controller.showDetailsDialog(bet['number']),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Bet Number
                              Expanded(
                                flex: 2,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryRed.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          bet['number'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryRed,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '${bet['timestamp'].day}/${bet['timestamp'].month}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Amount
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '${bet['amount']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              
                              // Schedule
                              Expanded(
                                flex: 1,
                                child: Text(
                                  bet['schedule'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ),
          ),
        ],
      ),
    );
  }
}
