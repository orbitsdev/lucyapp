# Bets API Documentation

## Endpoint
```
GET /api/betting
```

## Description
Retrieves a paginated list of bets for the authenticated teller. The endpoint supports various filtering options and can return all bets or paginated results.

## Authentication
- Requires Bearer token authentication
- User must be a teller

## Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| page | integer | No | Page number for pagination (default: 1) |
| per_page | integer | No | Number of items per page (default: 20, max: 100) |
| all | boolean | No | If true, returns all results without pagination (default: false) |
| draw_id | integer | No | Filter bets by specific draw ID |
| date | date | No | Filter bets by bet date (format: YYYY-MM-DD) |
| is_rejected | string | No | Filter by rejection status (true/false/0/1) |
| is_claimed | string | No | Filter by claim status (true/false/0/1) |
| game_type_id | integer | No | Filter bets by specific game type ID |
| search | string | No | Search bets by ticket ID or bet number |

## Response Format

```json
{
    "status": true,
    "message": "Bets retrieved",
    "data": [
        {
            "id": 7,
            "ticket_id": "YWF0LRMNRF",
            "bet_number": "22",
            "amount": "10",
            "is_claimed": false,
            "is_rejected": false,
            "is_combination": false,
            "bet_date": "2025-05-10T16:00:00.000000Z",
            "bet_date_formatted": "May 11, 2025 12:00 AM",
            "created_at": "2025-05-11T02:12:15.000000Z",
            "game_type": {
                "id": 1,
                "name": "2 Digit",
                "code": "S2",
                "digit_count": 2
            },
            "draw": {
                "id": 11,
                "draw_date": "2025-05-10T16:00:00.000000Z",
                "draw_date_formatted": "May 11, 2025",
                "draw_time": "14:00:00",
                "draw_time_formatted": "2:00 PM",
                "draw_time_simple": "2PM",
                "is_open": true,
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

## Example Requests

1. Get all bets (paginated):
```
GET /api/betting
```

2. Get all bets without pagination:
```
GET /api/betting?all=true
```

3. Get bets for a specific date:
```
GET /api/betting?date=2025-05-10
```

4. Get bets for a specific draw:
```
GET /api/betting?draw_id=11
```

5. Get bets for a specific game type:
```
GET /api/betting?game_type_id=1
```

6. Get rejected bets:
```
GET /api/betting?is_rejected=true
```

7. Get claimed bets:
```
GET /api/betting?is_claimed=true
```

8. Search bets:
```
GET /api/betting?search=YWF0
```

9. Get bets with custom pagination:
```
GET /api/betting?page=1&per_page=50
```

## Error Responses

### 401 Unauthorized
```json
{
    "status": false,
    "message": "Unauthenticated",
    "data": null
}
```

### 422 Validation Error
```json
{
    "status": false,
    "message": "The given data was invalid",
    "data": {
        "date": ["The date field must be a valid date"],
        "per_page": ["The per page field must be between 1 and 100"],
        "is_rejected": ["The is rejected field must be true, false, 0, or 1"],
        "is_claimed": ["The is claimed field must be true, false, 0, or 1"],
        "game_type_id": ["The selected game type id is invalid"]
    }
}
```

## Notes
- All dates are handled in the application's timezone
- The API uses proper timezone conversion to ensure accurate date filtering
- Results are always filtered by the authenticated teller's ID
- Multiple filters can be combined (e.g., date + game type + is_rejected)
- When using `all=true`, results are limited to 1000 records
- The endpoint supports both paginated and non-paginated responses 