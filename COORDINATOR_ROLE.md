# Coordinator Role Guide

This document outlines the responsibilities, workflows, and features available to users with the **Coordinator** role in the LuckyBet app.

## Role Overview

The Coordinator is the administrative user with the highest level of access in the system. Coordinators manage the overall betting operations, including user management, game configuration, financial reporting, and can also perform teller functions when needed.

```
+---------------------+
|     Coordinator     |
|    (Admin User)     |
+---------------------+
          |
          v
+---------------------+
| • Manage Users      |
| • Configure Games   |
| • Set Win Numbers   |
| • Generate Reports  |
| • Monitor Sales     |
| • Manage Commission |
| • Act as Teller     |
+---------------------+
```

## Access and Authentication

```
+----------------+     +----------------+     +----------------+
| Login Screen   | --> | Select         | --> | Coordinator    |
| (Credentials)  |     | "Coordinator"  |     | Dashboard      |
+----------------+     +----------------+     +----------------+
```

1. Open the LuckyBet app
2. Enter username and password
3. Select the "Coordinator" role
4. Click the Login button
5. Access the Coordinator Dashboard

## Main Features and Workflows

### 1. User Management

```
+----------------+     +----------------+     +----------------+
| Coordinator    | --> | User           | --> | View/Add/Edit/ |
| Dashboard      |     | Management     |     | Delete Users   |
+----------------+     +----------------+     +----------------+
                                                      |
                                                      v
                                              +----------------+
                                              | Set User Roles |
                                              | and Permissions|
                                              +----------------+
```

**Steps:**
1. From the Coordinator Dashboard, tap "User Management"
2. View the list of all users (Tellers and Customers)
3. Add new users with the "+" button
4. Edit existing users by tapping on their entry
5. Assign roles (Teller or Customer)
6. Set permissions and access levels
7. Activate/deactivate user accounts

### 2. Game Management

```
+----------------+     +----------------+     +----------------+
| Coordinator    | --> | Game           | --> | Configure Game |
| Dashboard      |     | Management     |     | Parameters     |
+----------------+     +----------------+     +----------------+
                                                      |
                                                      v
                                              +----------------+
                                              | Set Odds and   |
                                              | Payout Rates   |
                                              +----------------+
```

**Steps:**
1. From the Coordinator Dashboard, tap "Game Management"
2. View the list of available games
3. Configure game parameters (min/max numbers, selection count)
4. Set odds and payout rates for different game types
5. Enable/disable specific games or game types
6. Set draw schedules and cut-off times

### 3. Commission Management

```
+----------------+     +----------------+     +----------------+
| Coordinator    | --> | Commission     | --> | View/Set       |
| Dashboard      |     | Management     |     | Commission     |
+----------------+     +----------------+     +----------------+
                                                      |
                                                      v
                                              +----------------+
                                              | Configure      |
                                              | Rates          |
                                              +----------------+
```

**Steps:**
1. From the Coordinator Dashboard, tap "Commission"
2. View the current commission rates for tellers
3. Set or adjust commission percentages (standard rates are 5%, 10%, or 15%)
4. View commission reports by teller, location, or date range
5. Analyze commission payouts against sales performance

**Key Functions:**
- Set standard commission percentage for all tellers
- Configure special commission rates for high-performing tellers
- View commission history and reports
- Calculate total commission payouts for accounting purposes

### 4. Setting Winning Numbers

```
+----------------+     +----------------+     +----------------+
| Coordinator    | --> | Generate       | --> | Select Game    |
| Dashboard      |     | Hits           |     | and Draw       |
+----------------+     +----------------+     +----------------+
                                                      |
                                                      v
                                              +----------------+
                                              | Enter Winning  |
                                              | Numbers        |
                                              +----------------+
                                                      |
                                                      v
                                              +----------------+
                                              | Generate       |
                                              | Winning Tickets|
                                              +----------------+
```

