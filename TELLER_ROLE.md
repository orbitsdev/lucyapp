# Teller Role Guide

This document outlines the responsibilities, workflows, and features available to users with the **Teller** role in the GAMBLE Mobile App.

## Role Overview

The Teller is the operational user who directly interacts with customers, processes bets, handles claims, and manages daily transactions. Tellers are the frontline staff of the betting operation.

```
+---------------------+
|       Teller        |
|  (Operational User) |
+---------------------+
          |
          v
+---------------------+
| • Process Bets      |
| • Handle Claims     |
| • Cancel Tickets    |
| • Manage Sales      |
| • Print Receipts    |
+---------------------+
```

## Access and Authentication

```
+----------------+     +----------------+     +----------------+
| Login Screen   | --> | Select         | --> | Teller         |
| (Credentials)  |     | "Teller"       |     | Dashboard      |
+----------------+     +----------------+     +----------------+
```

1. Open the GAMBLE Mobile App
2. Enter username and password
3. Select the "Teller" role
4. Click the Login button
5. Access the Teller Dashboard

## Main Features and Workflows

### 1. Processing New Bets

```c
+----------------+     +----------------+     +----------------+
| Teller         | --> | New Bet        | --> | Select Game    |
| Dashboard      |     | Screen         |     | Type           |
+----------------+     +----------------+     +----------------+
                                                      |
                                                      v
                                              +----------------+
                                              | Enter Numbers  |
                                              | and Amount     |
                                              +----------------+
                                                      |
                                                      v
                                              +----------------+
                                              | Confirm and    |
                                              | Print Ticket   |
                                              +----------------+
```

**Steps:**
1. From the Teller Dashboard, tap "New Bet"
2. Select the game type (3D, 2D, etc.)
3. Enter the customer's selected numbers
4. Enter the bet amount
5. Review the bet details with the customer
6. Confirm the bet and collect payment
7. Print the betting ticket for the customer

### 2. Processing Claims

```
+----------------+     +----------------+     +----------------+
| Teller         | --> | Claim          | --> | Enter Ticket   |
| Dashboard      |     | Screen         |     | Number         |
+----------------+     +----------------+     +----------------+
                                                      |
                                                      v
                                              +----------------+
                                              | Verify Winning |
                                              | Status         |
                                              +----------------+
                                                      |
                                                      v
                                              +----------------+
                                              | Process Payout |
                                              | and Print      |
                                              +----------------+
```

**Steps:**
1. From the Teller Dashboard, tap "Claim"
2. Enter or scan the customer's ticket number
3. The system verifies if the ticket is a winner
4. If winning, the system displays the winning amount
5. Confirm the payout with the customer
6. Process the payout and provide the winnings
7. Print a claim receipt for the customer

### 3. Cancelling Tickets

```
+----------------+     +----------------+     +----------------+
| Teller         | --> | Cancel         | --> | Enter Ticket   |
| Dashboard      |     | Document       |     | Number         |
+----------------+     +----------------+     +----------------+
                                                      |
                                                      v
                                              +----------------+
                                              | Verify Ticket  |
                                              | Eligibility    |
                                              +----------------+
                                                      |
                                                      v
                                              +----------------+
                                              | Confirm Cancel |
                                              | and Refund     |
                                              +----------------+
```

**Steps:**
1. From the Teller Dashboard, tap "Cancel Document"
2. Enter or scan the ticket number to be cancelled
3. The system verifies if the ticket is eligible for cancellation
   - Must be within the cancellation time window
   - Must not be for a draw that has already occurred
4. Review the ticket details with the customer
5. Confirm the cancellation and process the refund
6. Print a cancellation receipt for the customer

### 4. Managing Sales and Reporting

```
+----------------+     +----------------+     +----------------+
| Teller         | --> | Sales          | --> | View Daily     |
| Dashboard      |     | Screen         |     | Sales Summary  |
+----------------+     +----------------+     +----------------+
                                                      |
                                                      v
                                              +----------------+
                                              | Generate Tally |
                                              | Sheet          |
                                              +----------------+
```

**Steps:**
1. From the Teller Dashboard, tap "Sales"
2. View the daily sales summary showing:
   - Total tickets sold
   - Total sales amount
   - Breakdown by game type
3. Filter by date if needed
4. Generate a tally sheet at the end of the shift
5. Reconcile cash on hand with system totals
6. Submit the tally sheet to the Coordinator

### 5. Printer Setup and Management

