# Detailed Tallysheet API Update

## Overview
The Detailed Tallysheet API endpoint has been updated to support the new D4 sub-selection feature. This update allows tellers to view their bets with D4 sub-selections (S2 and S3) separately in the response.

## Endpoint

```
GET /api/teller/reports/detailed-tallysheet
```

## Authentication
- Bearer Token required
- User must have teller role

## Request Parameters

| Parameter    | Type    | Required | Description                                                |
|--------------|---------|----------|------------------------------------------------------------|
| date         | string  | Yes      | Date in YYYY-MM-DD format                                  |
| game_type_id | integer | No       | Filter by game type ID                                     |
| draw_id      | integer | No       | Filter by draw ID                                          |
| per_page     | integer | No       | Number of results per page (default: 50, min: 10, max: 100)|
| page         | integer | No       | Page number (default: 1)                                   |
| all          | boolean | No       | If true, returns all results without pagination            |

## Response Structure

```json
{
  "success": true,
  "message": "Detailed tally sheet retrieved successfully",
  "data": {
    "date": "2025-05-16",
    "date_formatted": "May 16, 2025",
    "game_type": {
      "id": 1,
      "code": "D3",
      "name": "Digit 3"
    },
    "total_amount": 5000,
    "total_amount_formatted": "5,000",
    "bets": [
      {
        "bet_number": "123",
        "amount": 1000,
        "amount_formatted": "1,000",
        "game_type_code": "D3",
        "draw_time": "11:00:00",
        "draw_time_formatted": "11:00 AM",
        "draw_time_simple": "11AM",
        "d4_sub_selection": null,
        "display_type": "D3"
      },
      {
        "bet_number": "4567",
        "amount": 2000,
        "amount_formatted": "2,000",
        "game_type_code": "D4",
        "draw_time": "21:00:00",
        "draw_time_formatted": "9:00 PM",
        "draw_time_simple": "9PM",
        "d4_sub_selection": "S2",
        "display_type": "D4-S2"
      },
      {
        "bet_number": "7890",
        "amount": 2000,
        "amount_formatted": "2,000",
        "game_type_code": "D4",
        "draw_time": "21:00:00",
        "draw_time_formatted": "9:00 PM",
        "draw_time_simple": "9PM",
        "d4_sub_selection": "S3",
        "display_type": "D4-S3"
      }
    ],
    "bets_by_game_type": {
      "D2": [],
      "D3": [
        {
          "bet_number": "123",
          "amount": 1000,
          "amount_formatted": "1,000",
          "game_type_code": "D3",
          "draw_time": "11:00:00",
          "draw_time_formatted": "11:00 AM",
          "draw_time_simple": "11AM",
          "d4_sub_selection": null,
          "display_type": "D3"
        }
      ],
      "D4": [
        {
          "bet_number": "4567",
          "amount": 2000,
          "amount_formatted": "2,000",
          "game_type_code": "D4",
          "draw_time": "21:00:00",
          "draw_time_formatted": "9:00 PM",
          "draw_time_simple": "9PM",
          "d4_sub_selection": "S2",
          "display_type": "D4-S2"
        },
        {
          "bet_number": "7890",
          "amount": 2000,
          "amount_formatted": "2,000",
          "game_type_code": "D4",
          "draw_time": "21:00:00",
          "draw_time_formatted": "9:00 PM",
          "draw_time_simple": "9PM",
          "d4_sub_selection": "S3",
          "display_type": "D4-S3"
        }
      ],
      "D4-S2": [
        {
          "bet_number": "4567",
          "amount": 2000,
          "amount_formatted": "2,000",
          "game_type_code": "D4",
          "draw_time": "21:00:00",
          "draw_time_formatted": "9:00 PM",
          "draw_time_simple": "9PM",
          "d4_sub_selection": "S2",
          "display_type": "D4-S2"
        }
      ],
      "D4-S3": [
        {
          "bet_number": "7890",
          "amount": 2000,
          "amount_formatted": "2,000",
          "game_type_code": "D4",
          "draw_time": "21:00:00",
          "draw_time_formatted": "9:00 PM",
          "draw_time_simple": "9PM",
          "d4_sub_selection": "S3",
          "display_type": "D4-S3"
        }
      ]
    },
    "pagination": {
      "total": 3,
      "current_page": 1
    }
  }
}
```

## Key Changes

1. **New Fields in Bet Objects**:
   - `d4_sub_selection`: Contains the sub-selection value for D4 bets ("S2" or "S3"), or null for other game types
   - `display_type`: Contains the game type code, or for D4 bets with sub-selection, a combined format like "D4-S2"

2. **New Categories in bets_by_game_type**:
   - In addition to standard game type categories (D2, D3, D4, etc.), there are now specific categories for D4 sub-selections:
     - `D4-S2`: Contains only D4 bets with S2 sub-selection
     - `D4-S3`: Contains only D4 bets with S3 sub-selection

3. **Categorization Logic**:
   - All bets are added to their standard game type category (D2, D3, D4, etc.)
   - D4 bets with sub-selections are additionally added to their specific sub-category (D4-S2 or D4-S3)
   - D4 bets without sub-selections are only added to the standard D4 category

## Frontend Implementation Notes

When implementing this in the frontend:

1. Use the `bets_by_game_type` object to display bets grouped by game type
2. For D4 bets, you can now show separate sections for:
   - All D4 bets (using the "D4" key)
   - Only D4-S2 bets (using the "D4-S2" key)
   - Only D4-S3 bets (using the "D4-S3" key)
3. Use the `display_type` field when showing individual bets to properly indicate D4 sub-selections
4. The `d4_sub_selection` field can be used for additional filtering or conditional display logic

## Error Responses

| Status Code | Description                                  |
|-------------|----------------------------------------------|
| 500         | Server error with detailed error message     |
| 422         | Validation error with detailed error message |
| 401         | Unauthorized - Invalid or missing token      |
