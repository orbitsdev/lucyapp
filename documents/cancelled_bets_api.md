# Cancelled Bets API Documentation

## Endpoint
```
GET /api/betting/cancelled
```

## Description
Retrieves a paginated list of cancelled bets for the authenticated teller. The endpoint supports various filtering options and defaults to showing today's cancelled bets if no date is specified.

## Authentication
- Requires Bearer token authentication
- User must be a teller

## Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| page | integer | No | Page number for pagination (default: 1) |
| per_page | integer | No | Number of items per page (default: 20, max: 100) |
| date | date | No | Filter bets by draw date (format: YYYY-MM-DD). If not provided, defaults to today's date |
| draw_id | integer | No | Filter bets by specific draw ID |
| search | string | No | Search bets by ticket ID or bet number |

## Response Format

```json
{
    "status": true,
    "message": "Cancelled bets retrieved",
    "data": [
        {
            "id": 7,
            "ticket_id": "YWF0LRMNRF",
            "bet_number": "22",
            "amount": "10",
            "is_claimed": false,
            "is_rejected": true,
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

## Default Behavior
- If no date is provided, the API returns cancelled bets for the current day
- Results are ordered by latest first
- Only shows bets that belong to the authenticated teller
- Only includes bets where `is_rejected` is true

## Example Requests

1. Get today's cancelled bets:
```
GET /api/betting/cancelled
```

2. Get cancelled bets for a specific date:
```
GET /api/betting/cancelled?date=2025-05-10
```

3. Get cancelled bets for a specific draw:
```
GET /api/betting/cancelled?draw_id=11
```

4. Search cancelled bets:
```
GET /api/betting/cancelled?search=YWF0
```

5. Get cancelled bets with custom pagination:
```
GET /api/betting/cancelled?page=1&per_page=50
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
        "per_page": ["The per page field must be between 1 and 100"]
    }
}
```

## Notes
- All dates are handled in the application's timezone
- The API uses proper timezone conversion to ensure accurate date filtering
- Results are always filtered by the authenticated teller's ID
- The endpoint supports both date-based and draw-specific filtering 