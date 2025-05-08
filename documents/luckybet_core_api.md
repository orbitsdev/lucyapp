# LuckyBet Admin API Documentation

## Overview

The LuckyBet Admin API provides endpoints for managing betting operations, including user authentication, bet placement, reporting, and dropdown data for the frontend. This document outlines all available endpoints, request parameters, and response formats.

## Purpose and Architecture

### Purpose

The LuckyBet Admin API serves as the backend interface for the LuckyBet betting system, enabling:

1. **Teller Operations**: Allows tellers to place bets, view bet history, and cancel bets
2. **Reporting**: Provides detailed reports on sales and performance metrics
3. **Data Management**: Offers access to game types, schedules, and draw information
4. **Authentication**: Secures the system with token-based authentication

### System Architecture

```
┌─────────────────┐      ┌────────────────┐      ┌────────────────┐
│                 │      │                │      │                │
│  Mobile Client  │◄────►│  LuckyBet API  │◄────►│    Database    │
│                 │      │                │      │                │
└─────────────────┘      └────────────────┘      └────────────────┘
                                 ▲
                                 │
                                 ▼
                         ┌────────────────┐
                         │                │
                         │ Admin Dashboard│
                         │                │
                         └────────────────┘
```

### Key Workflows

#### Betting Flow

```
┌─────────┐     ┌────────────────┐     ┌───────────────┐
│  Teller │     │ Betting System │     │ Report System │
│         │     │                │     │               │
└────┬────┘     └────────┬───────┘     └───────┬───────┘
     │                   │                     │
     │  Get Available    │                     │
     │  Draws            │                     │
     │ ─────────────────>│                     │
     │                   │                     │
     │   Return Draws    │                     │
     │ <─────────────────│                     │
     │                   │                     │
     │   Place Bet       │                     │
     │ ─────────────────>│                     │
     │                   │                     │
     │   Bet Confirmed   │                     │
     │ <─────────────────│                     │
     │                   │                     │
     │   Cancel Bet      │                     │
     │ ─────────────────>│                     │
     │                   │                     │
     │  Cancellation     │                     │
     │  Confirmed        │                     │
     │ <─────────────────│                     │
     │                   │                     │
     │  Request Report   │                     │
     │ ───────────────────────────────────────>│
     │                   │                     │
     │   Return Report   │                     │
     │ <───────────────────────────────────────│
     │                   │                     │
```

### Implementation Requirements

#### For Mobile Developers

1. **Authentication**: 
   - Implement secure token storage
   - Include token in all API requests
   - Handle token expiration and refresh

2. **Data Handling**:
   - Cache dropdown data (game types, schedules)
   - Implement proper date formatting
   - Handle pagination for list endpoints

3. **Error Handling**:
   - Check `status` field in all responses
   - Display appropriate error messages
   - Implement retry logic for network failures

4. **UI Requirements**:
   - Implement bet slip creation interface
   - Display reports with proper formatting
   - Show bet history with filtering options

## Table of Contents

