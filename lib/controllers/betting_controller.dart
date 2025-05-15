import 'package:get/get.dart';
import 'package:bettingapp/config/api_config.dart';
import 'package:bettingapp/core/dio/dio_base.dart';
import 'package:bettingapp/models/bet.dart';
import 'package:bettingapp/models/draw.dart';
import 'package:bettingapp/widgets/common/modal.dart';
import 'package:dio/dio.dart';

class BettingController extends GetxController {
  static BettingController get to => Get.find<BettingController>();
  
  final DioService _dioService = DioService();
  
  // Observable lists and objects
  final RxList<Bet> bets = <Bet>[].obs;
  final RxList<Bet> cancelledBets = <Bet>[].obs;
  final RxList<Bet> claimedBets = <Bet>[].obs;
  final RxList<Bet> winningBets = <Bet>[].obs;
  final RxList<Draw> availableDraws = <Draw>[].obs;
  
  // Pagination data
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt totalItems = 0.obs;
  final RxInt perPage = 20.obs;
  
  // Claimed bets pagination data
  final RxInt claimedBetsCurrentPage = 1.obs;
  final RxInt claimedBetsTotalPages = 1.obs;
  final RxInt claimedBetsPerPage = 50.obs;
  final RxString claimedBetsLastSearchQuery = ''.obs;
  final RxString claimedBetsLastDateFilter = ''.obs;
  final Rx<int?> claimedBetsLastDrawIdFilter = Rx<int?>(null);
  final Rx<int?> claimedBetsLastGameTypeIdFilter = Rx<int?>(null);
  
  // Winning bets pagination data
  final RxInt winningBetsCurrentPage = 1.obs;
  final RxInt winningBetsTotalPages = 1.obs;
  final RxInt winningBetsPerPage = 50.obs;
  final RxString winningBetsLastSearchQuery = ''.obs;
  final RxString winningBetsLastDateFilter = ''.obs;
  final Rx<int?> winningBetsLastDrawIdFilter = Rx<int?>(null);
  final Rx<int?> winningBetsLastGameTypeIdFilter = Rx<int?>(null);
  final RxBool hasMoreWinningBets = false.obs;
  
  // Loading states
  final RxBool isLoadingBets = false.obs;
  final RxBool isLoadingCancelledBets = false.obs;
  final RxBool isLoadingClaimedBets = false.obs;
  final RxBool isLoadingWinningBets = false.obs;
  final RxBool isLoadingAvailableDraws = false.obs;
  final RxBool isPlacingBet = false.obs;
  final RxBool isCancellingBet = false.obs;
  final RxBool isClaimingBet = false.obs;
  
  // Selected values for new bet
  final Rx<int?> selectedGameTypeId = Rx<int?>(null);
  final Rx<int?> selectedDrawId = Rx<int?>(null);
  final Rx<String> betNumber = ''.obs;
  final Rx<double> betAmount = 0.0.obs;
  final RxBool isCombination = false.obs;
  
