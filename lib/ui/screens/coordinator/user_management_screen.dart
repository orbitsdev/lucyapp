import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bettingapp/utils/app_colors.dart';

class UserManagementController extends GetxController {
  final searchQuery = ''.obs;
  final selectedLocation = 'All Locations'.obs;
  final locations = ['All Locations', 'L1', 'L2', 'L3', 'L4', 'L5'].obs;
  final selectedTabIndex = 0.obs;
  
  List<Map<String, dynamic>> get filteredTellers {
    // In a real app, this would filter from a database
    // For now, we'll just simulate filtering
    final List<Map<String, dynamic>> allTellers = List.generate(
      10,
      (index) => {
        'name': 'Teller ${index + 1}',
        'email': 'teller${index + 1}@example.com',
        'phone': '+1234567890',
        'role': 'Teller',
        'isActive': index % 3 != 0,
        'location': 'L${(index % 5) + 1}',
      },
    );
    
    if (searchQuery.isEmpty && selectedLocation.value == 'All Locations') {
      return allTellers;
    }
    
    return allTellers.where((teller) {
      final matchesSearch = searchQuery.isEmpty || 
          teller['name'].toLowerCase().contains(searchQuery.toLowerCase()) ||
          teller['email'].toLowerCase().contains(searchQuery.toLowerCase());
      
      final matchesLocation = selectedLocation.value == 'All Locations' || 
          teller['location'] == selectedLocation.value;
      
      return matchesSearch && matchesLocation;
    }).toList();
  }
  
