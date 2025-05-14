# Claimed Bets API Documentation

## 1. List Claimed Bets

### Endpoint
```
GET /api/betting/claimed
```

### Description
Retrieves a paginated list of claimed bets for the authenticated teller. The endpoint supports various filtering options and can return all claimed bets or paginated results. By default, it returns only today's claimed bets.

### Authentication
- Requires Bearer token authentication
- User must be a teller

### Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| page | integer | No | Page number for pagination (default: 1) |
| per_page | integer | No | Number of items per page (default: 20, max: 100) |
| all | boolean | No | If true, returns all results without pagination (default: false) |
| date | date | No | Filter bets by bet date (format: YYYY-MM-DD, default: today) |
| draw_id | integer | No | Filter bets by specific draw ID |
| search | string | No | Search bets by ticket ID or bet number |
| game_type_id | integer | No | Filter bets by specific game type ID |
| is_winner | boolean | No | Filter bets by winner status (true/false) |

### Response Format

```json
{
    "status": true,
    "message": "Claimed bets retrieved",
    "data": [
        {
            "id": 12,
            "ticket_id": "ABCDE12345",
            "bet_number": "34",
            "amount": "50",
            "is_claimed": true,
            "is_rejected": false,
            "is_combination": false,
            "bet_date": "2025-05-14T16:00:00.000000Z",
            "bet_date_formatted": "May 14, 2025 12:00 AM",
            "claimed_at": "2025-05-14T09:30:15.000000Z",
            "created_at": "2025-05-14T08:12:15.000000Z",
            "game_type": {
                "id": 1,
                "name": "2 Digit",
                "code": "S2",
                "digit_count": 2
            },
            "draw": {
                "id": 15,
                "draw_date": "2025-05-14T16:00:00.000000Z",
                "draw_date_formatted": "May 14, 2025",
                "draw_time": "14:00:00",
                "draw_time_formatted": "2:00 PM",
                "draw_time_simple": "2PM",
                "is_open": false,
                "is_active": true
            },
            "location": {
                "id": 1,
                "name": "Main Branch",
                "address": "Tacurong City",
                "is_active": true
            }
        }
    ],
    "pagination": {
        "current_page": 1,
        "last_page": 1,
        "per_page": 20,
        "total": 1,
        "next_page_url": null,
        "prev_page_url": null
    }
}
```

### Example Requests

1. Get all claimed bets for today (default):
```
GET /api/betting/claimed
```

2. Get all claimed bets for a specific date:
```
GET /api/betting/claimed?date=2025-05-13
```

3. Get all claimed bets without pagination:
```
GET /api/betting/claimed?all=true
```

4. Get claimed bets for a specific draw:
```
GET /api/betting/claimed?draw_id=15
```

5. Get claimed bets for a specific game type:
```
GET /api/betting/claimed?game_type_id=1
```

6. Search claimed bets:
```
GET /api/betting/claimed?search=ABCDE
```

7. Get claimed bets with custom pagination:
```
GET /api/betting/claimed?page=1&per_page=50
```

8. Combine multiple filters:
```
GET /api/betting/claimed?date=2025-05-14&game_type_id=1&draw_id=15
```

### Error Responses

#### 401 Unauthorized
```json
{
    "status": false,
    "message": "Unauthenticated",
    "data": null
}
```

#### 422 Validation Error
```json
{
    "status": false,
    "message": "The given data was invalid",
    "data": {
        "date": ["The date field must be a valid date"],
        "per_page": ["The per page field must be between 1 and 100"],
        "game_type_id": ["The selected game type id is invalid"]
    }
}
```

### Notes
- By default, the endpoint returns only today's claimed bets
- Results are always filtered by the authenticated teller's ID
- Multiple filters can be combined (e.g., date + game type + draw_id)
- When using `all=true`, results are limited to 1000 records
- The endpoint supports both paginated and non-paginated responses

---

## 2. Claim Bet by Ticket ID

### Endpoint
```
POST /api/betting/claim-ticket/{ticket_id}
```