  // Last placed bet ticket ID
  final RxString lastPlacedTicketId = ''.obs;
  
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
    // Don't reset lastPlacedTicketId here as it might be needed for printing
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
  // Returns the bet data if successful, null otherwise
  Future<Map<String, dynamic>?> placeBet() async {
    if (betNumber.value.isEmpty) {
      Modal.showErrorModal(
        title: 'Validation Error',
        message: 'Please enter a bet number',
      );
      return null;
    }
    
    if (betAmount.value <= 0) {
      Modal.showErrorModal(
        title: 'Validation Error',
        message: 'Please enter a valid bet amount',
      );
      return null;
    }
    
    if (selectedGameTypeId.value == null) {
      Modal.showErrorModal(
        title: 'Validation Error',
        message: 'Please select a game type',
      );
      return null;
    }
    
    if (selectedDrawId.value == null) {
      Modal.showErrorModal(
        title: 'Validation Error',
        message: 'Please select a draw',
      );
      return null;
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
          return null;
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
            
            // Store the ticket ID for later use (e.g., printing)
            lastPlacedTicketId.value = ticketId;
            
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
            return Map<String, dynamic>.from(betData);
          } else {
            Modal.showErrorModal(
              title: 'Error Processing Response',
              message: 'Could not process the server response',
            );
            return null;
          }
        },
      );
    } catch (e) {
      Modal.showErrorModal(
        title: 'Error',
        message: 'Failed to place bet: ${e.toString()}',
      );
      return null;
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
    bool refresh = false,
    bool? is_claimed,
    bool? is_rejected,
    int? gameTypeId,
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
      if (is_claimed != null) queryParams['is_claimed'] = is_claimed;
      if (is_rejected != null) queryParams['is_rejected'] = is_rejected;
      if (gameTypeId != null) queryParams['game_type_id'] = gameTypeId;
      
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
          Modal.closeDialog();
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
          fetchCancelledBets();
          return true;
        },
      );
    } finally {
      isCancellingBet.value = false;
    }
  }
  
  // List cancelled bets with pagination
  Future<void> fetchCancelledBets({
    String? search, 
    String? date, 
    int? drawId,
    int? gameTypeId,
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
      if (gameTypeId != null) queryParams['game_type_id'] = gameTypeId;
      
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
  Future<void> loadMoreBets({RxInt? selectedGameTypeId}) async {
    if (currentPage.value < totalPages.value && !isLoadingBets.value) {
      await fetchBets(
        page: currentPage.value + 1,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
        date: selectedDate.value,
        drawId: selectedDrawIdFilter.value,
        is_claimed: showClaimed.value ? true : null,
        is_rejected: showCancelled.value ? true : null,
        gameTypeId: selectedGameTypeId != null && selectedGameTypeId.value != -1 ? selectedGameTypeId.value : null,
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
      is_claimed: selectedStatus.value == 'claimed',
      is_rejected: selectedStatus.value == 'rejected',
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
  
  final RxBool showClaimed = false.obs;
  final RxBool showCancelled = false.obs;
  
  // Helper to close dialog and show another after a short delay
  Future<void> _showModalAfterClose(Future<void> Function() showModal) async {
    Modal.closeDialog();
    await Future.delayed(const Duration(milliseconds: 300));
    await showModal();
  }

  Future<bool> cancelBetByTicketId(String ticketId) async {
    isCancellingBet.value = true;

    try {
      final result = await _dioService.authPost<void>(
        '${ApiConfig.cancelBetByTicketId}/$ticketId',
        fromJson: (_) => null,
      );

      return await result.fold(
        (error) async {
          await _showModalAfterClose(() async {
            Modal.showErrorModal(
              title: 'Error Cancelling Bet',
              message: error.message.isNotEmpty
                  ? error.message
                  : 'Failed to cancel bet.',
            );
          });
          return false;
        },
        (_) {
          fetchCancelledBets();
          return Future.value(true);
        },
      );
    } catch (e) {
      await _showModalAfterClose(() async {
        String message = 'Failed to cancel bet: ${e.toString()}';
        if (e is DioError && e.response?.data != null) {
          final data = e.response?.data;
          if (data is Map && data['message'] != null) {
            message = data['message'];
          }
        }
        Modal.showErrorModal(
          title: 'Error',
          message: message,
        );
      });
      return false;
  } finally {
      isCancellingBet.value = false;
    }
  }
  
  // List claimed bets with pagination
  Future<void> fetchClaimedBets({
    String? search, 
    String? date, 
    int? drawId,
    int? gameTypeId,
    int page = 1,
    int perPage = 50,
    bool refresh = false,
  }) async {
    // If refreshing, reset to page 1
    if (refresh) {
      claimedBetsCurrentPage.value = 1;
      claimedBets.clear();
    }
    
    // Store filter values for load more function
    claimedBetsLastSearchQuery.value = search ?? '';
    claimedBetsLastDateFilter.value = date ?? '';
    claimedBetsLastDrawIdFilter.value = drawId;
    claimedBetsLastGameTypeIdFilter.value = gameTypeId;
    claimedBetsPerPage.value = perPage;
    
    isLoadingClaimedBets.value = true;
    
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (date != null) queryParams['date'] = date;
      if (drawId != null) queryParams['draw_id'] = drawId;
      if (gameTypeId != null) queryParams['game_type_id'] = gameTypeId;
      
      final result = await _dioService.authGet<Map<String, dynamic>>(
        ApiConfig.claimedBets,
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
            title: 'Error Loading Claimed Bets',
            message: error.message,
          );
        },
        (data) {
          if (data.containsKey('data')) {
            final List<dynamic> betsData = data['data'] as List;
            final List<Bet> newBets = betsData.map((item) => Bet.fromJson(item)).toList();
            
            // If refreshing or first page, replace the list
            if (refresh || page == 1) {
              claimedBets.value = newBets;
            } else {
              // Otherwise append to the list
              claimedBets.addAll(newBets);
            }
            
            // Update pagination info
            if (data.containsKey('pagination')) {
              final pagination = data['pagination'] as Map<String, dynamic>;
              claimedBetsCurrentPage.value = pagination['current_page'] ?? 1;
              claimedBetsTotalPages.value = pagination['last_page'] ?? 1;
            }
          } else {
            if (refresh || page == 1) {
              claimedBets.clear();
            }
          }
        },
      );
    } catch (e) {
      Modal.showErrorModal(
        title: 'Error',
        message: 'Failed to load claimed bets: ${e.toString()}',
      );
    } finally {
      isLoadingClaimedBets.value = false;
    }
  }
  
  // Load more claimed bets (pagination)
  Future<void> loadMoreClaimedBets() async {
    if (claimedBetsCurrentPage.value < claimedBetsTotalPages.value && !isLoadingClaimedBets.value) {
      await fetchClaimedBets(
        page: claimedBetsCurrentPage.value + 1,
        search: claimedBetsLastSearchQuery.value.isEmpty ? null : claimedBetsLastSearchQuery.value,
        date: claimedBetsLastDateFilter.value.isEmpty ? null : claimedBetsLastDateFilter.value,
        drawId: claimedBetsLastDrawIdFilter.value,
        gameTypeId: claimedBetsLastGameTypeIdFilter.value,
        perPage: claimedBetsPerPage.value,
      );
    }
  }
  
  // Claim a bet by ticket ID
  Future<bool> claimBetByTicketId(String ticketId) async {
    isClaimingBet.value = true;

    try {
      final result = await _dioService.authPost<void>(
        '${ApiConfig.claimBetByTicketId}/$ticketId',
        fromJson: (_) => null,
      );

      return await result.fold(
        (error) async {
          await _showModalAfterClose(() async {
            Modal.showErrorModal(
              title: 'Error Claiming Bet',
              message: error.message.isNotEmpty
                  ? error.message
                  : 'Failed to claim bet.',
            );
          });
          return false;
        },
        (_) {
          fetchClaimedBets();
          fetchWinningBets(); // Refresh winning bets after claiming
          return Future.value(true);
        },
      );
    } catch (e) {
      await _showModalAfterClose(() async {
        String message = 'Failed to claim bet: ${e.toString()}';
        if (e is DioError && e.response?.data != null) {
          final data = e.response?.data;
          if (data is Map && data['message'] != null) {
            message = data['message'];
          }
        }
        Modal.showErrorModal(
          title: 'Error',
          message: message,
        );
      });
      return false;
    } finally {
      isClaimingBet.value = false;
    }
  }
  
  // List winning bets with pagination
  Future<void> fetchWinningBets({
    String? search, 
    String? date, 
    int? drawId,
    int? gameTypeId,
    bool? isClaimed,
    int page = 1,
    int perPage = 50,
    bool refresh = false,
  }) async {
    // If refreshing, reset to page 1
    if (refresh) {
      winningBetsCurrentPage.value = 1;
      winningBets.clear();
    }
    
    // Store filter values for load more function
    winningBetsLastSearchQuery.value = search ?? '';
    winningBetsLastDateFilter.value = date ?? '';
    winningBetsLastDrawIdFilter.value = drawId;
    winningBetsLastGameTypeIdFilter.value = gameTypeId;
    winningBetsPerPage.value = perPage;
    
    isLoadingWinningBets.value = true;
    
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (date != null) queryParams['date'] = date;
      if (drawId != null) queryParams['draw_id'] = drawId;
      if (gameTypeId != null) queryParams['game_type_id'] = gameTypeId;
      if (isClaimed != null) queryParams['is_claimed'] = isClaimed;
      
      final result = await _dioService.authGet<Map<String, dynamic>>(
        ApiConfig.hits,
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
            title: 'Error Loading Winning Bets',
            message: error.message,
          );
        },
        (data) {
          if (data.containsKey('data')) {
            final List<dynamic> betsData = data['data'] as List;
            final List<Bet> newBets = betsData.map((item) => Bet.fromJson(item)).toList();
            
            // If refreshing or first page, replace the list
            if (refresh || page == 1) {
              winningBets.value = newBets;
            } else {
              // Otherwise append to the list
              winningBets.addAll(newBets);
            }
            
            // Update pagination info
            if (data.containsKey('pagination')) {
              final pagination = data['pagination'] as Map<String, dynamic>;
              winningBetsCurrentPage.value = pagination['current_page'] ?? 1;
              winningBetsTotalPages.value = pagination['last_page'] ?? 1;
              hasMoreWinningBets.value = winningBetsCurrentPage.value < winningBetsTotalPages.value;
            } else {
              hasMoreWinningBets.value = false;
            }
          } else {
            if (refresh || page == 1) {
              winningBets.clear();
            }
            hasMoreWinningBets.value = false;
          }
        },
      );
    } catch (e) {
      Modal.showErrorModal(
        title: 'Error',
        message: 'Failed to load winning bets: ${e.toString()}',
      );
    } finally {
      isLoadingWinningBets.value = false;
    }
  }
  
  // Load more winning bets (pagination)
  Future<void> loadMoreWinningBets() async {
    if (winningBetsCurrentPage.value < winningBetsTotalPages.value && !isLoadingWinningBets.value) {
      await fetchWinningBets(
        page: winningBetsCurrentPage.value + 1,
        search: winningBetsLastSearchQuery.value.isEmpty ? null : winningBetsLastSearchQuery.value,
        date: winningBetsLastDateFilter.value.isEmpty ? null : winningBetsLastDateFilter.value,
        drawId: winningBetsLastDrawIdFilter.value,
        gameTypeId: winningBetsLastGameTypeIdFilter.value,
        perPage: winningBetsPerPage.value,
      );
    }
  }
}