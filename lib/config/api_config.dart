class ApiConfig {
  // LuckyBet Admin API Configuration
  
  // Base URLs
  static const String stagingBaseUrl = 'http://167.99.76.120';
  static const String productionBaseUrl = 'http://167.99.76.120';
  static const String baseUrl = 'https://luckybet-api.com/api';
  
  // Auth endpoints
  static const String register = '/register';
  static const String login = '/login';
  static const String logout = '/logout';
  static const String user = '/user';
  
  // Betting endpoints
  static const String bets = '/betting/list';
  static const String createBet = '/betting/place';
  static const String cancelBet = '/betting/cancel';
  static const String cancelBetByTicket = '/betting/cancel-by-ticket/';
  static const String availableDraws = '/betting/available-draws';
  static const String cancelledBets = '/betting/cancelled';
  
  // Dropdown endpoints
  static const String gameTypes = '/dropdown/game-types';
  static const String schedules = '/dropdown/schedules';
  static const String draws = '/dropdown/draws';
  static const String availableDates = '/dropdown/available-dates';
  
  // Reports endpoints
  static const String reports = '/reports';
  static const String salesReport = '/reports/sales';
  static const String tallySheet = '/reports/tallysheet';
  static const String detailedTallySheet = '/teller/detailed-tallysheet';
  static const String tellerTodaySales = '/teller/today-sales';
}
