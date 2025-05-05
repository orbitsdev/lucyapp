# Lucky Betting App - Visualizations

This document provides visual representations of the Lucky Betting app's architecture, database schema, and navigation flows to help both frontend and backend developers understand the system.

## System Architecture

```
+-------------------+        +-------------------+        +-------------------+
| Flutter Frontend  |<------>| Laravel API       |<------>| MySQL Database    |
| (Mobile App)      |        | (Backend)         |        | (Data Storage)    |
+-------------------+        +-------------------+        +-------------------+
```

## Database Schema

```
+-------------+       +-------------+       +-------------+
| Users       |       | Locations   |       | Schedules   |
+-------------+       +-------------+       +-------------+
| id          |<----->| id          |       | id          |
| username    |       | name        |       | draw_time   |
| password    |       | address     |       | name        |
| name        |       | coordinator_|------>| is_active   |
| email       |       | is_active   |       +-------------+
| phone       |       +-------------+              ^
| role        |              ^                     |
| profile_img |              |                     |
| is_active   |              |                     |
| location_id |------------->|                     |
+-------------+                                    |
      ^                                            |
      |                                            |
+-------------+       +-------------+       +-------------+
| Tellers     |       | Bets        |       | Results     |
+-------------+       +-------------+       +-------------+
| id          |       | id          |       | id          |
| user_id     |------>| bet_number  |       | winning_num |
| coordinator |       | amount      |       | schedule_id |------+
| comm_rate   |       | schedule_id |------>| draw_date   |      |
| balance     |       | teller_id   |       | coordinator |      |
+-------------+       | customer_id |       +-------------+      |
      ^               | location_id |              ^             |
      |               | bet_date    |              |             |
      |               | ticket_id   |              |             |
      |               | status      |              |             |
      |               | combination |              |             |
      |               +-------------+              |             |
      |                      ^                     |             |
      |                      |                     |             |
+-------------+       +-------------+       +-------------+      |
| Commissions |       | Claims      |       | Tally Sheets|      |
+-------------+       +-------------+       +-------------+      |
| id          |       | id          |       | id          |      |
| teller_id   |------>| bet_id      |------>| teller_id   |      |
| rate        |       | result_id   |------>| location_id |      |
| amount      |       | teller_id   |       | sheet_date  |      |
| comm_date   |       | amount      |       | total_sales |      |
| type        |       | comm_amount |       | total_claims|      |
| bet_id      |       | claimed_at  |       | total_comm  |      |
| claim_id    |       | qr_code     |       | net_amount  |      |
+-------------+       +-------------+       +-------------+      |
                                                                 |
+-------------+                                                  |
| Sold Out    |                                                  |
+-------------+                                                  |
| id          |                                                  |
| number      |                                                  |
| schedule_id |<-------------------------------------------------+
| date        |
| location_id |
| is_active   |
+-------------+
```

## Navigation Flows

### 1. Login Flow

```
+----------------+     +----------------+     +----------------+
| Login Screen   | --> | Role Selection | --> | Role-Specific  |
| Username/Pass  |     | Coordinator    |     | Dashboard      |
|                |     | Teller         |     |                |
|                |     | Customer       |     |                |
+----------------+     +----------------+     +----------------+
```

### 2. Coordinator Navigation Flow

```
                                 +-------------------+
                                 | Coordinator       |
                                 | Dashboard         |
                                 +-------------------+
                                          |
                                          v
    +----------------+----------------+----------------+----------------+
    |                |                |                |                |
    v                v                v                v                v
+--------+     +--------+     +------------+    +--------+     +------------+
| User    |     | Tally   |     | Generate   |    | Summary |     | Commission |
| Manage  |     | Sheet   |     | Hits       |    | Reports |     | Management |
+--------+     +--------+     +------------+    +--------+     +------------+
    |                                                |
    v                                                v
+--------+                                     +--------+
| Teller |                                     | Summary |
| Actions|                                     | Details |
+--------+                                     +--------+
    |
    +----------------+----------------+
    |                |                |
    v                v                v
+--------+     +--------+     +--------+
| New Bet |     | Claims  |     | Sales   |
| as      |     | as      |     | as      |
| Teller  |     | Teller  |     | Teller  |
+--------+     +--------+     +--------+
```

### 3. Teller Navigation Flow

```
                          +-------------------+
                          | Teller            |
                          | Dashboard         |
                          +-------------------+
                                   |
                 +----------------+----------------+----------------+
                 |                |                |                |
                 v                v                v                v
          +------------+   +------------+   +------------+   +------------+
          | New Bet    |   | Claim      |   | Cancel Bet |   | Sales      |
          | Screen     |   | Screen     |   | Screen     |   | Screen     |
          +------------+   +------------+   +------------+   +------------+
                 |                |                               |
                 v                v                               v
          +------------+   +------------+                  +------------+
          | Bet Entry  |   | QR Code    |                  | Tally      |
          | Form       |   | Scanner    |                  | Sheet      |
          +------------+   +------------+                  +------------+
                                   |
                                   v
                          +-------------------+
                          | Commission        |
                          | Screen            |
                          +-------------------+
```

### 4. Customer Navigation Flow

