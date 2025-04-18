# LuckyBet App Workflow

This document outlines the complete flow of processes in the LuckyBet App, from user login to betting operations and administrative functions.

## 1. User Authentication Flow

```
User opens app → Login Screen → Authentication → Dashboard (success) / Error Message (failure)
```

Visual representation:
```
+-------------+     +---------------+     +-----------------+     +-------------+
| User opens  | --> | Login Screen  | --> | Authentication  | --> | Dashboard   |
| app         |     | (Credentials) |     | (Verification)  |     | (Main Menu) |
+-------------+     +---------------+     +-----------------+     +-------------+
                           ^                      |
                           |                      v
                           |              +-----------------+
                           +--------------| Error Message   |
                                          | (If failed)     |
                                          +-----------------+
```

## 2. Main Application Flow

The Dashboard serves as the central hub, providing access to all application features:

```
Dashboard (Coordinator)
  ├── User Management
  ├── Generate Hits
  ├── Summary Reports
  │   └── Summary Detail
  ├── Commission
  ├── System Administration
  │   ├── Game Configuration
  │   └── Financial Reports
  └── Teller Functions
      ├── New Bet
      ├── Claim
      └── Sales

Dashboard (Teller)
  ├── New Bet
  ├── Claim
  ├── Printer Setup
  ├── Cancel Bet
  ├── Sales
  ├── Tally Sheet
  ├── Commission
  └── Combination

Dashboard (Customer)
  ├── Place Bet
  ├── History
  ├── Hits
  └── Results
```

## 3. New Bet Process

```
New Bet Screen → Select Game Type → Enter Numbers → Set Amount → Confirm Bet → Process Bet → Print Receipt
```

Visual representation:
```
+----------------+     +----------------+     +----------------+     +----------------+
| New Bet Screen | --> | Select Game    | --> | Enter Numbers  | --> | Set Amount     |
|                |     | Type           |     |                |     |                |
+----------------+     +----------------+     +----------------+     +----------------+
                                                                            |
                                                                            v
+----------------+     +----------------+     +----------------+     +----------------+
| Print Receipt  | <-- | Process Bet    | <-- | Confirm Bet    | <-- | Review Bet     |
|                |     |                |     |                |     | Details        |
+----------------+     +----------------+     +----------------+     +----------------+
```

## 4. Betting Process

```
New Bet → Select Game → Enter Numbers → Set Amount → Confirm → Print Receipt
```

Visual representation:
```
+----------------+     +----------------+     +----------------+
| Teller         | --> | New Bet        | --> | Select Game    |
| Dashboard      |     | Screen         |     | Type           |
+----------------+     +----------------+     +----------------+
                                                      |
                                                      v
+----------------+     +----------------+     +----------------+
| Print Receipt  | <-- | Confirm and    | <-- | Enter Numbers  |
| for Customer   |     | Process Bet    |     | and Amount     |
+----------------+     +----------------+     +----------------+
```

**Steps:**
1. Teller selects "New Bet" from the dashboard
2. Selects the game type (e.g., Standard, Combination)
3. Enters the bet numbers (1-31 or custom range based on game type)
4. Sets the bet amount (custom values allowed)
5. Confirms the bet details
6. System processes the bet and generates a receipt with QR code
7. Receipt is printed for the customer

## 5. Claim Process

```
Claim → Scan QR Code → Verify Win → Process Payment → Print Receipt
```

Visual representation:
```
+----------------+     +----------------+     +----------------+
| Teller         | --> | Claim          | --> | Scan QR Code   |
| Dashboard      |     | Screen         |     | of Ticket      |
+----------------+     +----------------+     +----------------+
                                                      |
                                                      v
+----------------+     +----------------+     +----------------+
| Print Claim    | <-- | Process        | <-- | Verify Win     |
| Receipt        |     | Payment        |     | Amount         |
+----------------+     +----------------+     +----------------+
```

**Steps:**
1. Teller selects "Claim" from the dashboard
2. Scans the QR code on the winning ticket
3. System verifies the ticket and displays win amount
4. Teller confirms the win and processes payment
5. System marks the ticket as claimed
6. Claim receipt is printed for the customer

## 6. Cancellation Process

```
Cancel Bet → Enter/Scan Ticket Number → Verify Eligibility → Process Cancellation → Print Receipt
```

Visual representation:
```
+----------------+     +----------------+     +----------------+
| Teller         | --> | Cancel Bet     | --> | Enter/Scan     |
| Dashboard      |     | Screen         |     | Ticket Number  |
+----------------+     +----------------+     +----------------+
                                                      |
                                                      v
+----------------+     +----------------+     +----------------+
| Print          | <-- | Process        | <-- | Verify         |
| Cancellation   |     | Cancellation   |     | Eligibility    |
| Receipt        |     | and Refund     |     | (Time Window)  |
+----------------+     +----------------+     +----------------+
```

**Steps:**
1. Teller selects "Cancel Bet" from the dashboard
2. Enters or scans the ticket number
3. System verifies if the ticket is eligible for cancellation
   - Must be within time window (typically 15 minutes after purchase)
   - Must not be for a draw that has already occurred
4. If eligible, system processes the cancellation and issues refund
5. Cancellation receipt is printed for the customer

## 7. Commission Process (Teller)

```
Commission → View Current Rate → View Earnings → Filter by Date → View Details
```

Visual representation:
```
+----------------+     +----------------+     +----------------+
| Teller         | --> | Commission     | --> | View Current   |
| Dashboard      |     | Screen         |     | Rate & Earnings|
+----------------+     +----------------+     +----------------+
                                                      |
                                                      v
+----------------+     +----------------+
| View Detailed  | <-- | Filter by      |
| Breakdown      |     | Date Range     |
+----------------+     +----------------+
```

