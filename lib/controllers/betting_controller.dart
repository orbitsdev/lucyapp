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
      
      final result = await _dioService.authPost<Bet>(
        ApiConfig.createBet,
        data: payload,
        fromJson: (data) {
          if (data is Map && data.containsKey('data')) {
            return Bet.fromJson(data['data']);
          }
          return Bet();
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
        (bet) {
          // Add the new bet to the list
          bets.insert(0, bet);
          
          // Show success message
          Modal.showSuccessModal(
            title: 'Bet Placed Successfully',
            message: 'Ticket ID: ${bet.ticketId}\nBet Number: ${bet.betNumber}\nAmount: ${bet.amount}',
            showButton: true,
          );
          
          // Reset form
          resetBetForm();
          return true;
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
          
          // Show success message
          Modal.showSuccessModal(
            title: 'Bet Cancelled',
            message: 'The bet has been cancelled successfully.',
            showButton: true,
          );
          
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
  
  // List cancelled bets
  Future<void> fetchCancelledBets({String? search}) async {
    isLoadingCancelledBets.value = true;
    
    try {
      final queryParams = <String, dynamic>{};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      
      final result = await _dioService.authGet<List<Bet>>(
        ApiConfig.cancelledBets,
        queryParameters: queryParams,
        fromJson: (data) {
          if (data is Map && data.containsKey('data')) {
            return (data['data'] as List)
                .map((item) => Bet.fromJson(item))
                .toList();
          }
          return [];
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
          cancelledBets.value = data;
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
}