**Steps:**
1. From the Coordinator Dashboard, tap "Generate Hits"
2. Select the game type (3D, 2D, etc.)
3. Select the draw date and time
4. Enter the winning numbers
5. Click "Generate Hits" to identify winning tickets
6. Review the list of winning tickets and amounts
7. Confirm and publish results

### 5. Financial Reporting

```
+----------------+     +----------------+     +----------------+
| Coordinator    | --> | Summary        | --> | Search & View  |
| Dashboard      |     | Reports        |     | Teller Data    |
+----------------+     +----------------+     +----------------+
                                                      |
                                                      v
                                              +----------------+
                                              | View Detailed  |
                                              | Breakdown      |
                                              +----------------+
```

**Steps:**
1. From the Coordinator Dashboard, select "Summary Reports"
2. View the summary cards for Total Sales and Total Hits
3. Use the search field to filter tellers by name
4. View the list of tellers with their sales totals
5. Click "View" on a teller to see detailed breakdown by draw time (2PM, 5PM, 9PM)
6. Analyze sales, hits, and profit for each time slot

### 6. System Administration

```
+----------------+     +----------------+     +----------------+
| Coordinator    | --> | System         | --> | Configure      |
| Dashboard      |     | Administration |     | System Settings|
+----------------+     +----------------+     +----------------+
                              |
                              v
                      +----------------+
                      | Access Teller  |
                      | Functions      |
                      +----------------+
```

**Steps:**
1. From the Coordinator Dashboard, select "System Administration"
2. Configure global system settings
3. Manage system parameters
4. Access teller functions (New Bet, Claim, Sales)

## Dashboard Overview

The Coordinator Dashboard provides a comprehensive overview of the betting operation:

```
+---------------------------------------------------------------+
|                     COORDINATOR DASHBOARD                      |
+---------------------------------------------------------------+
|                                                               |
| +-------------------+            +----------------------+     |
| | SYSTEM OVERVIEW   |            | TODAY'S PERFORMANCE |     |
| | Active Tellers: 12|            | Total Sales: $5,280 |     |
| | Active Games: 4   |            | Tickets Sold: 423   |     |
| | Pending Claims: 8 |            | Claims Paid: $1,500 |     |
| +-------------------+            +----------------------+     |
|                                                               |
| +-------------------+            +----------------------+     |
| | RECENT ACTIVITY   |            | UPCOMING DRAWS       |     |
| | • New Teller Added|            | • 3D Game: 11:00 AM  |     |
| | • Win #s Set: 123 |            | • 2D Game: 11:00 AM  |     |
| | • Large Claim: $2k|            | • 3D Game: 4:00 PM   |     |
| | • Report Generated|            | • 2D Game: 4:00 PM   |     |
| +-------------------+            +----------------------+     |
|                                                               |
+---------------------------------------------------------------+
|                                                               |
|  [Users]  [Games]  [Generate Hits]  [Summary]  [Commission]  |
|                                                               |
+---------------------------------------------------------------+
```

## Key Responsibilities

1. **System Administration**
   - Manage user accounts and permissions
   - Configure system settings
   - Monitor system performance

2. **Game Management**
   - Configure game parameters
   - Set draw schedules
   - Manage payout rates

3. **Results Management**
   - Enter winning numbers
   - Generate and verify hits
   - Approve large payouts

4. **Financial Oversight**
   - Monitor sales and claims
   - Generate and review reports
   - Track financial performance

5. **Operational Support**
   - Assist Tellers with issues
   - Handle escalated customer concerns
   - Ensure smooth daily operations

## Color Scheme and UI Elements

The Coordinator interface uses a deep red color scheme (#d32f2f) to visually distinguish it from other roles:

```
Primary Color: #d32f2f (Red)
Secondary Color: #ff6659
Text on Primary: #ffffff
Accent Color: #9a0007
```

This color scheme is applied consistently across all Coordinator screens to provide a cohesive and recognizable experience.