**Steps:**
1. Teller selects "Commission" from the dashboard
2. Views their current commission rate (5%, 10%, or 15%)
3. Views total commission earned for the current period
4. Can filter by date range to view historical commission
5. Views detailed breakdown of commission calculation

## 8. Commission Management (Coordinator)

```
Commission → View All Tellers → Set Rates → Approve Payments → Generate Reports
```

Visual representation:
```
+----------------+     +----------------+     +----------------+
| Coordinator    | --> | Commission     | --> | View All       |
| Dashboard      |     | Management     |     | Tellers        |
+----------------+     +----------------+     +----------------+
                                                      |
                                                      v
+----------------+     +----------------+     +----------------+
| Generate       | <-- | Approve        | <-- | Set/Adjust     |
| Reports        |     | Payments       |     | Rates          |
+----------------+     +----------------+     +----------------+
```

**Steps:**
1. Coordinator selects "Commission" from the dashboard
2. Views list of all tellers with their current commission rates
3. Sets or adjusts commission rates for individual tellers
4. Approves commission payments for processing
5. Generates commission reports for accounting purposes

## 9. Data Flow Architecture

```
UI Layer (Screens) → Controllers (Business Logic) → Models (Data) → Services (API/Storage)
```

Visual representation:
```
+----------------+     +----------------+     +----------------+     +----------------+
| UI Layer       | --> | Controllers    | --> | Models         | --> | Services       |
| (Flutter       |     | (GetX          |     | (Data          |     | (API/Storage   |
| Screens)       |     | Controllers)   |     | Structures)    |     | Interaction)   |
+----------------+     +----------------+     +----------------+     +----------------+
        ^                      |                      ^                      |
        |                      v                      |                      v
+---------------------------------------------------------------+     +----------------+
|                      State Management                         |     | External APIs/ |
|                      (GetX)                                   |     | Local Storage  |
+---------------------------------------------------------------+     +----------------+
```

## 10. Printer Setup and Management

```
Printer Setup Screen → Scan for Devices → Select Printer → Test Connection → Save Configuration
```

Visual representation:
```
+----------------+     +----------------+     +----------------+     +----------------+
| Printer Setup  | --> | Scan for       | --> | Select Printer | --> | Test           |
| Screen         |     | Devices        |     |                |     | Connection     |
+----------------+     +----------------+     +----------------+     +----------------+
                                                                            |
                                                                            v
                                                                     +----------------+
                                                                     | Save           |
                                                                     | Configuration  |
                                                                     +----------------+
```

## 11. Coordinator Administrative Process

```
Coordinator Dashboard → Select Administrative Function → Configure Settings → Save Changes
```

Visual representation:
```
+----------------+     +----------------+     +----------------+     +----------------+
| Coordinator    | --> | Select Admin   | --> | Configure      | --> | Save Changes   |
| Dashboard      |     | Function       |     | Settings       |     |                |
+----------------+     +----------------+     +----------------+     +----------------+
```

## 12. Coordinator as Teller Process

```
Coordinator Dashboard → Select Teller Function → Perform Teller Operations
```

Visual representation:
```
+----------------+     +----------------+     +----------------+
| Coordinator    | --> | Select Teller  | --> | New Bet        |
| Dashboard      |     | Function       |     | Claim          |
+----------------+     +----------------+     | Sales          |
                                              +----------------+
                                                      |
                                                      v
                                              +----------------+
                                              | Perform Teller |
                                              | Operations     |
                                              +----------------+
```

## 13. Combination Generator Flow

```
Combination Screen → Select Game Type → Enter Parameters → Generate Combinations → View/Save Combinations
```

Visual representation:
```
+----------------+     +----------------+     +----------------+     +----------------+
| Combination    | --> | Select Game    | --> | Enter          | --> | Generate       |
| Screen         |     | Type           |     | Parameters     |     | Combinations   |
+----------------+     +----------------+     +----------------+     +----------------+
                                                                            |
                                                                            v
                                                                     +----------------+
                                                                     | View/Save      |
                                                                     | Combinations   |
                                                                     +----------------+
```

## 14. Bet Win Process

```
Bet Win Screen → Select Draw → Enter Winning Numbers → Calculate Winners → Process Payouts
```

Visual representation:
```
+----------------+     +----------------+     +----------------+     +----------------+
| Bet Win Screen | --> | Select Draw    | --> | Enter Winning  | --> | Calculate      |
|                |     |                |     | Numbers        |     | Winners        |
+----------------+     +----------------+     +----------------+     +----------------+
                                                                            |
                                                                            v
                                                                     +----------------+
                                                                     | Process        |
                                                                     | Payouts        |
                                                                     +----------------+
```

## 15. Sold Out Management

```
Sold Out Screen → Select Game Type → View Available Numbers → Mark Numbers as Sold Out → Save Changes
```

Visual representation:
```
+----------------+     +----------------+     +----------------+     +----------------+
| Sold Out       | --> | Select Game    | --> | View Available | --> | Mark Numbers   |
| Screen         |     | Type           |     | Numbers        |     | as Sold Out    |
+----------------+     +----------------+     +----------------+     +----------------+
                                                                            |
                                                                            v
                                                                     +----------------+
                                                                     | Save Changes   |
                                                                     |                |
                                                                     +----------------+
```

## 16. Application Architecture Overview

The LuckyBet Mobile App follows a clean architecture pattern with the following components:

1. **UI Layer**: Flutter widgets and screens
2. **Controllers**: GetX controllers for business logic and state management
3. **Models**: Data structures representing business entities
4. **Services**: API communication and data persistence
5. **Routes**: Navigation management
6. **Utils**: Helper functions and utilities
7. **Widgets**: Reusable UI components

This architecture ensures separation of concerns, maintainability, and scalability of the application.