```
                          +-------------------+
                          | Customer          |
                          | Dashboard         |
                          +-------------------+
                                   |
                 +----------------+----------------+----------------+
                 |                |                |                |
                 v                v                v                v
          +------------+   +------------+   +------------+   +------------+
          | Place Bet  |   | History    |   | Results    |   | Hits       |
          | Screen     |   | Screen     |   | Screen     |   | Screen     |
          +------------+   +------------+   +------------+   +------------+
```

## Process Flows

### 1. Bet Processing Flow

```
+-------------+     +-------------+     +-------------+     +-------------+
| Enter Bet   | --> | Select      | --> | Enter       | --> | Save Bet    |
| Number      |     | Schedule    |     | Amount      |     | & Generate  |
|             |     | (2pm/5pm/9pm)|    | (Custom)    |     | QR Code     |
+-------------+     +-------------+     +-------------+     +-------------+
                                                                   |
                                                                   v
                                                            +-------------+
                                                            | Calculate   |
                                                            | Commission  |
                                                            | (5/10/15%)  |
                                                            +-------------+
                                                                   |
                                                                   v
                                                            +-------------+
                                                            | Update      |
                                                            | Tally Sheet |
                                                            | & Sales     |
                                                            +-------------+
```

### 2. Claim Processing Flow

```
+-------------+     +-------------+     +-------------+     +-------------+
| Scan QR     | --> | Validate    | --> | Check if    | --> | Calculate   |
| Code        |     | Ticket      |     | Winner      |     | Winning     |
|             |     | Exists      |     | Against     |     | Amount &    |
|             |     |             |     | Results     |     | Commission  |
+-------------+     +-------------+     +-------------+     +-------------+
                                                                   |
                                                                   v
                                                            +-------------+
                                                            | Process     |
                                                            | Claim &     |
                                                            | Update      |
                                                            | Status      |
                                                            +-------------+
                                                                   |
                                                                   v
                                                            +-------------+
                                                            | Update      |
                                                            | Tally Sheet |
                                                            | & Claims    |
                                                            +-------------+
```

### 3. Result Generation Flow (Coordinator Only)

```
+-------------+     +-------------+     +-------------+     +-------------+
| Select      | --> | Generate or | --> | Save        | --> | Process     |
| Schedule    |     | Enter       |     | Result      |     | Winning     |
| & Date      |     | Winning     |     | to          |     | Tickets     |
|             |     | Numbers     |     | Database    |     |             |
+-------------+     +-------------+     +-------------+     +-------------+
                                                                   |
                                                                   v
                                                            +-------------+
                                                            | Update      |
                                                            | Bet         |
                                                            | Statuses    |
                                                            | (Won/Lost)  |
                                                            +-------------+
                                                                   |
                                                                   v
                                                            +-------------+
                                                            | Notify      |
                                                            | Users of    |
                                                            | Results     |
                                                            +-------------+
```

## User Interface Flow (Teller)

```
+----------------+     +----------------+     +----------------+
| Login          | --> | Teller         | --> | New Bet       |
| Screen         |     | Dashboard      |     | Screen        |
+----------------+     +----------------+     +----------------+
                              |                       |
                              v                       v
                       +----------------+     +----------------+
                       | Tally Sheet    |     | Bet Entry     |
                       | Screen         |     | Form          |
                       +----------------+     +----------------+
                              |                       |
                              v                       v
                       +----------------+     +----------------+
                       | Commission     |     | QR Code       |
                       | Screen         |     | Generation    |
                       +----------------+     +----------------+
                              |                       |
                              v                       v
                       +----------------+     +----------------+
                       | Claims         |     | QR Code       |
                       | Screen         |     | Scanner       |
                       +----------------+     +----------------+
                              |                       |
                              v                       v
                       +----------------+     +----------------+
                       | Cancel Bet     |     | Sales         |
                       | Screen         |     | Screen        |
                       +----------------+     +----------------+
```

## Data Flow

```
+----------------+     +----------------+     +----------------+
| User Input     | --> | API Request    | --> | Database      |
| (Flutter UI)   |     | (Laravel)      |     | Operation     |
+----------------+     +----------------+     +----------------+
        ^                      |                      |
        |                      v                      v
+----------------+     +----------------+     +----------------+
| UI Update      | <-- | API Response   | <-- | Data          |
| (Flutter)      |     | (JSON)         |     | Processing    |
+----------------+     +----------------+     +----------------+
```

## Role-Based Access Control

```
+----------------+     +----------------+     +----------------+
| Authentication | --> | User Role      | --> | Available     |
| (JWT Token)    |     | Determination  |     | Features      |
+----------------+     +----------------+     +----------------+
                              |
              +---------------+---------------+
              |               |               |
              v               v               v
    +----------------+ +----------------+ +----------------+
    | Coordinator    | | Teller         | | Customer       |
    | Features       | | Features       | | Features       |
    +----------------+ +----------------+ +----------------+
    | - User Mgmt    | | - New Bet      | | - Place Bet    |
    | - Generate Hits| | - Claims       | | - View History |
    | - Set Schedules| | - Cancel Bet   | | - Check Results|
    | - View Reports | | - View Sales   | | - View Hits    |
    | - Set Commiss. | | - View Commiss.| |                |
    +----------------+ +----------------+ +----------------+
```

These visualizations provide a comprehensive overview of the Lucky Betting app's structure, navigation flows, and data relationships, helping both frontend and backend developers understand how the system works together.