  List<Map<String, dynamic>> get filteredCustomers {
    // In a real app, this would filter from a database
    // For now, we'll just simulate filtering
    final List<Map<String, dynamic>> allCustomers = List.generate(
      15,
      (index) => {
        'name': 'Customer ${index + 1}',
        'email': 'customer${index + 1}@example.com',
        'phone': '+1234567890',
        'role': 'Customer',
        'isActive': index % 4 != 0,
      },
    );
    
    if (searchQuery.isEmpty) {
      return allCustomers;
    }
    
    return allCustomers.where((customer) {
      return customer['name'].toLowerCase().contains(searchQuery.toLowerCase()) ||
          customer['email'].toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }
  
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }
  
  void updateSelectedLocation(String location) {
    selectedLocation.value = location;
  }
  
  void changeTab(int index) {
    selectedTabIndex.value = index;
  }
}

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserManagementController());
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: AppColors.primaryRed,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddUserDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Custom Tab Bar
          Container(
            color: AppColors.primaryRed,
            child: Obx(() => Row(
              children: [
                _buildTab('Tellers', 0, controller),
                _buildTab('Customers', 1, controller),
              ],
            )),
          ),
          
          // Search and Filter Bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Search Field
                Expanded(
                  child: Container(
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: TextField(
                      onChanged: controller.updateSearchQuery,
                      decoration: InputDecoration(
                        hintText: 'Search users...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14.sp,
                        ),
                        prefixIcon: Icon(Icons.search, color: Colors.grey.shade500, size: 20),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                // Location Filter - Only show for Tellers tab
                Obx(() => controller.selectedTabIndex.value == 0
                    ? Container(
                        height: 40.h,
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: controller.selectedLocation.value,
                            icon: Icon(Icons.arrow_drop_down, color: AppColors.primaryRed),
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 14.sp,
                            ),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                controller.updateSelectedLocation(newValue);
                              }
                            },
                            items: controller.locations
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      )
                    : SizedBox()),
              ],
            ),
          ),
          
          // Tab Content
          Expanded(
            child: Obx(() => controller.selectedTabIndex.value == 0
                ? _buildTellersList()
                : _buildCustomersList()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddUserDialog(),
        backgroundColor: AppColors.primaryRed,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
  
  Widget _buildTab(String title, int index, UserManagementController controller) {
    final isSelected = controller.selectedTabIndex.value == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changeTab(index),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 3.0,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 16.sp,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTellersList() {
    final controller = Get.find<UserManagementController>();
    
    return Obx(() => controller.filteredTellers.isEmpty
        ? Center(
            child: Text(
              'No tellers found',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey.shade600,
              ),
            ),
          )
        : ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            itemCount: controller.filteredTellers.length,
            itemBuilder: (context, index) {
              final teller = controller.filteredTellers[index];
              return _buildSimpleUserCard(
                name: teller['name'],
                email: teller['email'],
                phone: teller['phone'],
                isActive: teller['isActive'],
                location: teller['location'],
                role: 'Teller',
              );
            },
          ));
  }

  Widget _buildCustomersList() {
    final controller = Get.find<UserManagementController>();
    
    return Obx(() => controller.filteredCustomers.isEmpty
        ? Center(
            child: Text(
              'No customers found',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey.shade600,
              ),
            ),
          )
        : ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            itemCount: controller.filteredCustomers.length,
            itemBuilder: (context, index) {
              final customer = controller.filteredCustomers[index];
              return _buildSimpleUserCard(
                name: customer['name'],
                email: customer['email'],
                phone: customer['phone'],
                isActive: customer['isActive'],
                role: 'Customer',
                location: null,
              );
            },
          ));
  }

  Widget _buildSimpleUserCard({
    required String name,
    required String email,
    required String phone,
    required bool isActive,
    required String role,
    String? location,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 24.r,
                  backgroundColor: AppColors.primaryRed.withOpacity(0.1),
                  child: Text(
                    name.substring(0, 1),
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryRed,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                // User info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: isActive ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        phone,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (location != null) ...[
                        SizedBox(height: 2.h),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 14, color: AppColors.primaryRed),
                            SizedBox(width: 4.w),
                            Text(
                              location,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.primaryRed,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showEditUserDialog(name, role, location ?? 'L1'),
                  icon: Icon(Icons.edit, size: 18, color: AppColors.primaryRed),
                  label: Text(
                    'Edit',
                    style: TextStyle(
                      color: AppColors.primaryRed,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                SizedBox(width: 16.w),
                TextButton.icon(
                  onPressed: () => _showDeleteConfirmation(name),
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  label: const Text(
                    'Delete',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddUserDialog() {
    final selectedRole = 'Teller'.obs;
    final selectedLocation = 'L1'.obs;
    
    Get.dialog(
      AlertDialog(
        title: Text(
          'Add New User',
          style: TextStyle(
            color: AppColors.primaryRed,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Container(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primaryRed),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primaryRed),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primaryRed),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Obx(() => DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Role',
                    prefixIcon: Icon(Icons.work),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primaryRed),
                    ),
                  ),
                  value: selectedRole.value,
                  items: ['Teller', 'Customer'].map((String role) {
                    return DropdownMenuItem<String>(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    if (value != null) {
                      selectedRole.value = value;
                    }
                  },
                )),
                // Show location field only for Tellers
                Obx(() => selectedRole.value == 'Teller'
                    ? Column(
                        children: [
                          SizedBox(height: 16.h),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Location',
                              prefixIcon: Icon(Icons.location_on),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: AppColors.primaryRed),
                              ),
                            ),
                            value: selectedLocation.value,
                            items: ['L1', 'L2', 'L3', 'L4', 'L5'].map((String location) {
                              return DropdownMenuItem<String>(
                                value: location,
                                child: Text(location),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              if (value != null) {
                                selectedLocation.value = value;
                              }
                            },
                          ),
                        ],
                      )
                    : SizedBox()),
                SizedBox(height: 16.h),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primaryRed),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: Icon(Icons.lock),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primaryRed),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Success',
                'User added successfully!',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
            ),
            child: Text('Add User'),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(String name, String role, String location) {
    final selectedRole = role.obs;
    final selectedLocation = location.obs;
    
    Get.dialog(
      AlertDialog(
        title: Text(
          'Edit User: $name',
          style: TextStyle(
            color: AppColors.primaryRed,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Container(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primaryRed),
                    ),
                  ),
                  controller: TextEditingController(text: name),
                ),
                SizedBox(height: 16.h),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primaryRed),
                    ),
                  ),
                  controller: TextEditingController(
                      text: '${name.toLowerCase().replaceAll(' ', '')}@example.com'),
                ),
                SizedBox(height: 16.h),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primaryRed),
                    ),
                  ),
                  controller: TextEditingController(text: '+1234567890'),
                ),
                SizedBox(height: 16.h),
                Obx(() => DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Role',
                    prefixIcon: Icon(Icons.work),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primaryRed),
                    ),
                  ),
                  value: selectedRole.value,
                  items: ['Teller', 'Customer'].map((String role) {
                    return DropdownMenuItem<String>(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    if (value != null) {
                      selectedRole.value = value;
                    }
                  },
                )),
                // Show location field only for Tellers
                Obx(() => selectedRole.value == 'Teller'
                    ? Column(
                        children: [
                          SizedBox(height: 16.h),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Location',
                              prefixIcon: Icon(Icons.location_on),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: AppColors.primaryRed),
                              ),
                            ),
                            value: selectedLocation.value,
                            items: ['L1', 'L2', 'L3', 'L4', 'L5'].map((String location) {
                              return DropdownMenuItem<String>(
                                value: location,
                                child: Text(location),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              if (value != null) {
                                selectedLocation.value = value;
                              }
                            },
                          ),
                        ],
                      )
                    : SizedBox()),
                SizedBox(height: 16.h),
                SwitchListTile(
                  title: Text('Active Status'),
                  value: true,
                  activeColor: AppColors.primaryRed,
                  onChanged: (bool value) {},
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Success',
                'User updated successfully!',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
            ),
            child: Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(String name) {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Delete User',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text('Are you sure you want to delete $name?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Success',
                'User deleted successfully!',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
