# Commission Report API Documentation

## Overview
This API endpoint allows tellers to view their commission percentage and the calculated commission amount for a selected date. The commission percentage is set by the coordinator or defaults to 10% if not specified. The endpoint supports both today's date (default) and custom dates.

---

## Endpoint

`GET /api/teller/commission-report`

### Query Parameters
| Parameter | Type   | Required | Description                                 |
|-----------|--------|----------|---------------------------------------------|
| date      | string | No       | Date in `YYYY-MM-DD` format (default: today). Must be a valid date; invalid formats will return a 422 error.|

### Authentication
- Requires a valid bearer token (Sanctum auth)

---

## Response Format
Returns a JSON object with the following fields:

| Field                      | Type    | Description                                              |
|----------------------------|---------|----------------------------------------------------------|
| date                       | string  | The date for the report (YYYY-MM-DD)                     |
| date_formatted             | string  | Formatted date (e.g., May 18, 2025)                      |
| commission_rate            | number  | Commission percentage (e.g., 10)                         |
| commission_rate_formatted  | string  | Commission percentage with % symbol (e.g., "10%")        |
| total_sales                | number  | Total sales for the date (numeric, no formatting)        |
| total_sales_formatted      | string  | Total sales formatted with commas (e.g., "5,000")        |
| commission_amount          | number  | Computed commission amount (numeric, no formatting)      |
| commission_amount_formatted| string  | Commission amount formatted with peso sign (e.g., "₱1,245.00") |

---

## Example Request

```
GET /api/teller/commission-report?date=2025-05-18
Authorization: Bearer <token>
```

---

## Example Response

```
{
  "success": true,
  "message": "Commission report generated successfully",
  "data": {
    "date": "2025-05-18",
    "date_formatted": "May 18, 2025",
    "commission_rate": 10,
    "commission_rate_formatted": "10%",
    "total_sales": 12450,
    "total_sales_formatted": "12,450",
    "commission_amount": 1245,
    "commission_amount_formatted": "₱1,245.00"
  }
}
```

---

## Calculation Formula

```
commission_amount = total_sales * (commission_rate / 100)
```

---

## Capabilities
- Returns commission rate (from user profile or defaults to 10%)
- Calculates and returns total sales for the specified date
- Calculates and returns commission amount for the specified date
- Supports custom date selection (default is today); can retrieve commission for any past date
- Returns formatted values for easy UI display

---

## Notes
- The endpoint is intended for teller users; coordinators/admins may have different logic.
- If the commission rate is not set in the user profile, it defaults to 10%.
- All monetary values are formatted for mobile-friendly display (commas, peso sign, no decimals for whole numbers).
- Requires authentication.
- If the `date` parameter is provided but not in `YYYY-MM-DD` format, the API will return a `422 Unprocessable Entity` error with a validation message.
