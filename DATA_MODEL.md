# GAMBLE Mobile App Data Model

This document outlines the complete data model for the GAMBLE Mobile App, including entity relationships, data collections, and authentication requirements. The backend will be implemented using Laravel.

## 1. Authentication Data Model

```
+----------------+     +----------------+     +----------------+
| Users          | --> | Roles          | --> | Permissions    |
| (Account Info) |     | (User Types)   |     | (Access Rights)|
+----------------+     +----------------+     +----------------+
```

### Role Descriptions

1. **Coordinator**
   - Administrative access
   - Manages tellers and customers
   - Access to all reports and configurations
   - Can set winning numbers and manage games

2. **Teller**
   - Processes bets and claims
   - Access to sales reports and tally sheets
   - Can cancel tickets and manage printer settings

3. **Customer**
   - Places bets
   - Views betting history
   - Checks results and winning status

### Users Table
```
+-------------------+------------------+--------------------------------------+
| Field             | Type             | Description                          |
+-------------------+------------------+--------------------------------------+
| id                | bigint(unsigned) | Primary key                          |
| username          | string           | Unique username for login            |
| email             | string           | Unique email address                 |
| password          | string           | Encrypted password                   |
| role_id           | bigint(unsigned) | Foreign key to roles table           |
| first_name        | string           | User's first name                    |
| last_name         | string           | User's last name                     |
| phone_number      | string           | Contact phone number                 |
| address           | text             | Physical address                     |
| profile_image     | string           | Path to profile image                |
| last_login_at     | timestamp        | Last login timestamp                 |
| is_active         | boolean          | Account status                       |
| remember_token    | string           | For "remember me" functionality      |
| email_verified_at | timestamp        | When email was verified              |
| created_at        | timestamp        | Record creation timestamp            |
| updated_at        | timestamp        | Record update timestamp              |
+-------------------+------------------+--------------------------------------+
```

### Roles Table
```
+-------------------+------------------+--------------------------------------+
| Field             | Type             | Description                          |
+-------------------+------------------+--------------------------------------+
| id                | bigint(unsigned) | Primary key                          |
| name              | string           | Role name (Coordinator, Teller, Customer) |
| description       | text             | Role description                     |
| created_at        | timestamp        | Record creation timestamp            |
| updated_at        | timestamp        | Record update timestamp              |
+-------------------+------------------+--------------------------------------+
```

### Permissions Table
```
+-------------------+------------------+--------------------------------------+
| Field             | Type             | Description                          |
+-------------------+------------------+--------------------------------------+
| id                | bigint(unsigned) | Primary key                          |
| name              | string           | Permission name                      |
| description       | text             | Permission description               |
| created_at        | timestamp        | Record creation timestamp            |
| updated_at        | timestamp        | Record update timestamp              |
+-------------------+------------------+--------------------------------------+
```

### Role_Permission Table (Pivot)
```
+-------------------+------------------+--------------------------------------+
| Field             | Type             | Description                          |
+-------------------+------------------+--------------------------------------+
| role_id           | bigint(unsigned) | Foreign key to roles table           |
| permission_id     | bigint(unsigned) | Foreign key to permissions table     |
| created_at        | timestamp        | Record creation timestamp            |
| updated_at        | timestamp        | Record update timestamp              |
+-------------------+------------------+--------------------------------------+
```

## 2. Game Management Data Model

```
+----------------+     +----------------+     +----------------+
| Games          | --> | Game Types     | --> | Draw Schedules |
| (Base Info)    |     | (Variations)   |     | (Timing)       |
+----------------+     +----------------+     +----------------+
        |                      |                      |
        v                      v                      v
+----------------+     +----------------+     +----------------+
| Combinations   |     | Sold Out       |     | Winning        |
| (Number Sets)  |     | Numbers        |     | Numbers        |
+----------------+     +----------------+     +----------------+
```

### Games Table
```
+-------------------+------------------+--------------------------------------+
| Field             | Type             | Description                          |
+-------------------+------------------+--------------------------------------+
| id                | bigint(unsigned) | Primary key                          |
| name              | string           | Game name                            |
| description       | text             | Game description                     |
| is_active         | boolean          | Game status                          |
| min_number        | integer          | Minimum number in selection range    |
| max_number        | integer          | Maximum number in selection range    |
| selection_count   | integer          | How many numbers to select           |
| created_at        | timestamp        | Record creation timestamp            |
| updated_at        | timestamp        | Record update timestamp              |
+-------------------+------------------+--------------------------------------+
```

