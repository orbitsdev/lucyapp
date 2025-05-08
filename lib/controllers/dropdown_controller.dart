import 'package:get/get.dart';
import 'package:bettingapp/config/api_config.dart';
import 'package:bettingapp/core/dio/dio_base.dart';
import 'package:bettingapp/models/game_type.dart';
import 'package:bettingapp/models/schedule.dart';
import 'package:bettingapp/models/draw.dart';
import 'package:bettingapp/widgets/common/modal.dart';

class DropdownController extends GetxController {
  static DropdownController get to => Get.find<DropdownController>();
  
  final DioService _dioService = DioService();
  
  // Observable lists for dropdown data
  final RxList<GameType> gameTypes = <GameType>[].obs;
  final RxList<Schedule> schedules = <Schedule>[].obs;
  final RxList<Draw> draws = <Draw>[].obs;
  final RxList<Draw> availableDates = <Draw>[].obs;
  
  // Loading states
  final RxBool isLoadingGameTypes = false.obs;
  final RxBool isLoadingSchedules = false.obs;
  final RxBool isLoadingDraws = false.obs;
  final RxBool isLoadingAvailableDates = false.obs;
  
  // Note: We don't use onInit to avoid initialization errors with app binding
  // Call fetchAllDropdownData() manually when needed
  
  // Fetch all dropdown data at once
  Future<void> fetchAllDropdownData() async {
    await Future.wait([
      fetchGameTypes(),
      fetchSchedules(),
      fetchDraws(),
      fetchAvailableDates(),
    ]);
  }
  
  // Fetch game types
  Future<void> fetchGameTypes() async {
    isLoadingGameTypes.value = true;
    
    try {
      final result = await _dioService.authGet<List<GameType>>(
        ApiConfig.gameTypes,
        fromJson: (data) {
          if (data is Map && data.containsKey('data')) {
            return (data['data'] as List)
                .map((item) => GameType.fromJson(item))
                .toList();
          }
          return [];
        },
      );
      
      result.fold(
        (error) {
          Modal.showErrorModal(
            title: 'Error Loading Game Types',
            message: error.message,
          );
        },
        (data) {
          gameTypes.value = data;
        },
      );
    } catch (e) {
      Modal.showErrorModal(
        title: 'Error',
        message: 'Failed to load game types: ${e.toString()}',
      );
    } finally {
      isLoadingGameTypes.value = false;
    }
  }
  
  // Fetch schedules
  Future<void> fetchSchedules() async {
    isLoadingSchedules.value = true;
    
    try {
      final result = await _dioService.authGet<List<Schedule>>(
        ApiConfig.schedules,
        fromJson: (data) {
          if (data is Map && data.containsKey('data')) {
            return (data['data'] as List)
                .map((item) => Schedule.fromJson(item))
                .toList();
          }
          return [];
        },
      );
      
      result.fold(
        (error) {
          Modal.showErrorModal(
            title: 'Error Loading Schedules',
            message: error.message,
          );
        },
        (data) {
          schedules.value = data;
        },
      );
    } catch (e) {
      Modal.showErrorModal(
        title: 'Error',
        message: 'Failed to load schedules: ${e.toString()}',
      );
    } finally {
      isLoadingSchedules.value = false;
    }
  }
  
  // Fetch draws
  Future<void> fetchDraws() async {
    isLoadingDraws.value = true;
    
    try {
      final result = await _dioService.authGet<List<Draw>>(
        ApiConfig.draws,
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
            title: 'Error Loading Draws',
            message: error.message,
          );
        },
        (data) {
          draws.value = data;
        },
      );
    } catch (e) {
      Modal.showErrorModal(
        title: 'Error',
        message: 'Failed to load draws: ${e.toString()}',
      );
    } finally {
      isLoadingDraws.value = false;
    }
  }
  
  // Fetch available dates
  Future<void> fetchAvailableDates() async {
    isLoadingAvailableDates.value = true;
    
    try {
      final result = await _dioService.authGet<List<Draw>>(
        ApiConfig.availableDates,
        fromJson: (data) {
          if (data is Map && data.containsKey('data') && 
              data['data'] is Map && data['data'].containsKey('available_dates')) {
            return (data['data']['available_dates'] as List)
                .map((item) => Draw.fromJson(item))
                .toList();
          }
          return [];
        },
      );
      
      result.fold(
        (error) {
          Modal.showErrorModal(
            title: 'Error Loading Available Dates',
            message: error.message,
          );
        },
        (data) {
          availableDates.value = data;
        },
      );
    } catch (e) {
      Modal.showErrorModal(
        title: 'Error',
        message: 'Failed to load available dates: ${e.toString()}',
      );
    } finally {
      isLoadingAvailableDates.value = false;
    }
  }
  
  // Get game type by ID
  GameType? getGameTypeById(int id) {
    return gameTypes.firstWhereOrNull((gameType) => gameType.id == id);
  }
  
  // Get schedule by ID
  Schedule? getScheduleById(int id) {
    return schedules.firstWhereOrNull((schedule) => schedule.id == id);
  }
  
  // Get draw by ID
  Draw? getDrawById(int id) {
    return draws.firstWhereOrNull((draw) => draw.id == id);
  }
  
  // Get available date by ID
  Draw? getAvailableDateById(int id) {
    return availableDates.firstWhereOrNull((date) => date.id == id);
  }
  
  // Get active draws (isOpen = true)
  List<Draw> getActiveDraws() {
    return draws.where((draw) => draw.isOpen == true).toList();
  }
}