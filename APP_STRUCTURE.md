# LuckyBet App Structure

This document outlines the structure for the LuckyBet app, organizing screens by user role and module to avoid confusion and improve maintainability.

## 1. User Roles

The application will support three distinct user roles:

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
   - Manages commission rates for tellers

2. **Teller**
   - Processes bets and claims
   - Access to sales reports and tally sheets
   - Can cancel bets and manage printer settings
   - Views personal commission information

3. **Customer**
   - Places bets
   - Views betting history
   - Checks results and winning status

## 2. Login Screen Redesign

The login screen includes three clear options for users to identify their role:

```
+-----------------------------------------------+
|                                               |
|              LuckyBet                         |
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

## 3. Proposed Directory Structure

The app's screens will be reorganized by module and role to improve maintainability:

```
lib/
├── controllers/
│   ├── auth/
│   │   ├── login_controller.dart
│   │   └── auth_controller.dart
│   ├── coordinator/
│   │   ├── admin_controller.dart
│   │   ├── reports_controller.dart
│   │   ├── commission_controller.dart
│   │   └── game_management_controller.dart
│   ├── teller/
│   │   ├── betting_controller.dart
│   │   ├── claims_controller.dart
│   │   ├── commission_controller.dart
│   │   └── sales_controller.dart
│   └── customer/
│       ├── bet_controller.dart
│       └── history_controller.dart
├── models/
│   ├── user_model.dart
│   ├── game_model.dart
│   ├── bet_model.dart
│   ├── commission_model.dart
│   └── ...
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
│   │   │   ├── dashboard_screen.dart
│   │   │   ├── generate_hits_screen.dart
│   │   │   ├── summary_screen.dart
│   │   │   ├── commission_screen.dart
│   │   │   └── user_management_screen.dart
│   │   ├── teller/
│   │   │   ├── dashboard_screen.dart
│   │   │   ├── new_bet_screen.dart
│   │   │   ├── claim_screen.dart
│   │   │   ├── cancel_bet_screen.dart
│   │   │   ├── printer_setup_screen.dart
│   │   │   ├── sales_screen.dart
│   │   │   ├── tally_sheet_screen.dart
│   │   │   ├── commission_screen.dart
│   │   │   └── combination_screen.dart
│   │   └── customer/
│   │       ├── dashboard_screen.dart
│   │       ├── place_bet_screen.dart
│   │       ├── history_screen.dart
│   │       └── results_screen.dart
│   └── widgets/
│       ├── common/
│       │   ├── app_bar.dart
│       │   ├── drawer.dart
│       │   └── ...
│       ├── coordinator/
│       │   └── ...
│       ├── teller/
│       │   └── ...
│       └── customer/
│           └── ...
├── utils/
│   ├── app_colors.dart
│   ├── constants.dart
│   └── helpers.dart
└── main.dart
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

## 6. Implementation Strategy

### Phase 1: Restructure Project
1. Create the new directory structure
2. Move existing screens to appropriate folders
3. Update imports and references

### Phase 2: Role-Based Authentication
1. Modify login screen to include role selection
2. Implement role-based routing
3. Add role-specific controllers

### Phase 3: Dashboard Customization
1. Create role-specific dashboards
2. Implement appropriate navigation for each role
3. Add role-specific widgets and components

### Phase 4: Access Control
1. Implement middleware for role-based access control
2. Add permission checks to sensitive operations
3. Create role-specific API endpoints

## 7. Role-Based UI Customization

Each role will have a distinct UI experience with appropriate color schemes and layouts:

### Coordinator UI
- Primary color: Red (#FF0000)
- Comprehensive dashboard with analytics
- Access to administrative tools

### Teller UI
- Primary color: Teal Green (#00796b)
- Transaction-focused dashboard
- Quick access to betting and claiming functions

### Customer UI
- Primary color: Purple (#6a1b9a)
- Simple, intuitive interface
- Focus on placing bets and viewing results

This structure ensures that each user type has access to the appropriate functionality while maintaining a clean and organized codebase. The modular approach also makes it easier to add new features or modify existing ones without affecting the entire application.