### Game Types Table
```
+-------------------+------------------+--------------------------------------+
| Field             | Type             | Description                          |
+-------------------+------------------+--------------------------------------+
| id                | bigint(unsigned) | Primary key                          |
| game_id           | bigint(unsigned) | Foreign key to games table           |
| name              | string           | Type name (e.g., Straight, Rumble)   |
| description       | text             | Type description                     |
| multiplier        | decimal          | Payout multiplier                    |
| is_active         | boolean          | Type status                          |
| created_at        | timestamp        | Record creation timestamp            |
| updated_at        | timestamp        | Record update timestamp              |
+-------------------+------------------+--------------------------------------+
```

### Draw Schedules Table
```
+-------------------+------------------+--------------------------------------+
| Field             | Type             | Description                          |
+-------------------+------------------+--------------------------------------+
| id                | bigint(unsigned) | Primary key                          |
| game_id           | bigint(unsigned) | Foreign key to games table           |
| draw_time         | time             | Time of draw                         |
| draw_days         | json             | Days of week for draw                |
| cut_off_time      | time             | Betting cut-off time                 |
| is_active         | boolean          | Schedule status                      |
| created_at        | timestamp        | Record creation timestamp            |
| updated_at        | timestamp        | Record update timestamp              |
+-------------------+------------------+--------------------------------------+
```

### Winning Numbers Table
```
+-------------------+------------------+--------------------------------------+
| Field             | Type             | Description                          |
+-------------------+------------------+--------------------------------------+
| id                | bigint(unsigned) | Primary key                          |
| game_id           | bigint(unsigned) | Foreign key to games table           |
| draw_date         | date             | Date of the draw                     |
| draw_time         | time             | Time of the draw                     |
| numbers           | json             | Winning number combination           |
| created_by        | bigint(unsigned) | User who entered the numbers         |
| created_at        | timestamp        | Record creation timestamp            |
| updated_at        | timestamp        | Record update timestamp              |
+-------------------+------------------+--------------------------------------+
```

### Sold Out Numbers Table
```
+-------------------+------------------+--------------------------------------+
| Field             | Type             | Description                          |
+-------------------+------------------+--------------------------------------+
| id                | bigint(unsigned) | Primary key                          |
| game_id           | bigint(unsigned) | Foreign key to games table           |
| game_type_id      | bigint(unsigned) | Foreign key to game_types table      |
| draw_date         | date             | Date of the draw                     |
| draw_time         | time             | Time of the draw                     |
| numbers           | json             | Sold out number combination          |
| created_by        | bigint(unsigned) | User who marked as sold out          |
| created_at        | timestamp        | Record creation timestamp            |
| updated_at        | timestamp        | Record update timestamp              |
+-------------------+------------------+--------------------------------------+
```

## 3. Betting Data Model

```
+----------------+     +----------------+     +----------------+
| Tickets        | --> | Bet Details    | --> | Bet Numbers    |
| (Master Record)|     | (Game Info)    |     | (Selections)   |
+----------------+     +----------------+     +----------------+
        |                                             |
        v                                             v
+----------------+                           +----------------+
| Transactions   |                           | Hits           |
| (Financial)    |                           | (Winning Bets) |
+----------------+                           +----------------+
```

### Tickets Table
```
+-------------------+------------------+--------------------------------------+
| Field             | Type             | Description                          |
+-------------------+------------------+--------------------------------------+
| id                | bigint(unsigned) | Primary key                          |
| ticket_number     | string           | Unique ticket identifier             |
| user_id           | bigint(unsigned) | Foreign key to users table           |
| total_amount      | decimal          | Total ticket amount                  |
| status            | enum             | Active, Cancelled, Claimed, Expired  |
| created_at        | timestamp        | Record creation timestamp            |
| updated_at        | timestamp        | Record update timestamp              |
+-------------------+------------------+--------------------------------------+
```

