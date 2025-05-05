# Lucky Betting App Structure

This document outlines the structure for the Lucky Betting app (formerly "GAMBLE Betting Management System"), organizing screens by user role and module to avoid confusion and improve maintainability.

## 1. User Roles

The application supports three distinct user roles:

```
+----------------+     +----------------+     +----------------+
| Coordinator    |     | Teller         |     | Customer       |
| (Admin)        |     | (Agent)        |     | (Regular User) |
+----------------+     +----------------+     +----------------+
```

### Role Descriptions

1. **Coordinator**
   - Administrative access
   - Manages tellers and customers
   - Access to all reports and configurations
   - Can set winning numbers and manage games
   - Manages commission rates for tellers (5%, 10%, or 15%)
   - Sets schedules for betting (2pm, 5pm, 9pm)

2. **Teller**
   - Processes bets and claims
   - Access to sales reports and tally sheets
   - Can cancel bets and manage printer settings
   - Views personal commission information
   - Processes claims using QR code scanning
   - Works within schedules set by coordinators

3. **Customer**
   - Places bets
   - Views betting history
   - Checks results and winning status

## 2. Login Screen

The login screen includes options for users to identify their role:

```
+-----------------------------------------------+
|                                               |
|              Lucky Betting App                |
|                                               |
+-----------------------------------------------+
|                                               |
|  Username: [                            ]     |
|                                               |
|  Password: [                            ]     |
|                                               |
+-----------------------------------------------+
|                                               |
|  Select your role:                            |
|                                               |
|  [Coordinator]    [Teller]    [Customer]      |
|                                               |
+-----------------------------------------------+
|                                               |
|              [     Login     ]                |
|                                               |
+-----------------------------------------------+
```

## 3. Current Directory Structure

The app's screens are organized by module and role to improve maintainability:

```
lib/
├── controllers/
│   ├── auth/
│   │   └── auth_controller.dart
│   ├── coordinator/
│   │   └── coordinator_dashboard_controller.dart
│   ├── customer/
│   │   └── customer_dashboard_controller.dart
│   ├── login_controller.dart
│   └── teller/
│       └── teller_dashboard_controller.dart
├── main.dart
├── models/
│   └── (placeholder for data models)
├── routes/
│   └── app_routes.dart
├── services/
│   ├── api_service.dart
│   ├── auth_service.dart
│   └── storage_service.dart
├── ui/
│   ├── screens/
│   │   ├── auth/
│   │   │   └── login_screen.dart
│   │   ├── coordinator/
│   │   │   ├── bet_win_screen.dart
│   │   │   ├── commission_screen.dart
│   │   │   ├── dashboard_screen.dart
│   │   │   ├── generate_hits_screen.dart
│   │   │   ├── summary_detail_screen.dart
│   │   │   ├── summary_screen.dart
│   │   │   ├── teller_claim_screen.dart
│   │   │   ├── teller_new_bet_screen.dart
│   │   │   ├── teller_sales_screen.dart
│   │   │   └── user_management_screen.dart
│   │   ├── customer/
│   │   │   ├── dashboard_screen.dart
│   │   │   ├── history_screen.dart
│   │   │   ├── hits_screen.dart
│   │   │   ├── place_bet_screen.dart
│   │   │   └── results_screen.dart
│   │   ├── shared/
│   │   │   └── tally_sheet_screen.dart
│   │   └── teller/
│   │       ├── cancel_bet_screen.dart
│   │       ├── claim_screen.dart
│   │       ├── combination_screen.dart
│   │       ├── commission_screen.dart
│   │       ├── dashboard_screen.dart
│   │       ├── new_bet_screen.dart
│   │       ├── printer_setup_screen.dart
│   │       ├── sales_screen.dart
│   │       ├── sold_out_screen.dart
│   │       └── tally_sheet_screen.dart
│   └── widgets/
│       ├── common/
│       │   ├── app_bar.dart
│       │   ├── dashboard_card.dart
│       │   └── drawer.dart
│       ├── coordinator/
│       │   └── (coordinator-specific widgets)
│       ├── teller/
│       │   └── (teller-specific widgets)
│       └── customer/
│           └── (customer-specific widgets)
├── utils/
│   ├── app_colors.dart
│   ├── constants.dart
│   └── helpers.dart
└── widgets/
    └── dashboard_card.dart
```

