# Bet Listing API Documentation

## Overview

The Bet Listing API provides a flexible way to retrieve, filter, and paginate bet records for the authenticated teller. This API supports various filtering options including date, draw, status, and more.

## Endpoint

```
GET /api/betting/list
```

## Authentication

All requests to this endpoint require authentication using a valid Bearer token.

```
Authorization: Bearer {your_token}
```

## Parameters

| Parameter   | Type    | Required | Description                                                                |
|-------------|---------|----------|----------------------------------------------------------------------------|
| page        | integer | No       | Page number for pagination (min: 1)                                        |
| per_page    | integer | No       | Number of items per page (min: 1, max: 100, default: 20)                   |
| all         | boolean | No       | If true, returns all bets without pagination (limited to 1000)             |
| draw_id     | integer | No       | Filter bets by specific draw ID                                            |
| date        | date    | No       | Filter bets by specific date (format: YYYY-MM-DD)                          |
| is_rejected | boolean | No       | Filter by rejection status (true = cancelled bets, false = active bets)    |
| is_claimed  | boolean | No       | Filter by claim status (true = claimed bets, false = unclaimed bets)       |
| search      | string  | No       | Search for bets by ticket ID or bet number                                 |
| status      | string  | No       | Filter by bet status (if your system has additional status fields)         |

## Response Format

### Success Response (Paginated)

```json
{
  "data": [
    {
      "id": 123,
      "ticket_id": "ABC123XYZ",
      "bet_number": "12",
      "amount": 100,
      "is_claimed": false,
      "is_rejected": false,
      "is_combination": false,
      "bet_date": "2025-05-10",
      "bet_date_formatted": "May 10, 2025 02:30 PM",
      "created_at": "2025-05-10T14:30:00.000000Z",
      "game_type": {
        "id": 1,
        "code": "S2",
        "name": "Swertres 2 Digits"
      },
      "draw": {
        "id": 45,
        "draw_date": "2025-05-10",
        "draw_time": "14:00:00",
        "draw_time_formatted": "2:00 PM"
      },
      "teller": {
        "id": 5,
        "name": "John Doe",
        "email": "john@example.com"
      },
      "location": {
        "id": 2,
        "name": "Main Branch",
        "address": "123 Main Street"
      },
      "customer": {
        "id": 10,
        "name": "Jane Smith",
        "email": "jane@example.com"
      }
    },
    // More bet records...
  ],
  "links": {
    "first": "http://localhost/api/betting/list?page=1",
    "last": "http://localhost/api/betting/list?page=5",
    "prev": null,
    "next": "http://localhost/api/betting/list?page=2"
  },
  "meta": {
    "current_page": 1,
    "from": 1,
    "last_page": 5,
    "path": "http://localhost/api/betting/list",
    "per_page": 20,
    "to": 20,
    "total": 95
  },
  "message": "Bets retrieved"
}
```

### Success Response (Non-Paginated)

When using `all=true`:

```json
{
  "data": [
    {
      "id": 123,
      "ticket_id": "ABC123XYZ",
      "bet_number": "12",
      "amount": 100,
      "is_claimed": false,
      "is_rejected": false,
      "is_combination": false,
      "bet_date": "2025-05-10",
      "bet_date_formatted": "May 10, 2025 02:30 PM",
      "created_at": "2025-05-10T14:30:00.000000Z",
      "game_type": {
        "id": 1,
        "code": "S2",
        "name": "Swertres 2 Digits"
      },
      "draw": {
        "id": 45,
        "draw_date": "2025-05-10",
        "draw_time": "14:00:00",
        "draw_time_formatted": "2:00 PM"
      },
      "teller": {
        "id": 5,
        "name": "John Doe",
        "email": "john@example.com"
      },
      "location": {
        "id": 2,
        "name": "Main Branch",
        "address": "123 Main Street"
      },
      "customer": {
        "id": 10,
        "name": "Jane Smith",
        "email": "jane@example.com"
      }
    },
    // More bet records (up to 1000)...
  ],
  "message": "All bets retrieved"
}
```

### Error Response

```json
{
  "message": "Error message here",
  "errors": {
    "field_name": [
      "Validation error message"
    ]
  }
}
```

## Usage Examples

### Basic Usage - First Page of Bets

```
GET /api/betting/list
```

Returns the first page of bets for the authenticated teller, with 20 bets per page.

### Custom Pagination

```
GET /api/betting/list?page=2&per_page=50
```

Returns the second page of bets, with 50 bets per page.

### Get All Bets Without Pagination

```
GET /api/betting/list?all=true
```

Returns all bets (up to 1000) without pagination.

### Filter by Date

```
GET /api/betting/list?date=2025-05-10
```

Returns bets placed on May 10, 2025.

### Filter by Draw

```
GET /api/betting/list?draw_id=45
```

Returns bets for draw ID 45.

### Filter by Cancellation Status

```
GET /api/betting/list?is_rejected=true
```

Returns only cancelled bets.

```
GET /api/betting/list?is_rejected=false
```

Returns only active (non-cancelled) bets.

### Filter by Claim Status

```
GET /api/betting/list?is_claimed=true
```

Returns only claimed bets.

```
GET /api/betting/list?is_claimed=false
```

Returns only unclaimed bets.

### Search for Specific Bets

```
GET /api/betting/list?search=ABC123
```

Returns bets where the ticket ID or bet number contains "ABC123".

### Combining Multiple Filters

```
GET /api/betting/list?date=2025-05-10&draw_id=45&is_rejected=false
```

Returns active (non-cancelled) bets from May 10, 2025, for draw ID 45.

```
GET /api/betting/list?is_claimed=false&is_rejected=false&per_page=100
```

Returns 100 unclaimed and active bets per page.

## Notes

1. All date parameters should be in YYYY-MM-DD format.
2. Boolean parameters accept `true` or `false` (case-insensitive).
3. The API only returns bets for the authenticated teller.
4. The response includes formatted date and time values for better readability.
5. When using `all=true`, the response is limited to 1000 bets for performance reasons.
6. The `search` parameter performs a partial match on both ticket ID and bet number.
7. Results are ordered by creation date, with the most recent bets first.
