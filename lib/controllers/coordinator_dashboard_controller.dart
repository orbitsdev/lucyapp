import 'package:get/get.dart';

class CoordinatorDashboardController extends GetxController {
  final RxInt totalTellers = 0.obs;
  final RxInt totalCustomers = 0.obs;
  final RxDouble totalSales = 0.0.obs;
  final RxDouble totalClaims = 0.0.obs;
  final RxList<Map<String, dynamic>> recentActivities = <Map<String, dynamic>>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }
  
  Future<void> fetchDashboardData() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock data
    totalTellers.value = 15;
    totalCustomers.value = 120;
    totalSales.value = 25000.0;
    totalClaims.value = 8000.0;
    
    recentActivities.value = [
      {
        'type': 'New Teller',
        'description': 'Added new teller: John Doe',
        'time': '10:30 AM',
        'date': 'Today'
      },
      {
        'type': 'Winning Numbers',
        'description': 'Set winning numbers for 3D Game: 1-2-3',
        'time': '09:15 AM',
        'date': 'Today'
      },
      {
        'type': 'Report',
        'description': 'Generated monthly sales report',
        'time': '08:45 AM',
        'date': 'Today'
      },
      {
        'type': 'System',
        'description': 'Updated game configuration',
        'time': '05:30 PM',
        'date': 'Yesterday'
      },
      {
        'type': 'Claim',
        'description': 'Approved large claim: ₱5,000',
        'time': '03:20 PM',
        'date': 'Yesterday'
      },
    ];
  }
  
  void refreshData() {
    fetchDashboardData();
  }
}