## 4. Screen Access by Role

### Coordinator Access
```
- Login Screen
- Coordinator Dashboard
- User Management Screen
- Game Configuration Screen
- Generate Hits Screen
- Summary Screen
- Summary Detail Screen
- Commission Screen
- Financial Reports Screen
- Teller Functions:
  - Teller New Bet Screen
  - Teller Claim Screen
  - Teller Sales Screen
- All Teller Screens (for oversight)
```

### Teller Access
```
- Login Screen
- Teller Dashboard
- New Bet Screen
- Claim Screen
- Cancel Bet Screen
- Printer Setup Screen
- Sales Screen
- Tally Sheet Screen
- Commission Screen
- Combination Screen
```

### Customer Access
```
- Login Screen
- Customer Dashboard
- Place Bet Screen
- History Screen
- Results Screen
```

## 5. Navigation Flow by Role

### Coordinator Flow
```
Login (as Coordinator) → Coordinator Dashboard → [Access to all administrative functions]
```

Visual representation:
```
+----------------+     +----------------+     +----------------+
| Login Screen   | --> | Coordinator    | --> | Administrative |
| (Select Role)  |     | Dashboard      |     | Functions      |
+----------------+     +----------------+     +----------------+
```

### Teller Flow
```
Login (as Teller) → Teller Dashboard → [Access to betting and transaction functions]
```

Visual representation:
```
+----------------+     +----------------+     +----------------+
| Login Screen   | --> | Teller         | --> | Betting and    |
| (Select Role)  |     | Dashboard      |     | Transactions   |
+----------------+     +----------------+     +----------------+
```

### Customer Flow
```
Login (as Customer) → Customer Dashboard → [Access to betting and viewing functions]
```

Visual representation:
```
+----------------+     +----------------+     +----------------+
| Login Screen   | --> | Customer       | --> | Betting and    |
| (Select Role)  |     | Dashboard      |     | Viewing        |
+----------------+     +----------------+     +----------------+
```

## 6. Recent UI Updates

### Completed Updates
1. Changed app name from "GAMBLE Betting Management System" to "Lucky Betting app"
2. Changed primary color from blue to red throughout the app
3. Removed Tally Sheet card from teller dashboard and added it to drawer menu
4. Updated teller commission screen to match coordinator's layout
5. Removed redundant "Today's Commission" section from teller dashboard
6. Fixed issues with tally sheet navigation
7. Added display of teller location/place in header
8. Updated Claims screen to use QR code scanning instead of photos

### Upcoming Updates
1. Display commission information with dynamic percentage rates (5%, 10%, or 15%)
2. Update Claims Processed section to show commission percentage
3. Update Ticket Sold to show bet number information
4. Modify Bet Amount functionality for custom values
5. Update Schedule functionality to only display active schedules
6. Rename "Cancel Doc" to "Cancel Bet"
7. Implement schedule filter for cancelled bets

## 7. Role-Based UI Customization

Each role will have a distinct UI experience with appropriate color schemes and layouts:

### Coordinator UI
- Primary color: Red (AppColors.primaryRed)
- Comprehensive dashboard with analytics
- Access to administrative tools
- Tally sheet access from drawer menu

### Teller UI
- Primary color: Red (AppColors.primaryRed)
- Transaction-focused dashboard
- Quick access to betting and claiming functions
- Display of location/place in header
- Commission information with dynamic percentage rates
- Tally sheet access from drawer menu

### Customer UI
- Primary color: Red (AppColors.primaryRed)
- Simple, intuitive interface
- Focus on placing bets and viewing results

This structure ensures that each user type has access to the appropriate functionality while maintaining a clean and organized codebase. The modular approach also makes it easier to add new features or modify existing ones without affecting the entire application.
