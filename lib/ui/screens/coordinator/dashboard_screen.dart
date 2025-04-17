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
                                imageUrl: 'https://ui-avatars.com/api/?name=Coordinator&background=d32f2f&color=fff',
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
                      'COORDINATOR ADMIN',
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
                        'SYSTEM ADMINISTRATOR',
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
          
          // Lucky Bet Analytics
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
                    'Lucky Bet Analytics',
                    style: TextStyle(
                      color: AppColors.primaryRed,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatusItem(Icons.people, 'Total Teller', '24'),
                      _buildStatusItem(Icons.attach_money, 'Total Sales', '₱145,780'),
                      _buildStatusItem(Icons.trending_up, 'Total Hits', '32%'),
                    ],
                  ),
                ],
              ),
            ).animate()
              .fadeIn(duration: 300.ms, delay: 100.ms)
              .slideY(begin: 0.1, end: 0, duration: 300.ms),
          ),
          
          // Dashboard Cards - Coordinator Specific
          SliverList(
            delegate: SliverChildListDelegate([
              // Coordinator Features
              DashboardCard(
                title: 'USER MANAGEMENT',
                icon: Icons.people_alt,
                color: AppColors.primaryRed.withOpacity(0.9),
                route: AppRoutes.userManagement,
              ),
              
              DashboardCard(
                title: 'GENERATE HITS',
                icon: Icons.casino,
                color: AppColors.primaryRed.withOpacity(0.8),
                route: AppRoutes.generateHits,
              ),
              
              DashboardCard(
                title: 'SUMMARY REPORTS',
                icon: Icons.summarize,
                color: AppColors.primaryRed.withOpacity(0.7),
                route: AppRoutes.summary,
              ),
              
              DashboardCard(
                title: 'BET WIN ANALYSIS',
                icon: Icons.analytics,
                color: AppColors.primaryRed.withOpacity(0.6),
                route: AppRoutes.betWin,
              ),
              
              // Additional Admin Features
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'SYSTEM ADMINISTRATION',
                  style: TextStyle(
                    color: AppColors.primaryRed,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              
              DashboardCard(
                title: 'GAME CONFIGURATION',
                icon: Icons.settings,
                color: AppColors.primaryRed.withOpacity(0.5),
                route: AppRoutes.userManagement, // Replace with proper route when available
              ),
              
              DashboardCard(
                title: 'FINANCIAL REPORTS',
                icon: Icons.account_balance,
                color: AppColors.primaryRed.withOpacity(0.4),
                route: AppRoutes.summary, // Replace with proper route when available
              ),
              
              const SizedBox(height: 24),
            ]),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusItem(IconData icon, String title, String value) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primaryRed,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.primaryRed,
            fontSize: 18,
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
