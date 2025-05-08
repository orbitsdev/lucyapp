# Teller Reports API Documentation

This document provides detailed information about the Teller Reports API endpoints available in the LuckyBet Admin system. These endpoints are designed to help tellers and administrators access sales data, hits, and other important metrics.

## Table of Contents

- [Authentication](#authentication)
- [Tallysheet Report](#tallysheet-report)
- [Sales Report](#sales-report)
- [Response Format](#response-format)
- [Error Handling](#error-handling)
- [Implementation Guide](#implementation-guide)

## Authentication

All API endpoints require authentication. Include your API token in the request header:

```
Authorization: Bearer {your_api_token}
```

## Tallysheet Report

The Tallysheet Report provides a comprehensive breakdown of bets, sales, hits, and gross profit by draw.

### Endpoint

```
GET /api/teller/tallysheet
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| date | string (YYYY-MM-DD) | Yes | The date to generate the report for |
| teller_id | integer | No | Filter by specific teller ID |
| location_id | integer | No | Filter by specific location ID |
| draw_id | integer | No | Filter by specific draw ID |

### Example Request

```
GET /api/teller/tallysheet?date=2025-05-08&teller_id=3
```

### Example Response

```json
{
  "success": true,
  "message": "Tallysheet report generated",
  "data": {
    "date": "2025-05-08",
    "date_formatted": "May 8, 2025",
    "gross": 5000,
    "gross_formatted": "5,000.00",
    "sales": 5000,
    "sales_formatted": "5,000.00",
    "hits": 1000,
    "hits_formatted": "1,000.00",
    "kabig": 4000,
    "kabig_formatted": "4,000.00",
    "voided": 0,
    "voided_formatted": "0.00",
    "per_draw": [
      {
        "draw_id": 11,
        "type": null,
        "winning_number": "23",
        "draw_time": "14:00:00",
        "draw_time_formatted": "2:00 PM",
        "draw_label": "Draw #11: 2:00 PM",
        "gross": 2000,
        "gross_formatted": "2,000.00",
        "sales": 2000,
        "sales_formatted": "2,000.00",
        "hits": 500,
        "hits_formatted": "500.00",
        "kabig": 1500,
        "kabig_formatted": "1,500.00"
      }
    ]
  }
}
```

### Visualization Example

```
+----------------------------------------------------------+
|                  TALLYSHEET REPORT                       |
|                    May 8, 2025                           |
+----------------------------------------------------------+
| SUMMARY                                                  |
| Total Sales: 5,000.00                                   |
| Total Hits:  1,000.00                                   |
| Total Gross: 4,000.00                                   |
| Voided Bets: 0.00                                       |
+----------------------------------------------------------+
| DRAW BREAKDOWN                                           |
+----------------------------------------------------------+
| Draw #11: 2:00 PM                                        |
| Sales:     2,000.00                                     |
| Hits:      500.00                                       |
| Gross:     1,500.00                                     |
+----------------------------------------------------------+
```

## Sales Report

The Sales Report provides a summary of sales data for the logged-in teller, broken down by draw.

### Endpoint

```
GET /api/teller/sales
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| date | string (YYYY-MM-DD) | No | The date to generate the report for (defaults to today) |
| draw_id | integer | No | Filter by specific draw ID |

### Example Request

```
GET /api/teller/sales?date=2025-05-08
```

### Example Response

```json
{
  "success": true,
  "message": "Tally sheet generated successfully",
  "data": {
    "date": "2025-05-08",
    "date_formatted": "May 8, 2025",
    "totals": {
      "sales": 5000,
      "sales_formatted": "5,000.00",
      "hits": 1000,
      "hits_formatted": "1,000.00",
      "gross": 4000,
      "gross_formatted": "4,000.00",
      "voided": 2,
      "voided_formatted": "2 bet(s)"
    },
    "draws": [
      {
        "draw_id": 11,
        "time": "2:00 PM",
        "time_formatted": "2:00 PM",
        "game_type_code": "S2",
        "game_type_name": "Swertres 2",
        "winning_number": "23",
        "sales": 2000,
        "sales_formatted": "2,000.00",
        "hits": 500,
        "hits_formatted": "500.00",
        "gross": 1500,
        "gross_formatted": "1,500.00",
        "voided": 1,
        "voided_formatted": "1 bet(s)",
        "draw_label": "Draw #11: 2:00 PM (Swertres 2)"
      }
    ]
  }
}
```

### Visualization Example

```
+----------------------------------------------------------+
|                    SALES REPORT                          |
|                    May 8, 2025                           |
+----------------------------------------------------------+
| SUMMARY                                                  |
| Total Sales: 5,000.00                                   |
| Total Hits:  1,000.00                                   |
| Total Gross: 4,000.00                                   |
| Voided Bets: 2 bet(s)                                    |
+----------------------------------------------------------+
| DRAW BREAKDOWN                                           |
+----------------------------------------------------------+
| Draw #11: 2:00 PM (Swertres 2)                           |
| Winning Number: 23                                        |
| Sales:     2,000.00                                     |
| Hits:      500.00                                       |
| Gross:     1,500.00                                     |
| Voided:    1 bet(s)                                      |
+----------------------------------------------------------+
```

## Response Format

All API responses follow a consistent format:

```json
{
  "success": true|false,
  "message": "Human-readable message",
  "data": { ... } // Response data object
}
```

## Error Handling

When an error occurs, the API will return an error response:

```json
{
  "success": false,
  "message": "Error message describing what went wrong",
  "errors": { ... } // Optional validation errors
}
```

Common error codes:
- 400: Bad Request (invalid parameters)
- 401: Unauthorized (invalid or missing token)
- 403: Forbidden (insufficient permissions)
- 404: Not Found
- 500: Server Error

## Implementation Guide

### How to Use in Flutter

1. **Making API Calls**: Use Flutter's http package or Dio to make API calls to the endpoints.

2. **Date Selection**: Implement a date picker to allow users to select the date for which they want to view reports.

3. **Displaying Reports**: Use the formatted values provided in the API response for display purposes. For example:
   - Use `date_formatted` for showing the date in a user-friendly format
   - Use `sales_formatted`, `hits_formatted`, etc. for displaying monetary values with proper formatting
   - Use `draw_label` for displaying draw information in headers

4. **Handling Different Game Types**: The API handles different game types (S2, S3, D4) and their winning numbers automatically. The response includes game type information for each draw.

5. **UI Components**: Consider using the following UI components:
   - Cards for each draw
   - Tables for displaying sales data
   - Summary sections for totals
   - Error messages for handling API errors

### Key Features to Implement

1. **Date Navigation**: Allow users to navigate between dates easily (previous/next day buttons).

2. **Filtering**: Implement filtering by draw ID when needed for detailed views.

3. **Refresh Functionality**: Add pull-to-refresh to update the data.

4. **Offline Support**: Consider caching responses for offline viewing.

5. **Error Handling**: Display user-friendly error messages when API calls fail.

### Data Fields Explanation

1. **Raw vs. Formatted Values**: The API provides both raw numeric values (e.g., `sales: 5000`) and formatted values (e.g., `sales_formatted: "5,000.00"`).
   - Use raw values for calculations
   - Use formatted values for display

2. **Draw Labels**: The `draw_label` field combines the draw ID, time, and game type in a user-friendly format, ready for display.

3. **Totals**: The `totals` object in the sales report provides aggregated values across all draws.

4. **Kabig**: This represents the gross profit (sales minus hits).

### Important Notes

1. **Game Types**: The system supports multiple game types (S2, S3, D4) with different digit counts. The winning number calculation is based on the game type of each bet.

2. **Formatted Values**: All monetary values are provided in both raw format (for calculations) and formatted format (for display) with proper number formatting.

3. **Draw Labels**: Use the provided `draw_label` field for user-friendly display of draw information.

4. **Date Handling**: Always use the YYYY-MM-DD format for date parameters.

5. **Error Handling**: Implement proper error handling to provide a good user experience when API calls fail.

6. **Caching**: Consider implementing client-side caching for reports to reduce server load and improve performance.

7. **Default Date**: The Sales Report endpoint uses today's date by default if no date parameter is provided. The Tallysheet Report requires a date parameter.

8. **Available Dates**: You can use the `/api/dropdown/available-dates` endpoint to get a list of all available draws ordered by date and time. This is useful for implementing date and time selection in your application.

   **Example Response:**
   ```json
   {
     "success": true,
     "message": "Available draw list fetched successfully",
     "data": {
       "available_draws": [
         {
           "id": 1,
           "draw_date": "2025-05-08",
           "draw_date_formatted": "May 8, 2025",
           "draw_time": "10:30:00",
           "draw_time_formatted": "10:30 AM",
           "is_open": true,
           "is_active": true
         },
         {
           "id": 2,
           "draw_date": "2025-05-08",
           "draw_date_formatted": "May 8, 2025",
           "draw_time": "14:00:00",
           "draw_time_formatted": "2:00 PM",
           "is_open": true,
           "is_active": true
         },
         {
           "id": 3,
           "draw_date": "2025-05-07",
           "draw_date_formatted": "May 7, 2025",
           "draw_time": "10:30:00",
           "draw_time_formatted": "10:30 AM",
           "is_open": true,
           "is_active": true
         }
       ]
     }
   }
   ```

9. **Formatting Consistency**: All monetary values follow the same formatting pattern without peso symbols (e.g., "5,000.00"). This makes it easier to display values consistently across your application.

10. **Game Type Information**: The Sales Report includes game type information for each draw, which can be useful for displaying different game types with appropriate visual indicators.

11. **Draw Times**: You can use the `/api/dropdown/draws` endpoint to get a list of available draws with their times. This is useful for implementing draw time selection dropdowns in your application.

   **Example Response:**
   ```json
   {
     "success": true,
     "message": "Success",
     "data": [
       {
         "id": 1,
         "draw_date": "2025-05-08",
         "draw_date_formatted": "May 8, 2025",
         "draw_time": "10:30:00",
         "draw_time_formatted": "10:30 AM",
         "is_open": true,
         "is_active": true
       },
       {
         "id": 2,
         "draw_date": "2025-05-08",
         "draw_date_formatted": "May 8, 2025",
         "draw_time": "14:00:00",
         "draw_time_formatted": "2:00 PM",
         "is_open": true,
         "is_active": true
       },
       {
         "id": 3,
         "draw_date": "2025-05-08",
         "draw_date_formatted": "May 8, 2025",
         "draw_time": "17:00:00",
         "draw_time_formatted": "5:00 PM",
         "is_open": true,
         "is_active": true
       }
     ]
   }
   ```
