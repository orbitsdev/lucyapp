import 'package:get/get.dart';

class TellerDashboardController extends GetxController {
  final RxDouble todaySales = 0.0.obs;
  final RxInt todayTickets = 0.obs;
  final RxDouble todayClaims = 0.0.obs;
  final RxInt pendingClaims = 0.obs;
  final RxList<Map<String, dynamic>> recentTransactions = <Map<String, dynamic>>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }
  
  Future<void> fetchDashboardData() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock data
    todaySales.value = 5280.0;
    todayTickets.value = 42;
    todayClaims.value = 1500.0;
    pendingClaims.value = 3;
    
    recentTransactions.value = [
      {
        'type': 'Sale',
        'ticket': 'T123456',
        'amount': '₱100.00',
        'time': '10:30 AM',
        'game': '3D Game'
      },
      {
        'type': 'Claim',
        'ticket': 'T123400',
        'amount': '₱500.00',
        'time': '09:45 AM',
        'game': '2D Game'
      },
      {
        'type': 'Sale',
        'ticket': 'T123455',
        'amount': '₱50.00',
        'time': '09:30 AM',
        'game': '1D Game'
      },
      {
        'type': 'Cancel',
        'ticket': 'T123450',
        'amount': '₱200.00',
        'time': '09:15 AM',
        'game': '3D Game'
      },
      {
        'type': 'Sale',
        'ticket': 'T123445',
        'amount': '₱150.00',
        'time': '08:45 AM',
        'game': '3D Game'
      },
    ];
  }
  
  void refreshData() {
    fetchDashboardData();
  }
}
