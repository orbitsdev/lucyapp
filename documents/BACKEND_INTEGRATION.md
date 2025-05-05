# Lucky Betting App - Backend Integration Documentation

This document provides comprehensive details for implementing the Laravel backend for the Lucky Betting app. It outlines the data models, API endpoints, authentication mechanisms, and other backend requirements to support the Flutter frontend.

## Table of Contents

1. [System Overview](#system-overview)
2. [Data Models](#data-models)
3. [API Endpoints](#api-endpoints)
4. [Authentication & Authorization](#authentication--authorization)
5. [Business Logic](#business-logic)
6. [Database Schema](#database-schema)
7. [Integration Points](#integration-points)
8. [Deployment Considerations](#deployment-considerations)

## System Overview

The Lucky Betting app is a comprehensive betting management system with three user roles: Coordinator (Admin), Teller (Agent), and Customer. The system allows for number betting with scheduled draw times (2pm, 5pm, 9pm), commission tracking, and result management.

### Key Features

- **User Management**: Registration, authentication, and role-based access
- **Betting Operations**: Placing bets, cancellations, and combinations
- **Claims Processing**: QR code-based verification of winning tickets
- **Financial Tracking**: Sales reports, commission calculations, and tally sheets
- **Result Management**: Generating winning numbers and processing results
- **Schedule Management**: Setting and enforcing betting schedules

### Architecture Overview

```
+-------------------+        +-------------------+        +-------------------+
| Flutter Frontend  |<------>| Laravel API       |<------>| MySQL Database    |
| (Mobile App)      |        | (Backend)         |        | (Data Storage)    |
+-------------------+        +-------------------+        +-------------------+
```

## Data Models

### 1. User Model

```php
// users table
Schema::create('users', function (Blueprint $table) {
    $table->id();
    $table->string('username')->unique();
    $table->string('password');
    $table->string('name');
    $table->string('email')->nullable();
    $table->string('phone')->nullable();
    $table->enum('role', ['coordinator', 'teller', 'customer']);
    $table->string('profile_image')->nullable();
    $table->boolean('is_active')->default(true);
    $table->foreignId('location_id')->nullable()->constrained('locations');
    $table->timestamps();
    $table->softDeletes();
});
```

**Additional Fields for Tellers:**
```php
// tellers table (extends users)
Schema::create('tellers', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained('users');
    $table->foreignId('coordinator_id')->constrained('users');
    $table->decimal('commission_rate', 5, 2); // Percentage (5%, 10%, 15%)
    $table->decimal('balance', 10, 2)->default(0);
    $table->timestamps();
});
```

### 2. Location Model

```php
// locations table
Schema::create('locations', function (Blueprint $table) {
    $table->id();
    $table->string('name'); // e.g., "MANILA BRANCH"
    $table->string('address')->nullable();
    $table->foreignId('coordinator_id')->constrained('users');
    $table->boolean('is_active')->default(true);
    $table->timestamps();
});
```

### 3. Schedule Model

```php
// schedules table
Schema::create('schedules', function (Blueprint $table) {
    $table->id();
    $table->time('draw_time'); // 14:00:00, 17:00:00, 21:00:00
    $table->string('name'); // "2 pm", "5 pm", "9 pm"
    $table->boolean('is_active')->default(true);
    $table->timestamps();
});
```

### 4. Bet Model

```php
// bets table
Schema::create('bets', function (Blueprint $table) {
    $table->id();
    $table->string('bet_number');
    $table->decimal('amount', 10, 2);
    $table->foreignId('schedule_id')->constrained('schedules');
    $table->foreignId('teller_id')->constrained('users');
    $table->foreignId('customer_id')->nullable()->constrained('users');
    $table->foreignId('location_id')->constrained('locations');
    $table->date('bet_date');
    $table->string('ticket_id')->unique(); // For QR code generation
    $table->enum('status', ['active', 'cancelled', 'claimed', 'won', 'lost'])->default('active');
    $table->boolean('is_combination')->default(false);
    $table->timestamps();
});
```

### 5. Result Model

```php
// results table
Schema::create('results', function (Blueprint $table) {
    $table->id();
    $table->string('winning_number');
    $table->foreignId('schedule_id')->constrained('schedules');
    $table->date('draw_date');
    $table->foreignId('coordinator_id')->constrained('users'); // Who set the result
    $table->timestamps();
});
```

### 6. Claim Model

```php
// claims table
Schema::create('claims', function (Blueprint $table) {
    $table->id();
    $table->foreignId('bet_id')->constrained('bets');
    $table->foreignId('result_id')->constrained('results');
    $table->foreignId('teller_id')->constrained('users');
    $table->decimal('amount', 10, 2); // Winning amount
    $table->decimal('commission_amount', 10, 2); // Teller's commission
    $table->timestamp('claimed_at');
    $table->string('qr_code_data'); // Data from scanned QR code
    $table->timestamps();
});
```

### 7. Commission Model

```php
// commissions table
Schema::create('commissions', function (Blueprint $table) {
    $table->id();
    $table->foreignId('teller_id')->constrained('users');
    $table->decimal('rate', 5, 2); // Percentage rate
    $table->decimal('amount', 10, 2); // Commission amount
    $table->date('commission_date');
    $table->enum('type', ['sales', 'claims']);
    $table->foreignId('bet_id')->nullable()->constrained('bets');
    $table->foreignId('claim_id')->nullable()->constrained('claims');
    $table->timestamps();
});
```

### 8. Transaction Model

```php
// transactions table
Schema::create('transactions', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained('users');
    $table->decimal('amount', 10, 2);
    $table->enum('type', ['bet', 'claim', 'commission', 'adjustment']);
    $table->string('reference_id')->nullable(); // Reference to bet_id, claim_id, etc.
    $table->text('description')->nullable();
    $table->timestamps();
});
```

### 9. Tally Sheet Model

```php
// tally_sheets table
Schema::create('tally_sheets', function (Blueprint $table) {
    $table->id();
    $table->foreignId('teller_id')->constrained('users');
    $table->foreignId('location_id')->constrained('locations');
    $table->date('sheet_date');
    $table->decimal('total_sales', 10, 2)->default(0);
    $table->decimal('total_claims', 10, 2)->default(0);
    $table->decimal('total_commission', 10, 2)->default(0);
    $table->decimal('net_amount', 10, 2)->default(0);
    $table->timestamps();
});
```

### 10. Sold Out Numbers Model

```php
// sold_out_numbers table
Schema::create('sold_out_numbers', function (Blueprint $table) {
    $table->id();
    $table->string('number');
    $table->foreignId('schedule_id')->constrained('schedules');
    $table->date('date');
    $table->foreignId('location_id')->constrained('locations');
    $table->boolean('is_active')->default(true);
    $table->timestamps();
});
```

## API Endpoints

### Authentication

```
POST /api/auth/login
POST /api/auth/logout
POST /api/auth/refresh
GET  /api/auth/user
```

### User Management (Coordinator Only)

```
GET    /api/users
POST   /api/users
GET    /api/users/{id}
PUT    /api/users/{id}
DELETE /api/users/{id}
GET    /api/users/tellers
GET    /api/users/customers
```

### Locations (Coordinator Only)

```
GET    /api/locations
POST   /api/locations
GET    /api/locations/{id}
PUT    /api/locations/{id}
DELETE /api/locations/{id}
```

### Schedules (Coordinator Only)

```
GET    /api/schedules
POST   /api/schedules
GET    /api/schedules/{id}
PUT    /api/schedules/{id}
DELETE /api/schedules/{id}
GET    /api/schedules/active
```

### Bets (Teller & Coordinator)

```
GET    /api/bets
POST   /api/bets
GET    /api/bets/{id}
PUT    /api/bets/{id}
DELETE /api/bets/{id}
GET    /api/bets/by-date/{date}
GET    /api/bets/by-schedule/{scheduleId}
GET    /api/bets/by-teller/{tellerId}
POST   /api/bets/cancel/{id}
GET    /api/bets/ticket/{ticketId}
```

### Claims (Teller & Coordinator)

```
GET    /api/claims
POST   /api/claims
GET    /api/claims/{id}
GET    /api/claims/by-date/{date}
GET    /api/claims/by-teller/{tellerId}
POST   /api/claims/verify-qr
```

### Results (Coordinator Only)

```
GET    /api/results
POST   /api/results
GET    /api/results/{id}
PUT    /api/results/{id}
DELETE /api/results/{id}
GET    /api/results/by-date/{date}
GET    /api/results/by-schedule/{scheduleId}
POST   /api/results/generate-hits
```

### Commissions

```
GET    /api/commissions
GET    /api/commissions/{id}
GET    /api/commissions/by-teller/{tellerId}
GET    /api/commissions/by-date/{date}
GET    /api/commissions/summary
```

### Tally Sheets

```
GET    /api/tally-sheets
GET    /api/tally-sheets/{id}
GET    /api/tally-sheets/by-teller/{tellerId}
GET    /api/tally-sheets/by-date/{date}
GET    /api/tally-sheets/generate/{tellerId}/{date}
```

### Reports (Coordinator Only)

```
GET    /api/reports/sales
GET    /api/reports/claims
GET    /api/reports/commissions
GET    /api/reports/summary
GET    /api/reports/teller-performance
```

### Customer Endpoints

```
GET    /api/customer/bets
POST   /api/customer/bets
GET    /api/customer/results
GET    /api/customer/history
```

## Authentication & Authorization

The Lucky Betting app requires robust authentication and authorization mechanisms to ensure secure access to appropriate resources based on user roles.

### Sanctum Authentication

Implement Laravel Sanctum for secure API access:

```php
// Laravel Sanctum package
composer require laravel/sanctum
```

### Middleware for Role-Based Access

```php
// RoleMiddleware.php
public function handle($request, Closure $next, ...$roles)
{
    if (!$request->user() || !in_array($request->user()->role, $roles)) {
        return response()->json(['message' => 'Unauthorized'], 403);
    }
    
    return $next($request);
}

// Usage in routes
Route::middleware(['auth:sanctum', 'role:coordinator'])->group(function () {
    // Coordinator-only routes
});

Route::middleware(['auth:sanctum', 'role:coordinator,teller'])->group(function () {
    // Routes accessible by both coordinators and tellers
});
```

## Business Logic

### 1. Bet Processing

```php
// BetService.php
public function createBet(array $data)
{
    // Validate bet number format
    if (!$this->isValidBetNumber($data['bet_number'])) {
        throw new InvalidBetException('Invalid bet number format');
    }
    
    // Check if schedule is active
    $schedule = Schedule::findOrFail($data['schedule_id']);
    if (!$schedule->is_active) {
        throw new ScheduleClosedException('This schedule is not active');
    }
    
    // Check if number is sold out
    if ($this->isNumberSoldOut($data['bet_number'], $data['schedule_id'], $data['location_id'])) {
        throw new SoldOutException('This number is sold out for the selected schedule');
    }
    
    // Generate unique ticket ID for QR code
    $ticketId = $this->generateUniqueTicketId();
    
    // Create bet record
    $bet = Bet::create([
        'bet_number' => $data['bet_number'],
        'amount' => $data['amount'],
        'schedule_id' => $data['schedule_id'],
        'teller_id' => $data['teller_id'],
        'customer_id' => $data['customer_id'] ?? null,
        'location_id' => $data['location_id'],
        'bet_date' => now()->toDateString(),
        'ticket_id' => $ticketId,
        'is_combination' => $data['is_combination'] ?? false,
    ]);
    
    // Calculate and record commission
    $teller = Teller::where('user_id', $data['teller_id'])->first();
    $commissionAmount = $data['amount'] * ($teller->commission_rate / 100);
    
    Commission::create([
        'teller_id' => $data['teller_id'],
        'rate' => $teller->commission_rate,
        'amount' => $commissionAmount,
        'commission_date' => now()->toDateString(),
        'type' => 'sales',
        'bet_id' => $bet->id,
    ]);
    
    // Update tally sheet
    $this->updateTallySheet($data['teller_id'], $data['location_id'], $data['amount'], 0, $commissionAmount);
    
    return $bet;
}
```

### 2. Claim Processing

```php
// ClaimService.php
public function processClaim(string $qrCodeData)
{
    // Decode QR code data to get ticket ID
    $ticketId = $this->decodeQrCode($qrCodeData);
    
    // Find the bet
    $bet = Bet::where('ticket_id', $ticketId)->first();
    if (!$bet) {
        throw new TicketNotFoundException('Ticket not found');
    }
    
    // Check if bet is already claimed or cancelled
    if ($bet->status !== 'active' && $bet->status !== 'won') {
        throw new InvalidClaimException('This ticket has already been processed');
    }
    
    // Find the result for the bet's schedule and date
    $result = Result::where('schedule_id', $bet->schedule_id)
                    ->where('draw_date', $bet->bet_date)
                    ->first();
    
    if (!$result) {
        throw new ResultNotFoundException('No result found for this ticket');
    }
    
    // Check if the bet is a winner
    if (!$this->isWinningBet($bet->bet_number, $result->winning_number)) {
        throw new NotWinningException('This is not a winning ticket');
    }
    
    // Calculate winning amount (implement your prize calculation logic)
    $winningAmount = $this->calculateWinningAmount($bet->amount, $bet->bet_number, $result->winning_number);
    
    // Calculate commission
    $teller = Teller::where('user_id', auth()->id())->first();
    $commissionAmount = $winningAmount * ($teller->commission_rate / 100);
    
    // Create claim record
    $claim = Claim::create([
        'bet_id' => $bet->id,
        'result_id' => $result->id,
        'teller_id' => auth()->id(),
        'amount' => $winningAmount,
        'commission_amount' => $commissionAmount,
        'claimed_at' => now(),
        'qr_code_data' => $qrCodeData,
    ]);
    
    // Update bet status
    $bet->update(['status' => 'claimed']);
    
    // Record commission
    Commission::create([
        'teller_id' => auth()->id(),
        'rate' => $teller->commission_rate,
        'amount' => $commissionAmount,
        'commission_date' => now()->toDateString(),
        'type' => 'claims',
        'claim_id' => $claim->id,
    ]);
    
    // Update tally sheet
    $this->updateTallySheet(auth()->id(), $bet->location_id, 0, $winningAmount, $commissionAmount);
    
    return $claim;
}
```

### 3. Result Generation

```php
// ResultService.php
public function generateResult(int $scheduleId, string $date)
{
    // Check if result already exists
    $existingResult = Result::where('schedule_id', $scheduleId)
                           ->where('draw_date', $date)
                           ->first();
    
    if ($existingResult) {
        throw new ResultExistsException('Result already exists for this schedule and date');
    }
    
    // Generate random winning number (implement your logic)
    $winningNumber = $this->generateRandomWinningNumber();
    
    // Create result record
    $result = Result::create([
        'winning_number' => $winningNumber,
        'schedule_id' => $scheduleId,
        'draw_date' => $date,
        'coordinator_id' => auth()->id(),
    ]);
    
    // Process all matching bets
    $this->processWinningBets($winningNumber, $scheduleId, $date);
    
    return $result;
}
```

## Database Schema

### Entity Relationship Diagram

```
+-------------+       +-------------+       +-------------+
| Users       |       | Locations   |       | Schedules   |
+-------------+       +-------------+       +-------------+
| id          |<----->| id          |       | id          |
| username    |       | name        |       | draw_time   |
| password    |       | address     |       | name        |
| name        |       | coordinator_|------>| is_active   |
| email       |       | is_active   |       +-------------+
| phone       |       +-------------+              ^
| role        |              ^                     |
| profile_img |              |                     |
| is_active   |              |                     |
| location_id |------------->|                     |
+-------------+                                    |
      ^                                            |
      |                                            |
+-------------+       +-------------+       +-------------+
| Tellers     |       | Bets        |       | Results     |
+-------------+       +-------------+       +-------------+
| id          |       | id          |       | id          |
| user_id     |------>| bet_number  |       | winning_num |
| coordinator |       | amount      |       | schedule_id |------+
| comm_rate   |       | schedule_id |------>| draw_date   |      |
| balance     |       | teller_id   |       | coordinator |      |
+-------------+       | customer_id |       +-------------+      |
      ^               | location_id |              ^             |
      |               | bet_date    |              |             |
      |               | ticket_id   |              |             |
      |               | status      |              |             |
      |               | combination |              |             |
      |               +-------------+              |             |
      |                      ^                     |             |
      |                      |                     |             |
+-------------+       +-------------+       +-------------+      |
| Commissions |       | Claims      |       | Tally Sheets|      |
+-------------+       +-------------+       +-------------+      |
| id          |       | id          |       | id          |      |
| teller_id   |------>| bet_id      |------>| teller_id   |      |
| rate        |       | result_id   |------>| location_id |      |
| amount      |       | teller_id   |       | sheet_date  |      |
| comm_date   |       | amount      |       | total_sales |      |
| type        |       | comm_amount |       | total_claims|      |
| bet_id      |       | claimed_at  |       | total_comm  |      |
| claim_id    |       | qr_code     |       | net_amount  |      |
+-------------+       +-------------+       +-------------+      |
                                                                 |
+-------------+                                                  |
| Sold Out    |                                                  |
+-------------+                                                  |
| id          |                                                  |
| number      |                                                  |
| schedule_id |<-------------------------------------------------+
| date        |
| location_id |
| is_active   |
+-------------+
```

## Integration Points

### 1. QR Code Generation and Scanning

The system requires QR code generation for tickets and scanning for claims processing:

```php
// QR Code Generation (server-side)
public function generateQrCode(string $ticketId)
{
    // Using a QR code package like SimpleSoftwareIO/simple-qrcode
    return QrCode::size(300)->generate($ticketId);
}

// API endpoint to verify QR code
public function verifyQrCode(Request $request)
{
    $qrData = $request->input('qr_data');
    
    try {
        $claimResult = $this->claimService->processClaim($qrData);
        return response()->json([
            'success' => true,
            'claim' => $claimResult,
            'message' => 'Claim processed successfully'
        ]);
    } catch (Exception $e) {
        return response()->json([
            'success' => false,
            'message' => $e->getMessage()
        ], 400);
    }
}
```

### 2. Flutter Integration

The Laravel backend will need to provide API endpoints that match the Flutter app's requirements:

```php
// routes/api.php
Route::prefix('v1')->group(function () {
    // Auth routes
    Route::post('auth/login', [AuthController::class, 'login']);
    Route::post('auth/logout', [AuthController::class, 'logout'])->middleware('auth:sanctum');
    Route::get('auth/user', [AuthController::class, 'user'])->middleware('auth:sanctum');
    
    // Protected routes
    Route::middleware(['auth:sanctum'])->group(function () {
        // Common routes for all authenticated users
        Route::get('schedules/active', [ScheduleController::class, 'getActiveSchedules']);
        
        // Coordinator routes
        Route::middleware(['role:coordinator'])->group(function () {
            Route::apiResource('users', UserController::class);
            Route::apiResource('locations', LocationController::class);
            Route::apiResource('schedules', ScheduleController::class);
            Route::apiResource('results', ResultController::class);
            Route::post('results/generate-hits', [ResultController::class, 'generateHits']);
            Route::get('reports/summary', [ReportController::class, 'summary']);
            // More coordinator routes...
        });
        
        // Teller routes
        Route::middleware(['role:teller,coordinator'])->group(function () {
            Route::apiResource('bets', BetController::class);
            Route::post('bets/cancel/{id}', [BetController::class, 'cancelBet']);
            Route::apiResource('claims', ClaimController::class);
            Route::post('claims/verify-qr', [ClaimController::class, 'verifyQrCode']);
            Route::get('tally-sheets/by-date/{date}', [TallySheetController::class, 'getByDate']);
            // More teller routes...
        });
        
        // Customer routes
        Route::middleware(['role:customer'])->group(function () {
            Route::get('customer/bets', [CustomerController::class, 'getBets']);
            Route::post('customer/bets', [CustomerController::class, 'placeBet']);
            Route::get('customer/results', [CustomerController::class, 'getResults']);
            // More customer routes...
        });
    });
});
```

## Deployment Considerations

### 1. Server Requirements

- PHP 8.1+
- Laravel 10.x
- MySQL 8.0+
- Composer
- Redis (optional, for caching)

### 2. Environment Configuration

```
APP_NAME="Lucky Betting API"
APP_ENV=production
APP_DEBUG=false
APP_URL=https://api.luckybetting.com

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=lucky_betting
DB_USERNAME=luckybetting_user
DB_PASSWORD=secure_password

SANCTUM_STATEFUL_DOMAINS=luckybetting.com
SESSION_DOMAIN=.luckybetting.com
SANCTUM_EXPIRATION=1440
```

### 3. Security Measures

- Implement rate limiting to prevent abuse
- Use HTTPS for all API communications
- Implement proper CORS policies
- Set up proper database backups
- Use environment variables for sensitive information
- Implement API versioning for future updates

### 4. Performance Optimization

- Implement database indexing for frequently queried fields
- Use caching for frequently accessed data
- Implement pagination for large data sets
- Consider using a CDN for serving static assets

## Implementation Timeline

1. **Phase 1: Core Backend Setup** (2 weeks)
   - Database schema implementation
   - Authentication system
   - Basic API endpoints

2. **Phase 2: Business Logic Implementation** (3 weeks)
   - Betting system
   - Claims processing
   - Commission calculation
   - Result generation

3. **Phase 3: Integration and Testing** (2 weeks)
   - Integration with Flutter frontend
   - QR code implementation
   - Comprehensive testing

4. **Phase 4: Deployment and Optimization** (1 week)
   - Server setup
   - Performance optimization
   - Security hardening

## Conclusion

This documentation provides a comprehensive guide for implementing the Laravel backend for the Lucky Betting app. By following these specifications, you'll create a robust API that supports all the functionality required by the Flutter frontend while maintaining security, performance, and scalability.

Remember to implement proper error handling, validation, and logging throughout the application to ensure a smooth user experience and easier debugging when issues arise.
