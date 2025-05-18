# List Hit Bets API Documentation

## Endpoint

`GET /api/bets/hits`

Retrieve a paginated or full list of winning bets ("hit bets") for the authenticated teller. Supports advanced filtering, including D4 sub-selection (S2/S3).

---

## Query Parameters

| Parameter           | Type     | Required | Description                                                                                       |
|---------------------|----------|----------|---------------------------------------------------------------------------------------------------|
| `page`              | integer  | No       | Page number for pagination (default: 1)                                                           |
| `per_page`          | integer  | No       | Number of items per page (default: 20, max: 100)                                                  |
| `all`               | boolean  | No       | If true, returns all results (max 1000) without pagination                                         |
| `date`              | date     | No       | Filter bets by bet date (format: `YYYY-MM-DD`, default: today)                                    |
| `draw_id`           | integer  | No       | Filter by draw ID                                                                                 |
| `search`            | string   | No       | Search by ticket ID or bet number                                                                 |
| `game_type_id`      | integer  | No       | Filter by game type (e.g., S2, S3, D4)                                                            |
| `is_claimed`        | boolean  | No       | Filter by claimed status (`true`, `false`, `1`, `0`)                                              |
| `d4_sub_selection`  | string   | No       | **NEW**: Filter D4 bets by sub-selection (`S2` or `S3`, uppercase only)                           |

---

## Filtering by D4 Sub-selection

- To get only D4-S2 winners: add `d4_sub_selection=S2` to your query.
- To get only D4-S3 winners: add `d4_sub_selection=S3` to your query.
- If not provided, all D4 bets (with or without sub-selection) are included.

---

## Example Request

```
GET /api/bets/hits?date=2025-05-18&game_type_id=3&d4_sub_selection=S2&per_page=10
Authorization: Bearer {token}
```

---

## Example Success Response

```json
{
  "success": true,
  "message": "Winning bets retrieved",
  "data": {
    "current_page": 1,
    "per_page": 10,
    "total": 2,
    "data": [
      {
        "id": 123,
        "bet_number": "1246",
        "amount": 10,
        "winning_amount": 500,
        "draw_id": 45,
        "game_type_id": 3,
        "d4_sub_selection": "S2",
        "is_claimed": false,
        "bet_date": "2025-05-18",
        "ticket_id": "ABC123",
        "created_at": "2025-05-18T11:00:00Z",
        "updated_at": "2025-05-18T11:00:00Z"
      },
      {
        "id": 124,
        "bet_number": "8821",
        "amount": 20,
        "winning_amount": 1000,
        "draw_id": 45,
        "game_type_id": 3,
        "d4_sub_selection": "S2",
        "is_claimed": true,
        "bet_date": "2025-05-18",
        "ticket_id": "DEF456",
        "created_at": "2025-05-18T11:01:00Z",
        "updated_at": "2025-05-18T11:01:00Z"
      }
    ]
  }
}
```

---

## Notes
- The `d4_sub_selection` filter only applies to D4 game type bets. For S2 and S3 game types, use the `game_type_id` filter.
- All filters are optional and can be combined.
- Only authenticated tellers can access this endpoint.
- The API returns paginated results by default. Use `all=true` for a full (max 1000) result set.
- The value for `d4_sub_selection` must be uppercase (`S2` or `S3`).

---

## Changelog
- **2025-05-18**: Added `d4_sub_selection` filter to support granular D4-S2 and D4-S3 winner queries.