- [Authentication](#authentication)
- [Dropdown Data](#dropdown-data)
- [Betting Operations](#betting-operations)
- [Reports](#reports)

## Authentication

### Register

Register a new user account.

**Endpoint:** `POST /api/register`

**Request:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "password_confirmation": "password123",
  "role": "teller"
}
```

**Response:**
```json
{
  "status": true,
  "message": "User registered successfully",
  "data": {
    "user": {
      "id": 1,
      "name": "John Doe",
      "username": "johndoe",
      "email": "john@example.com",
      "phone": "+1234567890",
      "role": "teller",
      "location": null,
      "is_active": true,
      "profile_photo_url": null
    },
    "token": "1|a1b2c3d4e5f6g7h8i9j0..."
  }
}
```

### Login

Authenticate a user and receive an access token.

**Endpoint:** `POST /api/login`

**Request:**
```json
{
  "email": "john@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "status": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": 1,
      "name": "John Doe",
      "username": "johndoe",
      "email": "john@example.com",
      "phone": "+1234567890",
      "role": "teller",
      "location": null,
      "is_active": true,
      "profile_photo_url": null
    },
    "token": "1|a1b2c3d4e5f6g7h8i9j0..."
  }
}
```

### Get Current User

Get the currently authenticated user's details.

**Endpoint:** `GET /api/user`

**Headers:**
```
Authorization: Bearer <token>
```

**Response:**
```json
{
  "status": true,
  "message": "User details retrieved",
  "data": {
    "id": 1,
    "name": "John Doe",
    "username": "johndoe",
    "email": "john@example.com",
    "phone": "+1234567890",
    "role": "teller",
    "location": {
      "id": 1,
      "name": "Downtown Branch",
      "address": "123 Main Street",
      "is_active": true
    },
    "is_active": true,
    "profile_photo_url": null
  }
}
```

### Logout

Invalidate the current user's token.

**Endpoint:** `POST /api/logout`

**Headers:**
```
Authorization: Bearer <token>
```

**Response:**
```json
{
  "status": true,
  "message": "Logged out successfully"
}
```

## Dropdown Data

All dropdown endpoints require authentication.

### Game Types

Get all active game types.

**Endpoint:** `GET /api/dropdown/game-types`

**Headers:**
```
Authorization: Bearer <token>
```

**Response:**
```json
{
  "status": true,
  "message": "Success",
  "data": [
    {
      "id": 1,
      "name": "3D",
      "code": "3D"
    }
  ]
}
```

### Schedules

Get all active schedules.

**Endpoint:** `GET /api/dropdown/schedules`

**Headers:**
```
Authorization: Bearer <token>
```

**Response:**
```json
{
  "status": true,
  "message": "Success",
  "data": [
    {
      "id": 1,
      "name": "Morning",
      "draw_time": "11:00:00",
      "draw_time_formatted": "11:00 AM"
    }
  ]
}
```

### Draws

Get all open draws.

**Endpoint:** `GET /api/dropdown/draws`

**Headers:**
```
Authorization: Bearer <token>
```

**Response:**
```json
{
  "status": true,
  "message": "Success",
  "data": [
    {
      "id": 1,
      "draw_date": "2025-05-08",
      "draw_date_formatted": "May 08, 2025",
      "draw_time": "11:00:00",
      "draw_time_formatted": "11:00 AM",
      "is_open": true,
      "is_active": true
    }
  ]
}
```

### Available Dates

Get all dates with draws for dropdown/calendar.

**Endpoint:** `GET /api/dropdown/available-dates`

**Headers:**
```
Authorization: Bearer <token>
```

**Response:**
```json
{
  "status": true,
  "message": "Available draw dates fetched successfully",
  "data": {
    "available_dates": [
      {
        "id": 1,
        "date": "2025-05-08",
        "date_formatted": "May 8, 2025"
      }
    ]
  }
}
```

## Betting Operations

All betting endpoints require authentication.

### Available Draws for Betting

Get all available draws for today.

**Endpoint:** `GET /api/betting/available-draws`

**Headers:**
```
Authorization: Bearer <token>
```

**Response:**
```json
{
  "status": true,
  "message": "Success",
  "data": [
    {
      "id": 1,
      "draw_date": "2025-05-08",
      "draw_date_formatted": "May 08, 2025",
      "draw_time": "11:00:00",
      "draw_time_formatted": "11:00 AM",
      "is_open": true,
      "is_active": true
    }
  ]
}
```

### Place Bet

Place a new bet.

**Endpoint:** `POST /api/betting/place`

**Headers:**
```
Authorization: Bearer <token>
```

**Request:**
```json
{
  "bet_number": "123",
  "amount": 50,
  "draw_id": 1,
  "game_type_id": 1,
  "customer_id": null,
  "is_combination": false
}
```

**Response:**
```json
{
  "status": true,
  "message": "Bet placed successfully",
  "data": {
    "id": 101,
    "ticket_id": "A1B2C3D4E5",
    "bet_number": "123",
    "amount": 50.00,
    "status": "active",
    "is_claimed": false,
    "is_rejected": false,
    "is_combination": false,
    "bet_date": "2025-05-08",
    "bet_date_formatted": "May 08, 2025 10:45 AM",
    "created_at": "2025-05-08T10:45:12.000000Z",
    "game_type": {
      "id": 1,
      "name": "3D",
      "code": "3D"
    },
    "draw": {
      "id": 1,
      "draw_date": "2025-05-08",
      "draw_date_formatted": "May 08, 2025",
      "draw_time": "11:00:00",
      "draw_time_formatted": "11:00 AM",
      "is_open": true,
      "is_active": true
    },
    "teller": {
      "id": 1,
      "name": "John Doe",
      "username": "johndoe",
      "email": "john@example.com",
      "phone": "+1234567890",
      "role": "teller",
      "is_active": true,
      "profile_photo_url": null
    },
    "location": {
      "id": 1,
      "name": "Downtown Branch",
      "address": "123 Main Street",
      "is_active": true
    },
    "customer": null
  }
}
```

### List Bets

List bets for the authenticated teller with optional filtering.

**Endpoint:** `GET /api/betting/list`

**Headers:**
```
Authorization: Bearer <token>
```

**Query Parameters:**
- `page` (optional): Page number for pagination
- `per_page` (optional): Items per page (default: 20, max: 100)
- `all` (optional): If true, returns all bets (up to 1000)
- `draw_id` (optional): Filter by draw ID
- `date` (optional): Filter by date (YYYY-MM-DD)
- `search` (optional): Search by ticket ID or bet number
- `status` (optional): Filter by bet status

**Response:**
```json
{
  "status": true,
  "message": "Bets retrieved",
  "data": [
    {
      "id": 101,
      "ticket_id": "A1B2C3D4E5",
      "bet_number": "123",
      "amount": 50.00,
      "status": "active",
      "is_claimed": false,
      "is_rejected": false,
      "is_combination": false,
      "bet_date": "2025-05-08",
      "bet_date_formatted": "May 08, 2025 10:45 AM",
      "created_at": "2025-05-08T10:45:12.000000Z",
      "game_type": {
        "id": 1,
        "name": "3D",
        "code": "3D"
      },
      "draw": {
        "id": 1,
        "draw_date": "2025-05-08",
        "draw_date_formatted": "May 08, 2025",
        "draw_time": "11:00:00",
        "draw_time_formatted": "11:00 AM",
        "is_open": true,
        "is_active": true
      },
      "teller": {
        "id": 1,
        "name": "John Doe",
        "username": "johndoe",
        "email": "john@example.com",
        "phone": "+1234567890",
        "role": "teller",
        "is_active": true,
        "profile_photo_url": null
      },
      "location": {
        "id": 1,
        "name": "Downtown Branch",
        "address": "123 Main Street",
        "is_active": true
      },
      "customer": null
    }
  ],
  "pagination": {
    "current_page": 1,
    "last_page": 5,
    "per_page": 20,
    "total": 100,
    "next_page_url": "http://example.com/api/betting/list?page=2",
    "prev_page_url": null
  }
}
```

### Cancel Bet

Cancel an active bet.

**Endpoint:** `POST /api/betting/cancel/{id}`

**Headers:**
```
Authorization: Bearer <token>
```

**Response:**
```json
{
  "status": true,
  "message": "Bet cancelled successfully",
  "data": null
}
```

**Error Responses:**

When bet not found or already cancelled:
```json
{
  "status": false,
  "message": "Bet not found or already cancelled",
  "data": null
}
```

When draw is closed:
```json
{
  "status": false,
  "message": "Cannot cancel bet as the draw is closed",
  "data": null
}
```

When server error occurs:
```json
{
  "status": false,
  "message": "Failed to cancel bet: [error message]",
  "data": null
}
```

### List Cancelled Bets

List all cancelled bets for the authenticated teller.

**Endpoint:** `GET /api/betting/cancelled`

**Headers:**
```
Authorization: Bearer <token>
```

**Query Parameters:**
- `search` (optional): Search by ticket ID or bet number

**Response:**
```json
{
  "status": true,
  "message": "Cancelled bets retrieved",
  "data": [
    {
      "id": 123,
      "ticket_id": "A1B2C3D4E5",
      "bet_number": "24",
      "amount": 20.00,
      "status": "active",
      "is_claimed": false,
      "is_rejected": true,
      "is_combination": false,
      "bet_date": "2025-05-08",
      "bet_date_formatted": "May 08, 2025 05:00 PM",
      "created_at": "2025-05-08T09:45:00.000000Z",
      "game_type": {
        "id": 1,
        "name": "3D",
        "code": "3D"
      },
      "draw": {
        "id": 5,
        "draw_date": "2025-05-08",
        "draw_date_formatted": "May 08, 2025",
        "draw_time": "17:00:00",
        "draw_time_formatted": "05:00 PM",
        "is_open": true,
        "is_active": true
      },
      "teller": {
        "id": 2,
        "name": "Juan Dela Cruz"
      },
      "location": {
        "id": 1,
        "name": "Downtown Branch",
        "address": "123 Main Street",
        "is_active": true
      },
      "customer": null
    }
  ]
}
```

## Reports

All report endpoints require authentication.

### Tallysheet Report

Get a detailed tallysheet report with per-draw breakdown.

**Endpoint:** `GET /api/reports/tallysheet`

**Headers:**
```
Authorization: Bearer <token>
```

**Query Parameters:**
- `date` (required): Report date (YYYY-MM-DD)
- `teller_id` (optional): Filter by teller ID
- `location_id` (optional): Filter by location ID
- `draw_id` (optional): Filter by draw ID

**Response:**
```json
{
  "status": true,
  "message": "Tallysheet report generated",
  "data": {
    "date": "2025-05-08",
    "gross": 5000.00,
    "sales": 4950.00,
    "hits": 1200.00,
    "kabig": 3800.00,
    "voided": 200.00,
    "per_draw": [
      {
        "draw_id": 1,
        "type": "Regular",
        "winning_number": "123",
        "draw_label": "1: 11:00:00",
        "gross": 2000.00,
        "sales": 1950.00,
        "hits": 500.00,
        "kabig": 1500.00
      }
    ]
  }
}
```

### Sales Report

Get a detailed sales report with per-draw breakdown.

**Endpoint:** `GET /api/reports/sales`

**Headers:**
```
Authorization: Bearer <token>
```

**Query Parameters:**
- `date` (optional): Report date (YYYY-MM-DD), defaults to today
- `draw_id` (optional): Filter by draw ID

**Response:**
```json
{
  "status": true,
  "message": "Tally sheet generated successfully",
  "data": {
    "date": "2025-05-08",
    "date_formatted": "May 8, 2025",
    "totals": {
      "sales": 5000.00,
      "hits": 1200.00,
      "gross": 3800.00,
      "voided": 3
    },
    "draws": [
      {
        "draw_id": 1,
        "time": "11:00 AM",
        "type": "Regular",
        "winning_number": "123",
        "sales": 2000.00,
        "hits": 500.00,
        "gross": 1500.00,
        "voided": 1
      }
    ]
  }
}
```

## Error Handling

All API endpoints return standardized error responses:

```json
{
  "status": false,
  "message": "Error message describing what went wrong",
  "errors": {
    "field_name": [
      "Validation error message"
    ]
  }
}
```

Common HTTP status codes:
- 200: Success
- 400: Bad Request (validation errors)
- 401: Unauthorized (invalid or missing token)
- 403: Forbidden (insufficient permissions)
- 404: Not Found
- 422: Unprocessable Entity (validation errors)
- 500: Server Error

## Notes for Developers

1. **Authentication**: Store the token securely and include it in the `Authorization` header for all protected endpoints.
2. **Date Formats**: 
   - Input dates should be in `YYYY-MM-DD` format
   - Response dates include both raw (`date`) and formatted (`date_formatted`) versions
3. **Dropdown Data**: Cache dropdown data where appropriate to reduce API calls
4. **Error Handling**: Always check the `status` field to determine if the request was successful
5. **Pagination**: For list endpoints, check the `pagination` object for pagination information

## Testing the API

To test the API endpoints, you can use tools like Postman or cURL. Here's a sample testing workflow:

1. **Authentication**:
   ```bash
   curl -X POST http://your-domain.com/api/login \
     -H "Content-Type: application/json" \
     -d '{"email":"teller@example.com","password":"password123"}'
   ```

2. **Place a Bet**:
   ```bash
   curl -X POST http://your-domain.com/api/betting/place \
     -H "Authorization: Bearer YOUR_TOKEN" \
     -H "Content-Type: application/json" \
     -d '{"bet_number":"123","amount":50,"draw_id":1,"game_type_id":1}'
   ```

3. **Get a Report**:
   ```bash
   curl -X GET "http://your-domain.com/api/reports/tallysheet?date=2025-05-08" \
     -H "Authorization: Bearer YOUR_TOKEN"
   ```

## Conclusion

The LuckyBet Admin API provides a comprehensive set of endpoints for managing betting operations. By following the documentation and implementation guidelines, developers can create robust mobile and web applications that interact seamlessly with the betting system.