```
+----------------+     +----------------+     +----------------+
| Teller         | --> | Printer        | --> | Scan for       |
| Dashboard      |     | Setup          |     | Devices        |
+----------------+     +----------------+     +----------------+
                                                      |
                                                      v
                                              +----------------+
                                              | Configure and  |
                                              | Test Printer   |
                                              +----------------+
```

**Steps:**
1. From the Teller Dashboard, tap "Printer Setup"
2. Scan for available printer devices
3. Select the appropriate printer
4. Configure printer settings
5. Run a test print to verify connectivity
6. Save the printer configuration

### 6. Combination Generator

```
+----------------+     +----------------+     +----------------+
| Teller         | --> | Combination    | --> | Select Game    |
| Dashboard      |     | Screen         |     | Type           |
+----------------+     +----------------+     +----------------+
                                                      |
                                                      v
                                              +----------------+
                                              | Set Parameters |
                                              | for Generation |
                                              +----------------+
                                                      |
                                                      v
                                              +----------------+
                                              | Generate and   |
                                              | View Results   |
                                              +----------------+
```

**Steps:**
1. From the Teller Dashboard, tap "Combination"
2. Select the game type
3. Set parameters for combination generation
4. Generate combinations
5. Review the generated combinations with the customer
6. Proceed to place bets using the generated combinations

### 7. Sold Out Management

```
+----------------+     +----------------+     +----------------+
| Teller         | --> | Sold Out       | --> | Select Game    |
| Dashboard      |     | Screen         |     | Type           |
+----------------+     +----------------+     +----------------+
                                                      |
                                                      v
                                              +----------------+
                                              | View Available |
                                              | Numbers        |
                                              +----------------+
                                                      |
                                                      v
                                              +----------------+
                                              | Mark Numbers   |
                                              | as Sold Out    |
                                              +----------------+
```

**Steps:**
1. From the Teller Dashboard, tap "Sold Out"
2. Select the game type and draw
3. View the current status of numbers
4. Mark specific numbers as sold out when they reach their limit
5. Save changes to update the system

## Dashboard Overview

The Teller Dashboard provides an operational overview focused on daily activities:

```
+---------------------------------------------------------------+
|                       TELLER DASHBOARD                         |
+---------------------------------------------------------------+
|                                                               |
| +-------------------+            +----------------------+     |
| | TODAY'S SUMMARY   |            | UPCOMING DRAWS       |     |
| | Sales: $1,280     |            | • 3D Game: 11:00 AM  |     |
| | Tickets: 42       |            |   (Closes in 45 min) |     |
| | Claims: $500      |            | • 2D Game: 11:00 AM  |     |
| +-------------------+            |   (Closes in 45 min) |     |
|                                  +----------------------+     |
| +-------------------+                                         |
| | RECENT ACTIVITY   |            +----------------------+     |
| | • Bet: $100 (3D)  |            | PRINTER STATUS       |     |
| | • Claim: $500 (2D)|            | • Connected: Yes     |     |
| | • Cancel: $50 (1D)|            | • Paper: OK          |     |
| | • Bet: $150 (3D)  |            | • Last Test: 8:30 AM |     |
| +-------------------+            +----------------------+     |
|                                                               |
+---------------------------------------------------------------+
|                                                               |
|  [New Bet]  [Claim]  [Cancel]  [Sales]  [Printer]  [More]     |
|                                                               |
+---------------------------------------------------------------+
```

## Key Responsibilities

1. **Customer Service**
   - Assist customers with placing bets
   - Process winning claims
   - Handle ticket cancellations
   - Provide game information

2. **Transaction Processing**
   - Accept payments for bets
   - Pay out winnings
   - Process refunds for cancellations
   - Maintain accurate cash handling

3. **Record Keeping**
   - Track daily sales
   - Generate tally sheets
   - Reconcile accounts at end of shift
   - Report discrepancies to Coordinator

4. **Equipment Management**
   - Maintain printer functionality
   - Ensure adequate supplies (paper, ink)
   - Troubleshoot basic technical issues

5. **Game Management**
   - Mark numbers as sold out when needed
   - Generate number combinations for customers
   - Stay updated on game rules and payouts

## Color Scheme and UI Elements

The Teller interface uses a teal green color scheme (#00796b) to visually distinguish it from other roles:

```
Primary Color: #00796b (Teal Green)
Secondary Color: #48a999
Text on Primary: #ffffff
Accent Color: #ffd600
```

This color scheme is applied consistently across all Teller screens to provide a cohesive and recognizable experience.
