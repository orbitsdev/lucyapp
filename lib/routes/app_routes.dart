import 'package:get/get.dart';
// Auth screens
import 'package:bettingapp/ui/screens/auth/login_screen.dart';

// Coordinator screens
import 'package:bettingapp/ui/screens/coordinator/dashboard_screen.dart' as coordinator;
import 'package:bettingapp/ui/screens/coordinator/generate_hits_screen.dart';
import 'package:bettingapp/ui/screens/coordinator/summary_screen.dart';
import 'package:bettingapp/ui/screens/coordinator/summary_detail_screen.dart';
import 'package:bettingapp/ui/screens/coordinator/bet_win_screen.dart';
import 'package:bettingapp/ui/screens/coordinator/user_management_screen.dart';
import 'package:bettingapp/ui/screens/coordinator/teller_new_bet_screen.dart';
import 'package:bettingapp/ui/screens/coordinator/teller_claim_screen.dart';
import 'package:bettingapp/ui/screens/coordinator/teller_sales_screen.dart';
import 'package:bettingapp/ui/screens/coordinator/commission_screen.dart' as coordinator_commission;

// Teller screens
import 'package:bettingapp/ui/screens/teller/dashboard_screen.dart' as teller;
import 'package:bettingapp/ui/screens/teller/new_bet_screen.dart';
import 'package:bettingapp/ui/screens/teller/claim_screen.dart';
import 'package:bettingapp/ui/screens/teller/printer_setup_screen.dart';
import 'package:bettingapp/ui/screens/teller/cancel_bet_screen.dart';
import 'package:bettingapp/ui/screens/teller/sales_screen.dart';
import 'package:bettingapp/ui/screens/shared/tally_sheet_screen.dart';
import 'package:bettingapp/ui/screens/teller/tally_sheet_screen.dart' as teller_tally;
import 'package:bettingapp/ui/screens/teller/commission_screen.dart';
import 'package:bettingapp/ui/screens/teller/combination_screen.dart';
import 'package:bettingapp/ui/screens/teller/sold_out_screen.dart';

// Customer screens
import 'package:bettingapp/ui/screens/customer/dashboard_screen.dart' as customer;
import 'package:bettingapp/ui/screens/customer/history_screen.dart';
import 'package:bettingapp/ui/screens/customer/hits_screen.dart';
import 'package:bettingapp/ui/screens/customer/place_bet_screen.dart';
import 'package:bettingapp/ui/screens/customer/results_screen.dart';

class AppRoutes {
  // Auth routes
  static const String login = '/login';
  
  // Role-specific dashboard routes
  static const String coordinatorDashboard = '/coordinator/dashboard';
  static const String tellerDashboard = '/teller/dashboard';
  static const String customerDashboard = '/customer/dashboard';
  
  // Coordinator routes
  static const String userManagement = '/coordinator/user-management';
  static const String generateHits = '/coordinator/generate-hits';
  static const String summary = '/coordinator/summary';
  static const String summaryDetail = '/coordinator/summary/detail';
  static const String betWin = '/coordinator/bet-win';
  static const String coordinatorCommission = '/coordinator/commission';
  
  // Coordinator acting as teller routes
  static const String tellerNewBet = '/coordinator/teller/new-bet';
  static const String tellerClaim = '/coordinator/teller/claim';
  static const String tellerSales = '/coordinator/teller/sales';
  
  // Teller routes
  static const String newBet = '/teller/new-bet';
  static const String claim = '/teller/claim';
  static const String printer = '/teller/printer';
  static const String cancelBet = '/teller/cancel-bet';
  static const String sales = '/teller/sales';
  static const String tally = '/teller/tally'; // Original tally sheet
  static const String tallyDashboard = '/shared/tally'; // New dashboard tally sheet
  static const String commission = '/teller/commission'; // Teller commission screen
  static const String combination = '/teller/combination';
  static const String soldOut = '/teller/sold-out';
  
  // Customer routes
  static const String placeBet = '/customer/place-bet';
  static const String history = '/customer/history';
  static const String hits = '/customer/hits';
  static const String results = '/customer/results';

  static final routes = [
    // Auth routes
    GetPage(
      name: login,
      page: () => const LoginScreen(),
      transition: Transition.fadeIn,
    ),
    
    // Coordinator routes
    GetPage(
      name: coordinatorDashboard,
      page: () => const coordinator.DashboardScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: userManagement,
      page: () => const UserManagementScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: generateHits,
      page: () => const GenerateHitsScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: summary,
      page: () => const SummaryScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: summaryDetail,
      page: () => const SummaryDetailScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: betWin,
      page: () => const BetWinScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: coordinatorCommission,
      page: () => const coordinator_commission.CommissionScreen(),
      transition: Transition.rightToLeft,
    ),
    
    // Coordinator acting as teller routes
    GetPage(
      name: tellerNewBet,
      page: () => const TellerNewBetScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: tellerClaim,
      page: () => const TellerClaimScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: tellerSales,
      page: () => const TellerSalesScreen(),
      transition: Transition.cupertino,
    ),
    
    // Teller routes
    GetPage(
      name: tellerDashboard,
      page: () => const teller.DashboardScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: newBet,
      page: () => const NewBetScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: claim,
      page: () => const ClaimScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: printer,
      page: () => const PrinterSetupScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: cancelBet,
      page: () => const CancelBetScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: sales,
      page: () => const SalesScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: tally,
      page: () => const teller_tally.TallySheetScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: tallyDashboard,
      page: () => const TallySheetScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: commission,
      page: () => const CommissionScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: combination,
      page: () => const CombinationScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: soldOut,
      page: () => const SoldOutScreen(),
      transition: Transition.cupertino,
    ),
    
    // Customer routes
    GetPage(
      name: customerDashboard,
      page: () => const customer.DashboardScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: placeBet,
      page: () => const PlaceBetScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: history,
      page: () => const HistoryScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: hits,
      page: () => const HitsScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: results,
      page: () => const ResultsScreen(),
      transition: Transition.cupertino,
    ),
  ];
}
