import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bettingapp/utils/app_colors.dart';
import 'package:bettingapp/widgets/location_dropdown.dart';

class SoldOutController extends GetxController {
  final RxString selectedLocation = 'All Locations'.obs;
  final RxString selectedTimeSlot = 'All Time Slots'.obs;
  final RxString comboName = ''.obs;
  
  final RxList<Map<String, dynamic>> soldOutItems = <Map<String, dynamic>>[].obs;
  
  final List<String> locations = [
    'All Locations',
    'Davao',
    'Isulan',
    'Tacurong',
    'S2',
    'S3',
    'L2',
    'L3',
    '4D',
    'P3'
  ];
  
  final List<String> timeSlots = [
    'All Time Slots',
    '11AM',
    '3P',
    '4PM',
    '9PM',
  ];
  
  void addSoldOutItem() {
    if (comboName.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a combo name',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    soldOutItems.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'location': selectedLocation.value,
      'timeSlot': selectedTimeSlot.value,
      'combo': comboName.value,
    });
    
    // Clear the input field
    comboName.value = '';
  }
  
  void removeSoldOutItem(String id) {
    soldOutItems.removeWhere((item) => item['id'] == id);
  }
  
  void editSoldOutItem(String id) {
    final item = soldOutItems.firstWhere((item) => item['id'] == id);
    selectedLocation.value = item['location'];
    selectedTimeSlot.value = item['timeSlot'];
    comboName.value = item['combo'];
    
    // Remove the item to edit
    soldOutItems.removeWhere((item) => item['id'] == id);
  }
}

class SoldOutScreen extends StatelessWidget {
  const SoldOutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SoldOutController());
    
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('SOLD OUT'),
        backgroundColor: AppColors.cancelColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Input Form
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
              children: [
                // Location Dropdown
                Obx(() => LocationDropdown(
                  value: controller.selectedLocation.value,
                  onChanged: (value) => controller.selectedLocation.value = value,
                  locations: controller.locations,
                  label: 'SELECT LOCATION',
                )),
                
                // Time Slot Dropdown
                Obx(() => Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.selectedTimeSlot.value,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      iconSize: 24,
                      elevation: 16,
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 16,
                      ),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          controller.selectedTimeSlot.value = newValue;
                        }
                      },
                      items: controller.timeSlots
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      hint: Text(
                        'TIME SLOT',
                        style: TextStyle(
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ),
                  ),
                )),
                
                // Combo Name Input
                TextField(
                  onChanged: (value) => controller.comboName.value = value,
                  controller: TextEditingController(text: controller.comboName.value),
                  decoration: InputDecoration(
                    labelText: 'NAME',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Add Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => controller.addSoldOutItem(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'ADD',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'DRAW',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: const Text(
                      'COMBO',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Sold Out Items List
          Expanded(
            child: Obx(() => ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.soldOutItems.length,
              itemBuilder: (context, index) {
                final item = controller.soldOutItems[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      // Draw (Time Slot)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            item['timeSlot'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      
                      // Combo
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            item['combo'],
                          ),
                        ),
                      ),
                      
                      // Actions
                      Row(
                        children: [
                          // Edit Button
                          IconButton(
                            icon: Icon(
                              Icons.edit,
                              color: AppColors.primaryBlue,
                              size: 20,
                            ),
                            onPressed: () => controller.editSoldOutItem(item['id']),
                          ),
                          
                          // Delete Button
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: AppColors.error,
                              size: 20,
                            ),
                            onPressed: () => controller.removeSoldOutItem(item['id']),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate()
                  .fadeIn(duration: 300.ms, delay: (index * 50).ms)
                  .slideX(begin: 0.1, end: 0, duration: 300.ms);
              },
            )),
          ),
        ],
      ),
    );
  }
}