### Bet Details Table
```
+-------------------+------------------+--------------------------------------+
| Field             | Type             | Description                          |
+-------------------+------------------+--------------------------------------+
| id                | bigint(unsigned) | Primary key                          |
| ticket_id         | bigint(unsigned) | Foreign key to tickets table         |
| game_id           | bigint(unsigned) | Foreign key to games table           |
| game_type_id      | bigint(unsigned) | Foreign key to game_types table      |
| draw_date         | date             | Date of the draw                     |
| draw_time         | time             | Time of the draw                     |
| amount            | decimal          | Bet amount                           |
| potential_winnings| decimal          | Potential winning amount             |
| status            | enum             | Active, Won, Lost, Cancelled         |
| created_at        | timestamp        | Record creation timestamp            |
| updated_at        | timestamp        | Record update timestamp              |
+-------------------+------------------+--------------------------------------+
```

### Bet Numbers Table
```
+-------------------+------------------+--------------------------------------+
| Field             | Type             | Description                          |
+-------------------+------------------+--------------------------------------+
| id                | bigint(unsigned) | Primary key                          |
| bet_detail_id     | bigint(unsigned) | Foreign key to bet_details table     |
| numbers           | json             | Selected number combination          |
| created_at        | timestamp        | Record creation timestamp            |
| updated_at        | timestamp        | Record update timestamp              |
+-------------------+------------------+--------------------------------------+
```

### Hits Table
```
+-------------------+------------------+--------------------------------------+
| Field             | Type             | Description                          |
+-------------------+------------------+--------------------------------------+
| id                | bigint(unsigned) | Primary key                          |
| bet_detail_id     | bigint(unsigned) | Foreign key to bet_details table     |
| winning_number_id | bigint(unsigned) | Foreign key to winning_numbers table |
| win_amount        | decimal          | Winning amount                       |
| is_claimed        | boolean          | Whether prize has been claimed       |
| claimed_at        | timestamp        | When prize was claimed               |
| claimed_by        | bigint(unsigned) | User who processed the claim         |
| created_at        | timestamp        | Record creation timestamp            |
| updated_at        | timestamp        | Record update timestamp              |
+-------------------+------------------+--------------------------------------+
```

### Transactions Table
```
+-------------------+------------------+--------------------------------------+
| Field             | Type             | Description                          |
+-------------------+------------------+--------------------------------------+
| id                | bigint(unsigned) | Primary key                          |
| user_id           | bigint(unsigned) | Foreign key to users table           |
| ticket_id         | bigint(unsigned) | Foreign key to tickets table (opt)   |
| hit_id            | bigint(unsigned) | Foreign key to hits table (opt)      |
| type              | enum             | Sale, Claim, Cancellation, Adjustment|
| amount            | decimal          | Transaction amount                   |
| reference_number  | string           | Reference number                     |
| notes             | text             | Transaction notes                    |
| created_at        | timestamp        | Record creation timestamp            |
| updated_at        | timestamp        | Record update timestamp              |
+-------------------+------------------+--------------------------------------+
```

## 4. System Configuration Data Model

```
+----------------+     +----------------+     +----------------+
| Settings       | --> | Printers       | --> | Terminals      |
| (App Config)   |     | (Print Devices)|     | (Devices)      |
+----------------+     +----------------+     +----------------+
```

### Settings Table
```
+-------------------+------------------+--------------------------------------+
| Field             | Type             | Description                          |
+-------------------+------------------+--------------------------------------+
| id                | bigint(unsigned) | Primary key                          |
| key               | string           | Setting key                          |
| value             | text             | Setting value                        |
| description       | text             | Setting description                  |
| created_at        | timestamp        | Record creation timestamp            |
| updated_at        | timestamp        | Record update timestamp              |
+-------------------+------------------+--------------------------------------+
```

### Printers Table
```
+-------------------+------------------+--------------------------------------+
| Field             | Type             | Description                          |
+-------------------+------------------+--------------------------------------+
| id                | bigint(unsigned) | Primary key                          |
| user_id           | bigint(unsigned) | Foreign key to users table           |
| name              | string           | Printer name                         |
| ip_address        | string           | Printer IP address                   |
| port              | integer          | Printer port                         |
| model             | string           | Printer model                        |
| is_default        | boolean          | Whether it's the default printer     |
| is_active         | boolean          | Printer status                       |
| created_at        | timestamp        | Record creation timestamp            |
| updated_at        | timestamp        | Record update timestamp              |
+-------------------+------------------+--------------------------------------+
```

