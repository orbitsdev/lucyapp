import 'package:get/get.dart';
import 'package:bettingapp/config/api_config.dart';
import 'package:bettingapp/core/dio/dio_base.dart';
import 'package:bettingapp/models/bet.dart';
import 'package:bettingapp/models/draw.dart';
import 'package:bettingapp/widgets/common/modal.dart';

class BettingController extends GetxController {
  static BettingController get to => Get.find<BettingController>();
  
  final DioService _dioService = DioService();
  
  // Observable lists and objects
  final RxList<Bet> bets = <Bet>[].obs;
  final RxList<Bet> cancelledBets = <Bet>[].obs;
  final RxList<Draw> availableDraws = <Draw>[].obs;
  
  // Pagination data
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt totalItems = 0.obs;
  final RxInt perPage = 20.obs;
  
  // Loading states
  final RxBool isLoadingBets = false.obs;
  final RxBool isLoadingCancelledBets = false.obs;
  final RxBool isLoadingAvailableDraws = false.obs;
  final RxBool isPlacingBet = false.obs;
  final RxBool isCancellingBet = false.obs;
  
  // Selected values for new bet
  final Rx<int?> selectedGameTypeId = Rx<int?>(null);
  final Rx<int?> selectedDrawId = Rx<int?>(null);
  final Rx<String> betNumber = ''.obs;
  final Rx<double> betAmount = 0.0.obs;
  final RxBool isCombination = false.obs;
  
  // Search and filter
  final RxString searchQuery = ''.obs;
  final Rx<String?> selectedDate = Rx<String?>(null);
  final Rx<int?> selectedDrawIdFilter = Rx<int?>(null);
  final Rx<String?> selectedStatus = Rx<String?>(null);
  
  // Variables for cancelled bets pagination
  final RxInt cancelledBetsCurrentPage = 1.obs;
  final RxInt cancelledBetsTotalPages = 1.obs;
  final RxInt cancelledBetsPerPage = 50.obs;
  final RxString cancelledBetsLastSearchQuery = ''.obs;
  final RxString cancelledBetsLastDateFilter = ''.obs;
  final Rx<int?> cancelledBetsLastDrawIdFilter = Rx<int?>(null);
  
  // Note: We don't use onInit to avoid initialization errors with app binding
  // Call fetchAvailableDraws() manually when needed
  
  // Reset new bet form
  void resetBetForm() {
    selectedGameTypeId.value = null;
    selectedDrawId.value = null;
    betNumber.value = '';
    betAmount.value = 0.0;
    isCombination.value = false;
  }
  
  // Fetch available draws for betting
  Future<void> fetchAvailableDraws() async {
    isLoadingAvailableDraws.value = true;
    
    try {
      final result = await _dioService.authGet<List<Draw>>(
        ApiConfig.availableDraws,
        fromJson: (data) {
          if (data is Map && data.containsKey('data')) {
            return (data['data'] as List)
                .map((item) => Draw.fromJson(item))
                .toList();
          }
          return [];
        },
      );
      
      result.fold(
        (error) {
          Modal.showErrorModal(
            title: 'Error Loading Available Draws',
            message: error.message,
          );
        },
        (data) {
          availableDraws.value = data;
          // Auto-select first draw if available and none selected
          if (availableDraws.isNotEmpty && selectedDrawId.value == null) {
            selectedDrawId.value = availableDraws.first.id;
          }
        },
      );
    } catch (e) {
      Modal.showErrorModal(
        title: 'Error',
        message: 'Failed to load available draws: ${e.toString()}',
      );
    } finally {
      isLoadingAvailableDraws.value = false;
    }
  }
  
  // Smart format amount function that handles both string and numeric inputs
  String formatAmount(dynamic amount) {
    // Handle null case
    if (amount == null) return '0';
    
    // Convert to double first
    double numAmount;
    
    if (amount is String) {
      // Try to parse the string to a double
      try {
        // Remove any currency symbols or commas
        final cleanAmount = amount.replaceAll(RegExp(r'[^0-9.]'), '');
        numAmount = double.parse(cleanAmount);
      } catch (e) {
        print('Error parsing amount string: $e');
        return '0'; // Return 0 if parsing fails
      }
    } else if (amount is int) {
      numAmount = amount.toDouble();
    } else if (amount is double) {
      numAmount = amount;
    } else {
      print('Unsupported amount type: ${amount.runtimeType}');
      return '0'; // Return 0 for unsupported types
    }
    
    // Check if it's a whole number
    if (numAmount == numAmount.truncateToDouble()) {
      return numAmount.toInt().toString(); // No decimal places for whole numbers
    } else {
      // For non-whole numbers, show only necessary decimal places (max 2)
      // First, round to 2 decimal places
      numAmount = (numAmount * 100).round() / 100;
      
      // If the fractional part ends with 0, show only 1 decimal place
      if ((numAmount * 10).round() % 10 == 0) {
        return numAmount.toStringAsFixed(1);
      } else {
        return numAmount.toStringAsFixed(2);
      }
    }
  }
  
