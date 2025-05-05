# Lucky Betting App - Backend Requirements

This document outlines the requirements for the Laravel backend that will support the Lucky Betting app. It focuses on explaining the system architecture, data models, and API requirements without implementation details.

## Table of Contents

1. [System Overview](#system-overview)
2. [Data Model Requirements](#data-model-requirements)
3. [API Requirements](#api-requirements)
4. [Business Logic Requirements](#business-logic-requirements)
5. [Integration Requirements](#integration-requirements)
6. [Security Requirements](#security-requirements)
7. [Performance Considerations](#performance-considerations)

## System Overview

The Lucky Betting app is a comprehensive betting management system that facilitates number betting operations with three distinct user roles:

- **Coordinator (Admin)**: Manages the system, users, and game configurations
- **Teller (Agent)**: Processes bets and claims at specific locations
- **Customer**: Places bets and views results

### Key Features

![System Features](https://i.imgur.com/FnUZGgJ.png)

- **User Management**: Role-based access control for coordinators, tellers, and customers
- **Betting Operations**: Placing bets, cancellations, and combinations
- **Claims Processing**: QR code-based verification of winning tickets
- **Financial Tracking**: Sales reports, commission calculations, and tally sheets
- **Result Management**: Generating winning numbers and processing results
- **Schedule Management**: Setting and enforcing betting schedules (2pm, 5pm, 9pm)

### System Architecture

![System Architecture](https://i.imgur.com/9mVJbdM.png)

The system follows a client-server architecture:
- **Flutter Frontend**: Mobile application with role-specific interfaces
- **Laravel Backend**: RESTful API service handling business logic and data management
- **MySQL Database**: Persistent storage for all application data

## Data Model Requirements

The backend needs to support the following data entities and their relationships:

### Entity Relationship Diagram

![Entity Relationship Diagram](https://i.imgur.com/LQTcMlR.png)

Detailed Database Schema:

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

### Core Entities

1. **Users**
   - Attributes: username, password, name, email, phone, role, profile image, active status, location
   - Roles: coordinator, teller, customer
   - Relationships: belongs to a location, has many bets/claims/commissions

2. **Tellers** (extends Users)
   - Attributes: commission rate (5%, 10%, or 15%), balance
   - Relationships: belongs to a coordinator, has many bets/claims

3. **Locations**
   - Attributes: name (e.g., "MANILA BRANCH"), address, active status
   - Relationships: belongs to a coordinator, has many tellers and bets

4. **Schedules**
   - Attributes: draw time (2pm, 5pm, 9pm), name, active status
   - Relationships: has many bets and results

5. **Bets**
   - Attributes: bet number, amount, bet date, ticket ID (for QR), status, combination flag
   - Relationships: belongs to schedule, teller, customer, location
   - Statuses: active, cancelled, claimed, won, lost

6. **Results**
   - Attributes: winning number, draw date
   - Relationships: belongs to schedule and coordinator

7. **Claims**
   - Attributes: amount, commission amount, claimed date, QR code data
   - Relationships: belongs to bet, result, and teller

8. **Commissions**
   - Attributes: rate, amount, commission date, type (sales/claims)
   - Relationships: belongs to teller, bet, claim

9. **Tally Sheets**
   - Attributes: sheet date, total sales, total claims, total commission, net amount
   - Relationships: belongs to teller and location

10. **Sold Out Numbers**
    - Attributes: number, date, active status
    - Relationships: belongs to schedule and location

## API Requirements

The backend needs to provide the following API endpoints grouped by functionality:

### Authentication

- Login with role-based redirection
- Logout
- User profile retrieval
- Token refresh

### User Management (Coordinator Only)

- CRUD operations for users
- Filtering users by role (tellers, customers)
- Activation/deactivation of users

### Location Management (Coordinator Only)

- CRUD operations for locations
- Assigning tellers to locations

### Schedule Management (Coordinator Only)

- CRUD operations for schedules
- Activating/deactivating schedules
- Retrieving active schedules

### Bet Management

- Creating new bets (Teller)
- Retrieving bets with various filters (date, schedule, teller)
- Cancelling bets (Teller)
- Retrieving bet details by ticket ID

### Claim Processing

- Processing claims via QR code scanning
- Retrieving claims with various filters
- Verifying winning tickets

### Result Management (Coordinator Only)

- Setting winning numbers
- Generating results
- Retrieving results with various filters

### Commission Management

- Calculating commissions based on sales and claims
- Retrieving commission data with various filters
- Commission summaries by teller and date

### Reporting

- Sales reports
- Claims reports
- Commission reports
- Summary reports
- Teller performance reports

## Business Logic Requirements

### 1. Bet Processing Flow

![Bet Processing Flow](https://i.imgur.com/8XVLKFQ.png)

1. Validate bet number format
2. Check if schedule is active
3. Check if number is sold out for the selected schedule
4. Generate unique ticket ID for QR code
5. Create bet record
6. Calculate and record commission based on teller's rate
7. Update tally sheet

### 2. Claim Processing Flow

![Claim Processing Flow](https://i.imgur.com/YKdkJGh.png)

1. Scan QR code to get ticket ID
2. Validate ticket (exists, not already claimed/cancelled)
3. Find result for the bet's schedule and date
4. Verify if the bet is a winner
5. Calculate winning amount
6. Calculate commission based on teller's rate
7. Create claim record
8. Update bet status
9. Record commission
10. Update tally sheet

### 3. Result Generation Flow

![Result Generation Flow](https://i.imgur.com/JQwL6Wd.png)

1. Check if result already exists for schedule and date
2. Generate winning number
3. Create result record
4. Process all matching bets (update status to won/lost)
5. Notify users of results

### 4. Commission Calculation

- Tellers earn commission on both sales and claims
- Commission rates can be 5%, 10%, or 15% based on coordinator settings
- Commission is calculated as percentage of bet amount or winning amount
- Daily commissions are tracked and summarized in tally sheets

## Integration Requirements

### 1. QR Code Integration

The backend must support:
- Generating unique QR codes for each bet ticket
- Validating QR codes during claims processing
- Providing QR code data in a format compatible with the Flutter frontend

### 2. Flutter Frontend Integration

The backend must provide:
- RESTful API endpoints matching the Flutter app's requirements
- Proper response formats (JSON)
- Appropriate HTTP status codes
- Pagination for large data sets
- Filtering capabilities for all list endpoints

### 3. Role-Based Access Control

![Role-Based Access](https://i.imgur.com/DzRDJgN.png)

The backend must enforce:
- Coordinator-only access to administrative functions
- Teller-specific access to betting and claiming functions
- Customer-specific access to betting history and results
- Proper authentication and authorization for all endpoints

Detailed Role-Based Access Control Flow:

```
+----------------+     +----------------+     +----------------+
| Authentication | --> | User Role      | --> | Available     |
| (Sanctum)      |     | Determination  |     | Features      |
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

## Security Requirements

1. **Authentication**
   - Laravel Sanctum authentication
   - Secure token storage and transmission
   - Token expiration and refresh mechanisms

2. **Authorization**
   - Role-based access control
   - Resource-level permissions
   - Ownership verification for sensitive operations

3. **Data Protection**
   - Password hashing
   - HTTPS for all API communications
   - Input validation and sanitization
   - Protection against common web vulnerabilities (CSRF, XSS, SQL Injection)

4. **Operational Security**
   - Rate limiting to prevent abuse
   - Proper error handling without exposing sensitive information
   - Comprehensive logging for audit purposes
   - Regular security updates

## Performance Considerations

1. **Database Optimization**
   - Indexing for frequently queried fields
   - Efficient relationship design
   - Query optimization for complex reports

2. **API Optimization**
   - Response caching for frequently accessed data
   - Pagination for large data sets
   - Eager loading of relationships to prevent N+1 query problems

3. **Scalability**
   - Stateless API design for horizontal scaling
   - Database connection pooling
   - Potential for future microservices architecture

## Implementation Recommendations

1. **Technology Stack**
   - Laravel 10.x
   - MySQL 8.0+
   - Redis for caching (optional)
   - Laravel Sanctum for authentication

2. **Development Approach**
   - API-first development
   - Test-driven development
   - Incremental implementation with frequent integration testing

3. **Documentation**
   - OpenAPI/Swagger documentation for all endpoints
   - Comprehensive error codes and messages
   - Integration guides for the Flutter frontend team

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

## Conclusion

This document provides a comprehensive overview of the backend requirements for the Lucky Betting app. By implementing these requirements, the backend will provide all the necessary functionality to support the Flutter frontend while ensuring security, performance, and scalability.

The backend team should focus on creating a robust API that handles the complex business logic of betting operations, claims processing, and financial tracking while providing a seamless integration experience for the frontend team.