### Terminals Table
```
+-------------------+------------------+--------------------------------------+
| Field             | Type             | Description                          |
+-------------------+------------------+--------------------------------------+
| id                | bigint(unsigned) | Primary key                          |
| user_id           | bigint(unsigned) | Foreign key to users table           |
| name              | string           | Terminal name                        |
| device_id         | string           | Unique device identifier             |
| is_active         | boolean          | Terminal status                      |
| last_activity     | timestamp        | Last activity timestamp              |
| created_at        | timestamp        | Record creation timestamp            |
| updated_at        | timestamp        | Record update timestamp              |
+-------------------+------------------+--------------------------------------+
```

## 5. Reporting Data Model

```
+----------------+     +----------------+     +----------------+
| Sales Reports  | --> | Tally Sheets   | --> | Summary Reports|
| (Daily Sales)  |     | (Accounting)   |     | (Aggregated)   |
+----------------+     +----------------+     +----------------+
```

### Sales Reports Table
```
+-------------------+------------------+--------------------------------------+
| Field             | Type             | Description                          |
+-------------------+------------------+--------------------------------------+
| id                | bigint(unsigned) | Primary key                          |
| user_id           | bigint(unsigned) | Foreign key to users table           |
| report_date       | date             | Report date                          |
| total_sales       | decimal          | Total sales amount                   |
| total_tickets     | integer          | Total number of tickets sold         |
| game_breakdown    | json             | Sales breakdown by game              |
| created_at        | timestamp        | Record creation timestamp            |
| updated_at        | timestamp        | Record update timestamp              |
+-------------------+------------------+--------------------------------------+
```

### Tally Sheets Table
```
+-------------------+------------------+--------------------------------------+
| Field             | Type             | Description                          |
+-------------------+------------------+--------------------------------------+
| id                | bigint(unsigned) | Primary key                          |
| user_id           | bigint(unsigned) | Foreign key to users table           |
| report_date       | date             | Report date                          |
| opening_balance   | decimal          | Opening balance                      |
| total_sales       | decimal          | Total sales                          |
| total_claims      | decimal          | Total claims paid                    |
| total_cancellations| decimal         | Total cancellations                  |
| closing_balance   | decimal          | Closing balance                      |
| remarks           | text             | Additional remarks                   |
| created_at        | timestamp        | Record creation timestamp            |
| updated_at        | timestamp        | Record update timestamp              |
+-------------------+------------------+--------------------------------------+
```

### Summary Reports Table
```
+-------------------+------------------+--------------------------------------+
| Field             | Type             | Description                          |
+-------------------+------------------+--------------------------------------+
| id                | bigint(unsigned) | Primary key                          |
| report_type       | enum             | Daily, Weekly, Monthly, Custom       |
| start_date        | date             | Start date of report period          |
| end_date          | date             | End date of report period            |
| total_sales       | decimal          | Total sales amount                   |
| total_claims      | decimal          | Total claims paid                    |
| total_cancellations| decimal         | Total cancellations                  |
| net_income        | decimal          | Net income                           |
| user_breakdown    | json             | Breakdown by user                    |
| game_breakdown    | json             | Breakdown by game                    |
| created_by        | bigint(unsigned) | User who generated the report        |
| created_at        | timestamp        | Record creation timestamp            |
| updated_at        | timestamp        | Record update timestamp              |
+-------------------+------------------+--------------------------------------+
```

## 6. Entity Relationship Diagram (ERD)

```
+-------------+     +-------------+     +-------------+
| Users       |<----| Roles       |<----| Permissions |
+-------------+     +-------------+     +-------------+
      |
      |
      v
+-------------+     +-------------+     +-------------+
| Tickets     |---->| Bet Details |---->| Bet Numbers |
+-------------+     +-------------+     +-------------+
      |                   |                   |
      |                   |                   |
      v                   v                   v
+-------------+     +-------------+     +-------------+
| Transactions|     | Games       |     | Hits        |
+-------------+     +-------------+     +-------------+
                          |
                          |
                          v
                    +-------------+     +-------------+
                    | Game Types  |     | Draw        |
                    |             |     | Schedules   |
                    +-------------+     +-------------+
                          |
                          |
                          v
                    +-------------+     +-------------+
                    | Winning     |     | Sold Out    |
                    | Numbers     |     | Numbers     |
                    +-------------+     +-------------+
```