  // Place a new bet
  Future<bool> placeBet() async {
    if (betNumber.value.isEmpty) {
      Modal.showErrorModal(
        title: 'Validation Error',
        message: 'Please enter a bet number',
      );
      return false;
    }
    
    if (betAmount.value <= 0) {
      Modal.showErrorModal(
        title: 'Validation Error',
        message: 'Please enter a valid bet amount',
      );
      return false;
    }
    
    if (selectedGameTypeId.value == null) {
      Modal.showErrorModal(
        title: 'Validation Error',
        message: 'Please select a game type',
      );
      return false;
    }
    
    if (selectedDrawId.value == null) {
      Modal.showErrorModal(
        title: 'Validation Error',
        message: 'Please select a draw',
      );
      return false;
    }
    
    isPlacingBet.value = true;
    
    try {
      final payload = {
        'bet_number': betNumber.value,
        'amount': betAmount.value,
        'draw_id': selectedDrawId.value,
        'game_type_id': selectedGameTypeId.value,
        'is_combination': isCombination.value,
        'customer_id': null, // Optional, can be null
      };
      
      // Use dynamic type to get the raw response first
      final result = await _dioService.authPost<dynamic>(
        ApiConfig.createBet,
        data: payload,
        fromJson: (data) {
          // Just return the raw data
          print('Raw API response: $data');
          return data;
        },
      );
      
      return result.fold(
        (error) {
          Modal.showErrorModal(
            title: 'Error Placing Bet',
            message: error.message,
          );
          return false;
        },
        (response) {
          print('------------------');
          print('Response: $response');
          print('---------------------YOWW');
          
          // The response is already the bet data object
          if (response is Map) {
            final betData = response;
            print('Bet data: $betData');
            
            // Extract values directly from the response data
            final ticketId = betData['ticket_id']?.toString() ?? 'Unknown';
            final betNumber = betData['bet_number']?.toString() ?? 'Unknown';
            final amount = betData['amount'];
            
            // Format amount with proper currency using our smart formatter
            final formattedAmount = 'PHP ${formatAmount(amount)}';
            
            print('Extracted values - Ticket ID: $ticketId, Bet Number: $betNumber, Amount: $amount');
            
            // Create a Bet object and add it to the list
            try {
              final bet = Bet.fromJson(betData);
              if (bet.id != null) {
                bets.insert(0, bet);
              }
            } catch (e) {
              print('Error creating Bet object: $e');
              // Still continue to show success message even if bet object creation fails
            }
            
            // Show success message with the extracted values
            Modal.showSuccessModal(
              title: 'Bet Placed Successfully',
              message: 'Ticket ID: $ticketId\nBet Number: $betNumber\nAmount: $formattedAmount',
              showButton: true,
            );
            
            // Reset form
            resetBetForm();
            return true;
          } else {
            Modal.showErrorModal(
              title: 'Error Processing Response',
              message: 'Could not process the server response',
            );
            return false;
          }
        },
      );
    } catch (e) {
      Modal.showErrorModal(
        title: 'Error',
        message: 'Failed to place bet: ${e.toString()}',
      );
      return false;
    } finally {
      isPlacingBet.value = false;
    }
  }
  
  // List bets with optional filtering
  Future<void> fetchBets({
    int page = 1,
    int? perPage,
    String? search,
    String? date,
    int? drawId,
    String? status,
    bool refresh = false,
  }) async {
    isLoadingBets.value = true;
    
    if (refresh) {
      bets.clear();
      currentPage.value = 1;
    }
    
    try {
      final queryParams = <String, dynamic>{
        'page': page,
      };
      
      if (perPage != null) queryParams['per_page'] = perPage;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (date != null) queryParams['date'] = date;
      if (drawId != null) queryParams['draw_id'] = drawId;
      if (status != null) queryParams['status'] = status;
      
      final result = await _dioService.authGet<Map<String, dynamic>>(
        ApiConfig.bets,
        queryParameters: queryParams,
        fromJson: (data) {
          if (data is Map && data.containsKey('data')) {
            final List<Bet> fetchedBets = (data['data'] as List)
                .map((item) => Bet.fromJson(item))
                .toList();
                
            if (data.containsKey('pagination')) {
              final pagination = data['pagination'];
              return {
                'bets': fetchedBets,
                'current_page': pagination['current_page'],
                'last_page': pagination['last_page'],
                'per_page': pagination['per_page'],
                'total': pagination['total'],
              };
            }
            
            return {'bets': fetchedBets};
          }
          return {'bets': <Bet>[]};
        },
      );
      
      result.fold(
        (error) {
          Modal.showErrorModal(
            title: 'Error Loading Bets',
            message: error.message,
          );
        },
        (data) {
          final List<Bet> fetchedBets = data['bets'];
          
          if (refresh || page == 1) {
            bets.value = fetchedBets;
          } else {
            bets.addAll(fetchedBets);
          }
          
          if (data.containsKey('current_page')) {
            currentPage.value = data['current_page'];
            totalPages.value = data['last_page'];
            this.perPage.value = data['per_page'];
            totalItems.value = data['total'];
          }
        },
      );
    } catch (e) {
      Modal.showErrorModal(
        title: 'Error',
        message: 'Failed to load bets: ${e.toString()}',
      );
    } finally {
      isLoadingBets.value = false;
    }
  }
  
