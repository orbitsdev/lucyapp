# Detailed Tallysheet API Documentation

## Endpoint
```
GET /api/teller/reports/detailed-tallysheet
```

## Description
Retrieves a detailed tallysheet of bets for a specific date, with options to filter by game type and draw. The response includes bet numbers, amounts, and grouping by game types.

## Authentication
- Requires Bearer token authentication
- User must be a teller

## Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| date | date | Yes | Filter bets by date (format: YYYY-MM-DD) |
| game_type_id | integer | No | Filter bets by specific game type ID |
| draw_id | integer | No | Filter bets by specific draw ID |
| per_page | integer | No | Number of items per page (default: 50, min: 10, max: 100) |
| page | integer | No | Page number for pagination (default: 1) |
| all | boolean | No | If true, returns all results without pagination (default: false) |

## Response Format

```json
{
    "status": true,
    "message": "Detailed tally sheet retrieved successfully",
    "data": {
        "date": "2025-05-10",
        "date_formatted": "May 10, 2025",
        "game_type": {
            "id": 1,
            "code": "S2",
            "name": "2 Digit"
        },
        "total_amount": 1500.00,
        "total_amount_formatted": "1,500",
        "bets": [
            {
                "bet_number": "22",
                "amount": 100.00,
                "amount_formatted": "100",
                "game_type_code": "S2",
                "draw_time": "14:00:00",
                "draw_time_formatted": "2:00 PM",
                "draw_time_simple": "2PM"
            }
        ],
        "bets_by_game_type": {
            "S2": [
                {
                    "bet_number": "22",
                    "amount": 100.00,
                    "amount_formatted": "100",
                    "game_type_code": "S2",
                    "draw_time": "14:00:00",
                    "draw_time_formatted": "2:00 PM",
                    "draw_time_simple": "2PM"
                }
            ],
            "S3": [],
            "S4": []
        },
        "pagination": {
            "total": 50,
            "current_page": 1
        }
    }
}
```

## Response Fields

### Main Data
| Field | Type | Description |
|-------|------|-------------|
| date | string | The date in YYYY-MM-DD format |
| date_formatted | string | The date in "Month DD, YYYY" format |
| game_type | object | Game type details if filtered by game_type_id |
| total_amount | number | Total amount of all bets |
| total_amount_formatted | string | Formatted total amount with commas |
| bets | array | List of all bets |
| bets_by_game_type | object | Bets grouped by game type code |
| pagination | object | Pagination information (only if not using 'all' parameter) |

### Bet Object
| Field | Type | Description |
|-------|------|-------------|
| bet_number | string | The bet number |
| amount | number | The bet amount |
| amount_formatted | string | Formatted amount with commas |
| game_type_code | string | Code of the game type (e.g., "S2", "S3") |
| draw_time | string | Draw time in 24-hour format (HH:mm:ss) |
| draw_time_formatted | string | Draw time in 12-hour format with minutes (e.g., "2:00 PM") |
| draw_time_simple | string | Draw time in simplified 12-hour format (e.g., "2PM") |

### Game Type Object
| Field | Type | Description |
|-------|------|-------------|
| id | integer | Game type ID |
| code | string | Game type code |
| name | string | Game type name |

### Pagination Object
| Field | Type | Description |
|-------|------|-------------|
| total | integer | Total number of records |
| current_page | integer | Current page number |

## Example Requests

1. Get today's tallysheet:
```
GET /api/teller/reports/detailed-tallysheet?date=2025-05-10
```

2. Get tallysheet for a specific game type:
```
GET /api/teller/reports/detailed-tallysheet?date=2025-05-10&game_type_id=1
```

3. Get tallysheet for a specific draw:
```
GET /api/teller/reports/detailed-tallysheet?date=2025-05-10&draw_id=11
```

4. Get all results without pagination:
```
GET /api/teller/reports/detailed-tallysheet?date=2025-05-10&all=true
```

5. Get paginated results with custom page size:
```
GET /api/teller/reports/detailed-tallysheet?date=2025-05-10&per_page=100&page=1
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
        "date": ["The date field is required"],
        "per_page": ["The per page field must be between 10 and 100"]
    }
}
```

## Notes
- All amounts are formatted with commas for thousands
- Whole numbers are displayed without decimal places
- Numbers with decimals are displayed with 2 decimal places
- The API uses proper timezone conversion for dates and times
- Results are always filtered by the authenticated teller's ID
- The endpoint supports both paginated and non-paginated responses 