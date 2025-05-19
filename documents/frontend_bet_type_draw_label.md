# Frontend Usage: bet_type_draw_label and Updated placeBet API

## Overview
This guide explains how to use the new `bet_type_draw_label` field in your frontend (Flutter or web) and how to submit combination bets using the updated `placeBet` API endpoint.

---

## Why This Change? (Goal & Reason)

**The goal is to ensure that all bet type labels (e.g., `9PMD4`, `9PMD4-S2`, `2PMS2`) are always consistent and correct, regardless of where they are displayed (web, mobile, admin, etc.).**

Previously, frontend code had to reconstruct the label using draw time, game type, and sub-selection fields, which led to:
- Inconsistent formatting across platforms
- Extra logic and bugs in the frontend
- Difficulty supporting new bet types or changes in business rules

**Now, the backend provides a single, ready-to-display field (`bet_type_draw_label`) for every bet.**

- This guarantees the label is always correct and matches business requirements.
- If the label format or rules change, only the backend needs updating—no frontend changes required.
- Frontend code is simplified and less error-prone.

**Frontend developers should always use the provided `bet_type_draw_label` for display and never attempt to re-create or format the label themselves.**

---

## 1. Displaying Bet Type in the Bet List/Table

### **What Changed?**
- The API now returns a new field: `bet_type_draw_label` for every bet.
- This field is **already formatted** for display (e.g., `9PMD4`, `9PMD4-S2`, `2PMS2`, etc.).
- You no longer need to build or format the bet type string in your frontend.

### **How to Use**
- In your model, add a property for `betTypeDrawLabel` and parse it from the API response.
- In your table/list, display `betTypeDrawLabel` directly under the "Bet Type" column.

#### **Example (Flutter Dart Model):**
```dart
final String? betTypeDrawLabel;

factory Bet.fromJson(Map json) {
  return Bet(
    // ...other fields...
    betTypeDrawLabel: json['bet_type_draw_label'],
  );
}
```

#### **Example (Widget/Table):**
```dart
Text(bet.betTypeDrawLabel ?? '-')
```

---

## 2. Submitting Bets with Updated placeBet API

### Why Did We Change placeBet?
The new betting requirements (especially for 4D with S2/S3 sub-selections) mean customers can now place:
- Standard 4-digit (D4) bets
- Combination bets (D4 with S2/S3 combos)
- Standalone S2/S3 bets

Previously, the API could not handle both regular and combination bets in a single, flexible way. Now, the `placeBet` endpoint supports both:
- If the customer wants to bet only on a 4-digit number, they send a simple payload (no combinations).
- If the customer wants to bet combinations (e.g., S2/S3 combos from a D4 number), they send a `combinations` array and specify the sub-selection.

This change makes the API more flexible, matches real-world betting scenarios, and ensures all bet types are handled cleanly and consistently.

### Real-World Scenarios

#### Example: Customer Bets on 1234
Let's say a customer wants to bet on the number **1234**. Here are the possible ways they might place their bet and how you should handle/display them:

##### 1. Regular 4D Bet
The customer bets 10 pesos on 1234 for the 9PM draw (no combination):
```json
{
  "bet_number": "1234",
  "amount": 10,
  "draw_id": 1,
  "game_type_id": 2
}
```
- **API Response:**
  - `bet_type_draw_label`: `9PMD4`
- **Frontend Display:**
  - Bet Type: `9PMD4`
  - Bet Number: `1234`
  - Amount: `₱10`

##### 2. D4 Combination Bet (with S2 sub-selection)
The customer bets on 1234 for D4, and also wants to play S2 combos (e.g., "12" and "34") for 10 pesos each for the 9PM draw:
```json
{
  "bet_number": "1234",
  "amount": 0,
  "draw_id": 1,
  "game_type_id": 2,
  "is_combination": true,
  "d4_sub_selection": "S2",
  "combinations": [
    { "combination": "12", "amount": 10 },
    { "combination": "34", "amount": 10 }
  ]
}
```
- **API Response:**
  - Parent bet (1234): `bet_type_draw_label`: `9PMD4-S2`
  - Child bet (12): `bet_type_draw_label`: `9PMD4-S2`
  - Child bet (34): `bet_type_draw_label`: `9PMD4-S2`
- **Frontend Display:**
  - Bet Type: `9PMD4-S2`
  - Bet Number: `12` (or `34`)
  - Amount: `₱10`
  - (Parent bet 1234 may be shown with amount `₱0` or hidden)

##### 3. Standalone S2 Bet
The customer bets 10 pesos on "22" for S2 in the 2PM draw:
```json
{
  "bet_number": "22",
  "amount": 10,
  "draw_id": 2,
  "game_type_id": 3
}
```
- **API Response:**
  - `bet_type_draw_label`: `2PMS2`
- **Frontend Display:**
  - Bet Type: `2PMS2`
  - Bet Number: `22`
  - Amount: `₱10`

### **Payload Examples**

#### **A. Regular 4D Bet (no combination):**
```json
{
  "bet_number": "1234",
  "amount": 10,
  "draw_id": 1,
  "game_type_id": 2
}
```

#### **B. 4D Combination Bet (with S2 sub-selection):**
```json
{
  "bet_number": "1234",
  "amount": 0,
  "draw_id": 1,
  "game_type_id": 2,
  "is_combination": true,
  "d4_sub_selection": "S2",
  "combinations": [
    { "combination": "12", "amount": 10 },
    { "combination": "34", "amount": 10 }
  ]
}
```

#### **C. Standalone S2 Bet:**
```json
{
  "bet_number": "22",
  "amount": 10,
  "draw_id": 1,
  "game_type_id": 3
}
```

### **Frontend Submission Tips**
- Only include `combinations` and `d4_sub_selection` when placing a D4 combination bet.
- For regular bets, omit these fields.
- The API will return the placed bet(s) with the correct `bet_type_draw_label` for display.

---

## 3. Real-World Example: Displaying Bets

| Bet Type        | Bet Number | Amount | Ticket ID | Date               |
|-----------------|------------|--------|-----------|--------------------|
| 9PMD4           | 1234       | ₱10    | SXDP7F    | May 19, 2025 9:00PM|
| 2PMS2           | 22         | ₱10    | 5AHTIG    | May 19, 2025 2:00PM|
| 9PMD4-S2        | 12         | ₱10    | 5AHTIG    | May 19, 2025 9:00PM|

---

## 4. Migration/Upgrade Note
- Update your frontend model to parse `bet_type_draw_label`.
- Remove any custom bet type formatting logic from the frontend.
- Always use the backend-provided label for display.

---

## 5. Additional Notes
- If you need to filter or group bets by type, you can use `bet_type_draw_label` directly.
- If you add new bet types or change label formats, only the backend needs to be updated.

---

For further questions or integration help, contact the backend/API developer.