## 7. Laravel API Endpoints

### Authentication Endpoints (Sanctum)
```
POST   /api/auth/login         - User login (returns Sanctum token)
POST   /api/auth/logout        - User logout (revokes token)
GET    /api/auth/user          - Get authenticated user
POST   /api/auth/register      - Register new user (optional)
```

### User Management Endpoints
```
GET    /api/users              - List all users
POST   /api/users              - Create new user
GET    /api/users/{id}         - Get user details
PUT    /api/users/{id}         - Update user
DELETE /api/users/{id}         - Delete user
```

### Game Management Endpoints
```
GET    /api/games              - List all games
POST   /api/games              - Create new game
GET    /api/games/{id}         - Get game details
PUT    /api/games/{id}         - Update game
DELETE /api/games/{id}         - Delete game
GET    /api/games/{id}/types   - Get game types
```

### Betting Endpoints
```
POST   /api/tickets            - Create new ticket/bet
GET    /api/tickets            - List tickets
GET    /api/tickets/{id}       - Get ticket details
PUT    /api/tickets/{id}/cancel - Cancel ticket
GET    /api/tickets/history    - Get betting history
```

### Winning and Claims Endpoints
```
POST   /api/winning-numbers    - Enter winning numbers
GET    /api/winning-numbers    - List winning numbers
POST   /api/hits/generate      - Generate hits
GET    /api/hits               - List hits
POST   /api/claims             - Process claim
```

### Reporting Endpoints
```
GET    /api/reports/sales      - Get sales report
GET    /api/reports/tally      - Get tally sheet
GET    /api/reports/summary    - Get summary report
```

## 8. Data Flow Between Flutter App and Laravel Backend

```
+-------------------+                    +-------------------+
| Flutter App       |                    | Laravel Backend   |
| (Client)          |                    | (API Server)      |
+-------------------+                    +-------------------+
        |                                         |
        | HTTP Request with Sanctum Token         |
        |---------------------------------------->|
        |                                         |
        |                                         | Authenticate
        |                                         | & Authorize
        |                                         |
        |                                         | Process Request
        |                                         | (CRUD Operations)
        |                                         |
        |                                         | Database
        |                                         | Interaction
        |                                         |
        | HTTP Response (JSON)                    |
        |<----------------------------------------|
        |                                         |
        | Update UI State                         |
        | (GetX Controllers)                      |
        |                                         |
+-------------------+                    +-------------------+
```

## 9. Authentication Flow with Laravel Sanctum

```
+-------------------+                    +-------------------+
| Flutter App       |                    | Laravel Backend   |
+-------------------+                    +-------------------+
        |                                         |
        | 1. Login Request                        |
        | (username/password)                     |
        |---------------------------------------->|
        |                                         | 2. Validate
        |                                         | Credentials
        |                                         |
        | 3. Sanctum Token                        |
        |<----------------------------------------|
        |                                         |
        | 4. Store Token                          |
        | in Secure Storage                       |
        |                                         |
        | 5. Subsequent Requests                  |
        | with Bearer Token in Header             |
        |---------------------------------------->|
        |                                         | 6. Validate
        |                                         | Token
        |                                         |
        | 7. Response Data                        |
        |<----------------------------------------|
        |                                         |
+-------------------+                    +-------------------+
```

### Laravel Sanctum Benefits

1. **Simplified Token Management**: Sanctum provides a lightweight solution for API token authentication without the complexity of OAuth.

2. **SPA Authentication**: Built-in support for single-page applications (SPAs) with CSRF protection and cookie-based session authentication.

3. **Mobile Application Support**: Perfect for mobile applications like our Flutter app with API token authentication.

4. **Role-Based Authorization**: Easily integrates with Laravel's built-in authorization features for role-based access control.

5. **Token Abilities**: Tokens can be assigned specific abilities (similar to OAuth scopes) to restrict what actions they can perform.

This data model provides a comprehensive foundation for implementing the GAMBLE Mobile App with a Laravel backend. The model covers all aspects of the application, from authentication to game management, betting operations, and reporting.