  // Cancel a bet
  Future<bool> cancelBet(int betId) async {
    isCancellingBet.value = true;
    
    try {
      final result = await _dioService.authPost<void>(
        '${ApiConfig.cancelBet}/$betId',
        fromJson: (_) => null,
      );
      
      return result.fold(
        (error) {
          Modal.showErrorModal(
            title: 'Error Cancelling Bet',
            message: error.message,
          );
          return false;
        },
        (_) {
          // Update the bet status in the list
          final index = bets.indexWhere((bet) => bet.id == betId);
          if (index != -1) {
            final updatedBet = bets[index].copyWith(isRejected: true);
            bets[index] = updatedBet;
          }
          
          // Refresh cancelled bets list
          fetchCancelledBets();
          
          return true;
        },
      );
    } catch (e) {
      Modal.showErrorModal(
        title: 'Error',
        message: 'Failed to cancel bet: ${e.toString()}',
      );
      return false;
    } finally {
      isCancellingBet.value = false;
    }
  }
  
  // List cancelled bets with pagination
  Future<void> fetchCancelledBets({
    String? search, 
    String? date, 
    int? drawId,
    int page = 1,
    int perPage = 50,
    bool refresh = false,
  }) async {
    // If refreshing, reset to page 1
    if (refresh) {
      cancelledBetsCurrentPage.value = 1;
      cancelledBets.clear();
    }
    
    // Store filter values for load more function
    cancelledBetsLastSearchQuery.value = search ?? '';
    cancelledBetsLastDateFilter.value = date ?? '';
    cancelledBetsLastDrawIdFilter.value = drawId;
    cancelledBetsPerPage.value = perPage;
    
    isLoadingCancelledBets.value = true;
    
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (date != null) queryParams['date'] = date;
      if (drawId != null) queryParams['draw_id'] = drawId;
      
      final result = await _dioService.authGet<Map<String, dynamic>>(
        ApiConfig.cancelledBets,
        queryParameters: queryParams,
        fromJson: (data) {
          if (data is Map<String, dynamic>) {
            return data;
          }
          return <String, dynamic>{};
        },
      );
      
      result.fold(
        (error) {
          Modal.showErrorModal(
            title: 'Error Loading Cancelled Bets',
            message: error.message,
          );
        },
        (data) {
          if (data.containsKey('data')) {
            final List<dynamic> betsData = data['data'] as List;
            final List<Bet> newBets = betsData.map((item) => Bet.fromJson(item)).toList();
            
            // If refreshing or first page, replace the list
            if (refresh || page == 1) {
              cancelledBets.value = newBets;
            } else {
              // Otherwise append to the list
              cancelledBets.addAll(newBets);
            }
            
            // Update pagination info
            if (data.containsKey('meta')) {
              final meta = data['meta'] as Map<String, dynamic>;
              cancelledBetsCurrentPage.value = meta['current_page'] ?? 1;
              cancelledBetsTotalPages.value = meta['last_page'] ?? 1;
            }
          } else {
            if (refresh || page == 1) {
              cancelledBets.clear();
            }
          }
        },
      );
    } catch (e) {
      Modal.showErrorModal(
        title: 'Error',
        message: 'Failed to load cancelled bets: ${e.toString()}',
      );
    } finally {
      isLoadingCancelledBets.value = false;
    }
  }
  
  // Load more bets (pagination)
  Future<void> loadMoreBets() async {
    if (currentPage.value < totalPages.value && !isLoadingBets.value) {
      await fetchBets(
        page: currentPage.value + 1,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
        date: selectedDate.value,
        drawId: selectedDrawIdFilter.value,
        status: selectedStatus.value,
      );
    }
  }
  
  // Apply filters to bets list
  Future<void> applyFilters() async {
    await fetchBets(
      refresh: true,
      search: searchQuery.value.isEmpty ? null : searchQuery.value,
      date: selectedDate.value,
      drawId: selectedDrawIdFilter.value,
      status: selectedStatus.value,
    );
  }
  
  // Reset filters
  void resetFilters() {
    searchQuery.value = '';
    selectedDate.value = null;
    selectedDrawIdFilter.value = null;
    selectedStatus.value = null;
  }
  
  // Load more cancelled bets (pagination)
  Future<void> loadMoreCancelledBets() async {
    if (cancelledBetsCurrentPage.value < cancelledBetsTotalPages.value && !isLoadingCancelledBets.value) {
      await fetchCancelledBets(
        page: cancelledBetsCurrentPage.value + 1,
        search: cancelledBetsLastSearchQuery.value.isEmpty ? null : cancelledBetsLastSearchQuery.value,
        date: cancelledBetsLastDateFilter.value.isEmpty ? null : cancelledBetsLastDateFilter.value,
        drawId: cancelledBetsLastDrawIdFilter.value,
        perPage: cancelledBetsPerPage.value,
      );
    }
  }
}