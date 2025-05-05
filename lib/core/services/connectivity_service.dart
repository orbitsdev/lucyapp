import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:bettingapp/widgets/common/modal.dart';

class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  final RxBool isConnected = true.obs;
  StreamSubscription? _subscription;
  bool _modalShown = false;

  Future<ConnectivityService> init() async {
    // Check initial connection state
    final connectivityResults = await _connectivity.checkConnectivity();
    _processConnectivityResults(connectivityResults);

    // Listen for connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen(_processConnectivityResults);
    
    return this;
  }
  
  void _processConnectivityResults(List<ConnectivityResult> results) {
    // If any result is not 'none', consider it connected
    final hasConnection = results.any((result) => result != ConnectivityResult.none);
    _updateConnectionStatus(hasConnection);
  }

  void _updateConnectionStatus(bool connected) {
    final wasConnected = isConnected.value;
    isConnected.value = connected;
    
    // Show no internet modal when connection is lost
    if (wasConnected && !isConnected.value && !_modalShown) {
      _modalShown = true;
      Modal.showNoInternetModal(
        onRetry: () async {
          final connectivityResults = await _connectivity.checkConnectivity();
          _processConnectivityResults(connectivityResults);
        },
      );
    } 
    // Close modal and show success message when connection is restored
    else if (!wasConnected && isConnected.value && _modalShown) {
      _modalShown = false;
      Modal.closeDialog();
      Modal.showSuccessModal(
        title: 'Connection Restored',
        message: 'Your internet connection has been restored.',
        duration: const Duration(seconds: 2),
      );
    }
  }

  // Check current connectivity status
  Future<bool> checkConnectivity() async {
    final connectivityResults = await _connectivity.checkConnectivity();
    return connectivityResults.any((result) => result != ConnectivityResult.none);
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
