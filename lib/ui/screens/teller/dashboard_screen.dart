import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bettingapp/utils/app_colors.dart';
import 'package:bettingapp/routes/app_routes.dart';
import 'package:bettingapp/widgets/dashboard_card.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'MANILA BRANCH',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
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
              onTap: () => Get.offAllNamed(AppRoutes.login),
            ),
          ],
        ),
      ),
      body: CustomScrollView(
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
                    const Text(
                      'TELLER ACCOUNT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    // Role Badge
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'MANILA BRANCH',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
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
                          Text(
                            '₱ 12,450',
                            style: TextStyle(
                              color: AppColors.primaryRed,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
                      _buildSalesItem('Bet Numbers', '45'),
                      _buildSalesItem('Commission Rate', '10%'),
                      _buildSalesItem('Cancellations', '3'),
                    ],
                  ),
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
                title: 'CLAIM',
                icon: Icons.monetization_on,
                color: const Color(0xFFE57373),
                route: AppRoutes.claim,
              ),
              
              DashboardCard(
                title: 'CANCEL BET',
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
