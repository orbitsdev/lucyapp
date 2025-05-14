import 'package:bettingapp/controllers/report_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bettingapp/utils/app_colors.dart';
import 'package:bettingapp/routes/app_routes.dart';
import 'package:bettingapp/widgets/dashboard_card.dart';
import 'package:bettingapp/controllers/auth_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
    final ReportController reportController = Get.find<ReportController>();

    @override
  void initState() {
    super.initState();
    // Fetch today's sales data when the screen loads
    _fetchTodaySales();
  }
  
  // Method to fetch today's sales data
  Future<void> _fetchTodaySales() async {
    await reportController.fetchTodaySales();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: AppColors.primaryRed,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      color: AppColors.primaryRed,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'TELLER ACCOUNT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Obx(() {
                    final user = Get.find<AuthController>().user.value;
                    final locationName = user?.location?.name ?? 'MANILA BRANCH';
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        locationName.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('Tally Sheet'),
              onTap: () {
                Navigator.pop(context);
                Get.toNamed(AppRoutes.tallyDashboard);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                // Close drawer first
                Navigator.pop(context);
                // Use AuthController to properly logout
                Get.find<AuthController>().logout();
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primaryRed,
        onRefresh: _fetchTodaySales,
        child: CustomScrollView(
        slivers: [
          // App Bar with User Info
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primaryRed,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.primaryRed,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    
                    // User Avatar
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          child: CircleAvatar(
                            radius: 38,
                            backgroundColor: Colors.white,
                            child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: 'https://ui-avatars.com/api/?name=Teller&background=C62828&color=fff',
                                placeholder: (context, url) => const CircularProgressIndicator(),
                                errorWidget: (context, url, error) => const Icon(Icons.person),
                                fit: BoxFit.cover,
                                width: 76,
                                height: 76,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.edit,
                              color: AppColors.primaryRed,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // User Name
                    Obx(() {
                      final user = Get.find<AuthController>().user.value;
                      final username = user?.username ?? 'TELLER ACCOUNT';
                      return Text(
                        username.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }),
                    
                    // Role Badge
                    Obx(() {
                      final user = Get.find<AuthController>().user.value;
                      final locationName = user?.location?.name ?? 'MANILA BRANCH';
                      return Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          locationName.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            actions: [
              // Tallysheet Button
              TextButton.icon(
                onPressed: () => Get.toNamed(AppRoutes.tallyDashboard),
                icon: const Icon(
                  Icons.receipt_long,
                  color: Colors.white,
                ),
                label: const Text(
                  'TALLYSHEET',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          // Daily Stats
          SliverToBoxAdapter(
            child: Container(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() {
                    if (reportController.isLoadingTodaySales.value) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: CircularProgressIndicator(
                            color: AppColors.primaryRed,
                            strokeWidth: 3,
                          ),
                        ),
                      );
                    } else {
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Today\'s Sales',
                                    style: TextStyle(
                                      color: AppColors.primaryRed,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '₱',
                                          style: TextStyle(
                                            color: AppColors.primaryRed,
                                            fontSize: 16,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                        TextSpan(
                                          text: reportController.salesFormatted.value.replaceAll('₱', '').trim(),
                                          style: TextStyle(
                                            color: AppColors.primaryRed,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildSalesItem(
                                'Commission Rate', 
                                reportController.commissionRateFormatted.value
                              ),
                              _buildSalesItem(
                                'Cancellations', 
                                reportController.cancellationsFormatted.value
                              ),
                            ],
                          ),
                        ],
                      );
                    }
                  }),
                ],
              ),
            ).animate()
              .fadeIn(duration: 300.ms, delay: 100.ms)
              .slideY(begin: 0.1, end: 0, duration: 300.ms),
          ),
          
          // Dashboard Cards - Teller Specific
          SliverList(
            delegate: SliverChildListDelegate([
              // Main Teller Operations
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                child: Text(
                  'BETTING OPERATIONS',
                  style: TextStyle(
                    color: AppColors.primaryRed,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              DashboardCard(
                title: 'NEW BET',
                icon: Icons.add_circle,
                color: const Color(0xFFC62828),
                route: AppRoutes.newBet,
              ),
                  DashboardCard(
                title: 'BET LIST',
                icon: Icons.format_list_numbered,
                color: const Color(0xFF3F51B5),
                route: AppRoutes.betList,
              ),
              
              DashboardCard(
                title: 'WINNING BETS (HITS)',
                icon: Icons.emoji_events,
                color: const Color(0xFF4CAF50),
                route: AppRoutes.winningBets,
              ),
             
              DashboardCard(
                title: 'CANCELLED BET',
                icon: Icons.cancel,
                color: const Color(0xFFFFC107),
                route: AppRoutes.cancelBet,
              ),
               
              

              
              // Equipment & Reports
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 24, bottom: 8),
                child: Text(
                  'EQUIPMENT & REPORTS',
                  style: TextStyle(
                    color: AppColors.primaryRed,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              DashboardCard(
                title: 'PRINTER SETUP',
                icon: Icons.print,
                color: const Color(0xFFB71C1C),
                route: AppRoutes.printer,
              ),
              
              DashboardCard(
                title: 'SALES',
                icon: Icons.bar_chart,
                color: const Color(0xFFE91E63),
                route: AppRoutes.sales,
              ),
              
          
              
              DashboardCard(
                title: 'TALLY SHEET',
                icon: Icons.list_alt,
                color: const Color(0xFFF44336),
                route: AppRoutes.tally,
              ),
              
              DashboardCard(
                title: 'COMMISSION',
                icon: Icons.monetization_on,
                color: const Color(0xFF9C27B0),
                route: AppRoutes.commission,
              ),
              
              // // Additional Tools
              // Padding(
              //   padding: const EdgeInsets.only(left: 16, top: 24, bottom: 8),
              //   child: Text(
              //     'ADDITIONAL TOOLS',
              //     style: TextStyle(
              //       color: AppColors.primaryRed,
              //       fontSize: 14,
              //       fontWeight: FontWeight.bold,
              //     ),
              //   ),
              // ),
              
              // DashboardCard(
              //   title: 'COMBINATION',
              //   icon: Icons.grid_3x3,
              //   color: const Color(0xFF9C27B0),
              //   route: AppRoutes.combination,
              // ),
              
              // DashboardCard(
              //   title: 'SOLD OUT',
              //   icon: Icons.block,
              //   color: const Color(0xFF7B1FA2),
              //   route: AppRoutes.soldOut,
              // ),
              
              const SizedBox(height: 24),
            ]),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildSalesItem(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: AppColors.primaryRed,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