### Description
Claims a bet by its ticket ID. This endpoint allows tellers to mark a bet as claimed after a draw has closed and results are available. Only bets that haven't been claimed or rejected before can be claimed.

### Authentication
- Requires Bearer token authentication
- User must be a teller

### URL Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| ticket_id | string | Yes | The unique ticket ID of the bet to claim |

### Request Body
No request body is required.

### Response Format (Success)

```json
{
    "status": true,
    "message": "Bet claimed successfully",
    "data": null
}
```

### Error Responses

#### 401 Unauthorized
```json
{
    "status": false,
    "message": "Unauthenticated",
    "data": null
}
```

#### 404 Not Found
```json
{
    "status": false,
    "message": "Bet not found or already claimed/cancelled",
    "data": null
}
```

#### 422 Unprocessable Entity
```json
{
    "status": false,
    "message": "Cannot claim bet as the draw is still open",
    "data": null
}
```

#### 500 Server Error
```json
{
    "status": false,
    "message": "Failed to claim bet: [error message]",
    "data": null
}
```

### Example Requests

1. Claim a bet by ticket ID:
```
POST /api/betting/claim-ticket/ABCDE12345
```

### Notes
- The ticket ID must belong to a bet owned by the authenticated teller
- The bet must not be already claimed or rejected
- The draw associated with the bet must be closed (is_open = false)
- When a bet is successfully claimed, its `is_claimed` field is set to true and `claimed_at` is set to the current timestamp
- This endpoint is designed to work with the multi-game lottery system workflow, allowing tellers to claim winning bets after draws are completed

## Recent API Enhancements

### New Fields in Bet Resource

The API now includes additional fields in the Bet resource to support the multi-game lottery system:

1. `claimed_at` - Timestamp when the bet was claimed (only included for claimed bets)
2. `claimed_at_formatted` - Human-readable formatted version of the claim timestamp
3. `d4_sub_selection` - For D4 game type bets, indicates the sub-selection ('s2' or 's3')
4. `is_winner` - Boolean indicating if the bet is a winning bet (based on draw results)

### Updated Example Response

```json
{
    "status": true,
    "message": "Claimed bets retrieved",
    "data": [
        {
            "id": 12,
            "ticket_id": "ABCDE12345",
            "bet_number": "34",
            "amount": "50",
            "is_claimed": true,
            "is_rejected": false,
            "is_combination": false,
            "d4_sub_selection": "s2",
            "bet_date": "2025-05-14T16:00:00.000000Z",
            "bet_date_formatted": "May 14, 2025 12:00 AM",
            "claimed_at": "2025-05-14T09:30:15.000000Z",
            "claimed_at_formatted": "May 14, 2025 09:30 AM",
            "is_winner": true,
            "created_at": "2025-05-14T08:12:15.000000Z",
            "game_type": {
                "id": 3,
                "name": "4 Digit",
                "code": "D4",
                "digit_count": 4
            },
            "draw": {
                "id": 15,
                "draw_date": "2025-05-14T16:00:00.000000Z",
                "draw_date_formatted": "May 14, 2025",
                "draw_time": "14:00:00",
                "draw_time_formatted": "2:00 PM",
                "draw_time_simple": "2PM",
                "is_open": false,
                "is_active": true
            },
            "location": {
                "id": 1,
                "name": "Main Branch",
                "address": "Tacurong City",
                "is_active": true
            }
        }
    ],
    "pagination": {
        "current_page": 1,
        "last_page": 1,
        "per_page": 20,
        "total": 1,
        "next_page_url": null,
        "prev_page_url": null
    }
}
```

### Notes on Field Behavior

- The `d4_sub_selection` field is only included in the response when it has a value (for D4 game type bets)
- The `claimed_at` and `claimed_at_formatted` fields are only included for bets that have been claimed
- The `is_winner` field is calculated dynamically based on the draw results and is only included for claimed bets
- All monetary values use smart formatting (no decimal places for whole numbers)
- Date fields are provided in both raw format (for processing) and formatted (for display)
