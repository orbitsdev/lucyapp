# Betting System API Documentation - Claim Bets

## Claim Bet by Ticket ID

### Endpoint
```
POST /api/betting/claim-ticket
```

### Description
Claims a winning bet using its ticket ID. This endpoint allows tellers to mark a winning bet as claimed, which is necessary for payout processing. Only winning bets (hits) that have not been previously claimed can be processed through this endpoint.

### Authentication
- Requires Bearer token authentication
- User must be a teller

### Request Format

```json
{
    "ticket_id": "ABCDE12345"
}
```

### Response Format

```json
{
    "status": true,
    "message": "Bet claimed successfully",
    "data": {
        "id": 12,
        "ticket_id": "ABCDE12345",
        "bet_number": "34",
        "amount": "50",
        "is_claimed": true,
        "is_rejected": false,
        "is_combination": false,
        "bet_date": "2025-05-14T16:00:00.000000Z",
        "bet_date_formatted": "May 14, 2025 12:00 AM",
        "created_at": "2025-05-14T08:12:15.000000Z",
        "claimed_at": "2025-05-15T08:30:45.000000Z",
        "claimed_at_formatted": "May 15, 2025 8:30 AM",
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
    "message": "Bet not found",
    "data": null
}
```

#### 422 Validation Error
```json
{
    "status": false,
    "message": "The given data was invalid",
    "data": {
        "ticket_id": ["The ticket ID field is required"]
    }
}
```

#### 400 Bad Request
```json
{
    "status": false,
    "message": "This bet is not a winning bet",
    "data": null
}
```

```json
{
    "status": false,
    "message": "This bet has already been claimed",
    "data": null
}
```

### Implementation Details

The endpoint performs the following operations:

1. Validates the ticket ID provided in the request
2. Retrieves the bet associated with the ticket ID
3. Verifies that the bet is a winning bet (matches winning numbers)
4. Checks that the bet has not already been claimed
5. Updates the bet's claim status and sets the claimed_at timestamp
6. Returns the updated bet details

### Claim Process

The claiming process follows these steps:

1. The teller enters or scans the ticket ID
2. The system validates the ticket and checks if it's a winning bet
3. If valid, the bet is marked as claimed with a timestamp
4. The updated bet details are returned, including the claim timestamp
5. The bet will now appear in the claimed bets list and will be marked as claimed in the winning bets list

### Notes
- Only winning bets can be claimed
- A bet can only be claimed once
- The claim process is recorded with a timestamp for audit purposes
- The teller who claims the bet is associated with the claim record
- Claimed bets appear in both the winning bets list (with claimed status) and the claimed bets list
- The API performs validation to ensure the ticket ID exists and corresponds to a valid winning bet
- If a bet is already claimed, the API will return an error message
- The response includes the full bet details, including the claim timestamp and formatted date
