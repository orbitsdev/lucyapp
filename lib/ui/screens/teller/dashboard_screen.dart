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
      body: CustomScrollView(
        slivers: [
          // App Bar with User Info
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF00796B), // Teal Green for Teller
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: const Color(0xFF00796B),
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
                                imageUrl: 'https://ui-avatars.com/api/?name=Teller&background=00796B&color=fff',
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
                            child: const Icon(
                              Icons.edit,
                              color: Color(0xFF00796B),
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
                        'OPERATIONS STAFF',
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
            actions: [
              // Logout Button
              TextButton.icon(
                onPressed: () => Get.offAllNamed(AppRoutes.login),
                icon: const Icon(
                  Icons.logout,
                  color: Colors.white,
                ),
                label: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.white,
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
                  const Text(
                    'Today\'s Sales',
                    style: TextStyle(
                      color: Color(0xFF00796B),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '₱ 12,450',
                    style: TextStyle(
                      color: Color(0xFF00796B),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSalesItem('Tickets Sold', '45'),
                      _buildSalesItem('Claims Processed', '12'),
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
              const Padding(
                padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
                child: Text(
                  'BETTING OPERATIONS',
                  style: TextStyle(
                    color: Color(0xFF00796B),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              DashboardCard(
                title: 'NEW BET',
                icon: Icons.add_circle,
                color: const Color(0xFF00897B),
                route: AppRoutes.newBet,
              ),
              
              DashboardCard(
                title: 'CLAIM',
                icon: Icons.monetization_on,
                color: const Color(0xFF009688),
                route: AppRoutes.claim,
              ),
              
              DashboardCard(
                title: 'CANCEL DOC',
                icon: Icons.cancel,
                color: const Color(0xFF26A69A),
                route: AppRoutes.cancelDoc,
              ),
              
              // Equipment & Reports
              const Padding(
                padding: EdgeInsets.only(left: 16, top: 24, bottom: 8),
                child: Text(
                  'EQUIPMENT & REPORTS',
                  style: TextStyle(
                    color: Color(0xFF00796B),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              DashboardCard(
                title: 'PRINTER SETUP',
                icon: Icons.print,
                color: const Color(0xFF4DB6AC),
                route: AppRoutes.printer,
              ),
              
              DashboardCard(
                title: 'SALES',
                icon: Icons.bar_chart,
                color: const Color(0xFF80CBC4),
                route: AppRoutes.sales,
              ),
              
              DashboardCard(
                title: 'TALLY SHEET',
                icon: Icons.list_alt,
                color: const Color(0xFFB2DFDB),
                route: AppRoutes.tally,
              ),
              
              // Additional Tools
              const Padding(
                padding: EdgeInsets.only(left: 16, top: 24, bottom: 8),
                child: Text(
                  'ADDITIONAL TOOLS',
                  style: TextStyle(
                    color: Color(0xFF00796B),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              DashboardCard(
                title: 'COMBINATION',
                icon: Icons.grid_3x3,
                color: const Color(0xFF004D40),
                route: AppRoutes.combination,
              ),
              
              DashboardCard(
                title: 'SOLD OUT',
                icon: Icons.block,
                color: const Color(0xFF00695C),
                route: AppRoutes.soldOut,
              ),
              
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
          style: const TextStyle(
            color: Color(0xFF00796B),
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
