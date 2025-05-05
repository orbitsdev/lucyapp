

class ApiConfig {
  // Base URLs
  static const String stagingBaseUrl = 'http://167.99.76.120';
  static const String productionBaseUrl = 'http://167.99.76.120';
  static const String baseUrl = 'https://your-api-domain.com/api';
  
  // Auth endpoints
  static const String register = '/register';
  static const String login = '/login';
  static const String logout = '/logout';
  static const String user = '/user';
  
  // User endpoints
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/profile/update';
  
  // Betting endpoints
  static const String bets = '/bets';
  static const String createBet = '/bets/create';
  static const String cancelBet = '/bets/cancel';
  
  // Claims endpoints
  static const String claims = '/claims';
  static const String processClaim = '/claims/process';
  
  // Results endpoints
  static const String results = '/results';
  static const String todayResults = '/results/today';
  
  // Commission endpoints
  static const String commissions = '/commissions';
  static const String commissionRates = '/commissions/rates';
  
  // Schedule endpoints
  static const String schedules = '/schedules';
  static const String activeSchedules = '/schedules/active';
  
  // Dashboard endpoints
  static const String dashboard = '/dashboard';
  static const String tellerDashboard = '/dashboard/teller';
  static const String coordinatorDashboard = '/dashboard/coordinator';
  
  // Reports endpoints
  static const String reports = '/reports';
  static const String salesReport = '/reports/sales';
  static const String claimsReport = '/reports/claims';
  static const String tallySheet = '/reports/tally-sheet';
}
