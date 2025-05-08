import 'package:get/get.dart';

class CustomerDashboardController extends GetxController {
  final RxDouble accountBalance = 0.0.obs;
  final RxInt activeBets = 0.obs;
  final RxDouble totalWinnings = 0.0.obs;
  final RxList<Map<String, dynamic>> recentBets = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> upcomingDraws = <Map<String, dynamic>>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }
  
  Future<void> fetchDashboardData() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock data
    accountBalance.value = 1250.0;
    activeBets.value = 3;
    totalWinnings.value = 750.0;
    
    recentBets.value = [
      {
        'ticket': 'T123456',
        'game': '3D Game',
        'numbers': '1-2-3',
        'amount': '₱100.00',
        'date': 'Today',
        'time': '10:30 AM',
        'status': 'Active'
      },
      {
        'ticket': 'T123455',
        'game': '2D Game',
        'numbers': '4-5',
        'amount': '₱50.00',
        'date': 'Today',
        'time': '09:30 AM',
        'status': 'Active'
      },
      {
        'ticket': 'T123445',
        'game': '3D Game',
        'numbers': '6-7-8',
        'amount': '₱150.00',
        'date': 'Yesterday',
        'time': '04:45 PM',
        'status': 'Won'
      },
      {
        'ticket': 'T123435',
        'game': '1D Game',
        'numbers': '9',
        'amount': '₱20.00',
        'date': 'Yesterday',
        'time': '11:15 AM',
        'status': 'Lost'
      },
      {
        'ticket': 'T123425',
        'game': '2D Game',
        'numbers': '0-1',
        'amount': '₱80.00',
        'date': '2 days ago',
        'time': '09:30 AM',
        'status': 'Lost'
      },
    ];
    
    upcomingDraws.value = [
      {
        'game': '3D Game',
        'time': '11:00 AM',
        'date': 'Today',
        'countdown': '00:45:30'
      },
      {
        'game': '2D Game',
        'time': '11:00 AM',
        'date': 'Today',
        'countdown': '00:45:30'
      },
      {
        'game': '3D Game',
        'time': '04:00 PM',
        'date': 'Today',
        'countdown': '05:45:30'
      },
      {
        'game': '2D Game',
        'time': '04:00 PM',
        'date': 'Today',
        'countdown': '05:45:30'
      },
      {
        'game': '3D Game',
        'time': '09:00 PM',
        'date': 'Today',
        'countdown': '10:45:30'
      },
    ];
  }
  
  void refreshData() {
    fetchDashboardData();
  }
}
