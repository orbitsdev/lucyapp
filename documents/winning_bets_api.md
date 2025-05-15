# Betting System API Documentation - Winning Bets

## List Winning Bets (Hits)

### Endpoint
```
GET /api/betting/hits
```

### Description
Retrieves a paginated list of winning bets (hits) for the authenticated teller, regardless of claim status. This endpoint allows tellers to see all bets that match winning numbers, making it easier to identify unclaimed winning bets. By default, it returns only today's winning bets.

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
| is_claimed | boolean | No | Filter bets by claim status (true/false) |

### Response Format

```json
{
    "status": true,
    "message": "Winning bets retrieved",
    "data": [
        {
            "id": 12,
            "ticket_id": "ABCDE12345",
            "bet_number": "34",
            "amount": "50",
            "is_claimed": false,
            "is_rejected": false,
            "is_combination": false,
            "bet_date": "2025-05-14T16:00:00.000000Z",
            "bet_date_formatted": "May 14, 2025 12:00 AM",
            "created_at": "2025-05-14T08:12:15.000000Z",
            "is_winner": true,
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

1. Get all winning bets for today (default):
```
GET /api/betting/hits
```

2. Get all winning bets for a specific date:
```
GET /api/betting/hits?date=2025-05-13
```

3. Get all winning bets without pagination:
```
GET /api/betting/hits?all=true
```

4. Get winning bets for a specific draw:
```
GET /api/betting/hits?draw_id=15
```

5. Get winning bets for a specific game type:
```
GET /api/betting/hits?game_type_id=1
```

6. Get only claimed winning bets:
```
GET /api/betting/hits?is_claimed=true
```

7. Get only unclaimed winning bets:
```
GET /api/betting/hits?is_claimed=false
```

8. Combine multiple filters:
```
GET /api/betting/hits?date=2025-05-14&game_type_id=1&is_claimed=false
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

### Implementation Details

The endpoint uses an optimized algorithm to efficiently identify winning bets:

1. First, it retrieves a batch of potential winning bets based on the query parameters
2. Then, it filters these bets using the `isHit()` method, which checks if each bet matches the winning numbers **regardless of claim status**
3. For better performance with large datasets, the endpoint:
   - Uses eager loading to minimize database queries
   - Applies a reasonable limit (1000) when retrieving all results
   - Uses a multiplier approach for pagination to ensure enough winning bets are found

### Winning Determination Logic

Bets are determined to be winners based on the following rules:

1. For **2 Digit (S2)** game type:
   - The bet number must exactly match the S2 winning number

2. For **3 Digit (S3)** game type:
   - The bet number must exactly match the S3 winning number

3. For **4 Digit (D4)** game type:
   - The bet number must exactly match the D4 winning number, OR
   - If the bet has a sub-selection 's2', the last 2 digits must match the S2 winning number, OR
   - If the bet has a sub-selection 's3', the last 3 digits must match the S3 winning number

The winning determination is performed by the `isHit()` method in the Bet model, which calls `getIsWinnerAttribute(true)` to check winning status regardless of whether the bet has been claimed or not.

### Notes
- By default, the endpoint returns only today's winning bets
- Results are always filtered by the authenticated teller's ID
- Multiple filters can be combined (e.g., date + game type + is_claimed)
- When using `all=true`, results are limited to 1000 records
- The endpoint uses an optimized algorithm to efficiently identify winning bets
- For D4 bets with sub-selection, the endpoint correctly identifies wins based on both direct matches and sub-selection matches
- **Important**: This endpoint returns all winning bets that match the winning numbers, regardless of whether they have been claimed or not. This differs from the `is_winner` attribute in the model, which normally only considers claimed bets as winners unless explicitly told to ignore claim status.
